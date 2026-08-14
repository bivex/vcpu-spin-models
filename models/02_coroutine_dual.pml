/*
 * Spin/Promela Model: vcpu_coroutine_dual.pml
 *
 * Architecture: Interleaved Dual-VCPU (Co-routine VCPU / Multi-VCPU Pipeline).
 *
 * Threat Model: VTIL / Static Deobfuscation Lifters.
 *
 * Why VTIL Fails against Interleaved Co-routine VCPUs:
 * 1. Single-trace assumption: VTIL lifts basic blocks assuming a deterministic, single-thread
 *    sequential execution path.
 * 2. Interlocked State Machine: VCPU_A (Master / Cryptor) and VCPU_B (Slave / Arithmetic)
 *    communicate via lock-free ring-buffers / synchronization channels.
 * 3. VTIL's Dead Code Elimination (DCE) and Constant Folding fail because data dependencies
 *    cross asynchronous channel boundaries with non-local side effects.
 *
 * Verification Objectives:
 * - Absence of Deadlock between VCPU_A and VCPU_B.
 * - Buffer boundary safety (no overflow / underflow).
 * - Complete execution of all bytecode instructions.
 */

#define QUEUE_SIZE 2
#define MAX_OPS 6

/* Inter-VCPU Communication Channels */
chan a_to_b = [QUEUE_SIZE] of { byte, byte }; /* { token_id, payload } */
chan b_to_a = [QUEUE_SIZE] of { byte };       /* { status_ack } */

byte master_vsp = 8;
byte slave_vsp = 8;
byte master_pc = 0;
byte executed_count = 0;
bool done_flag = false;

/* Shared Virtual Stack */
byte shared_stack[16];

proctype VCPU_Master() {
    byte op_token = 0;
    byte payload = 0;
    byte ack = 0;

    do
    :: (master_pc < MAX_OPS) ->
        /* Generate next cryptographic token */
        op_token = (master_pc * 3 + 1) % 4;
        payload = (master_pc * 7 + 5) % 16;

        /* Send execution command to Slave VCPU */
        a_to_b ! op_token, payload;

        /* Wait for execution confirmation / sync barrier */
        b_to_a ? ack;

        master_pc++;
    :: (master_pc >= MAX_OPS) ->
        /* Send termination token */
        a_to_b ! 255, 0;
        break;
    od;
}

proctype VCPU_Slave() {
    byte op = 0;
    byte arg = 0;

    do
    :: a_to_b ? op, arg ->
        if
        :: (op == 255) -> /* Termination signal */
            done_flag = true;
            break;
        :: (op == 0) -> /* Push to shared VSP */
            slave_vsp = (slave_vsp - 1) % 16;
            shared_stack[slave_vsp] = arg;
        :: (op == 1) -> /* Add on shared VSP */
            shared_stack[slave_vsp + 1] = (shared_stack[slave_vsp] + shared_stack[slave_vsp + 1]) % 16;
            slave_vsp = (slave_vsp + 1) % 16;
        :: (op == 2) -> /* Bitwise NOR on shared VSP */
            shared_stack[slave_vsp + 1] = (~(shared_stack[slave_vsp] | shared_stack[slave_vsp + 1])) % 16;
            slave_vsp = (slave_vsp + 1) % 16;
        :: else -> /* No-op / state mutation */
            skip;
        fi;

        executed_count++;
        /* Send ACK back to Master */
        b_to_a ! 1;
    od;
}

init {
    atomic {
        run VCPU_Master();
        run VCPU_Slave();
    }
}

/* LTL Verification: Both VCPUs terminate successfully without deadlock */
ltl safe_termination { <> (done_flag == true && executed_count == MAX_OPS) }
