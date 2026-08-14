/*
 * Spin/Promela Model: vcpu_self_mutating_bytecode.pml
 *
 * Architecture: Self-Modifying Rolling Bytecode with Overlapping Instruction Windows.
 *
 * Threat Model: VTIL / Static Disassembly & Linear Sweep.
 *
 * Why VTIL Fails:
 * Static lifters assume bytecode is immutable (Read-Only) during lifting.
 * In this VCPU:
 * - Each handler modifies the bytecode of subsequent instructions (`PCode[VIP + delta] ^= Key`).
 * - Instruction boundaries overlap: byte N can be an operand in step 1, but becomes part of
 *   the opcode in step 2.
 * - Static lifting produces incorrect semantics because the lifted IR does not match the
 *   runtime dynamic bytecode state.
 *
 * Verification Objectives:
 * - Deterministic forward decoding despite runtime self-mutation.
 * - Complete execution without buffer overrun.
 */

#define BYTECODE_LEN 6

byte bytecode[BYTECODE_LEN];
byte vip = 0;
byte register_acc = 5;
byte executed_steps = 0;
bool mutation_valid = true;

proctype SelfMutatingVCPU() {
    byte op = 0;
    byte arg = 0;

    do
    :: (vip < (BYTECODE_LEN - 1)) ->
        /* 1. Fetch current opcode & argument */
        op = bytecode[vip];
        arg = bytecode[vip + 1];

        /* 2. Execute operation */
        if
        :: (op == 1) -> /* ACC = (ACC + arg) % 16 */
            register_acc = (register_acc + arg) % 16;
        :: (op == 2) -> /* ACC = (ACC ^ arg) % 16 */
            register_acc = (register_acc ^ arg) % 16;
        :: else ->
            skip;
        fi;

        /* 3. Self-Mutation: Modify upcoming instruction stream ahead of VIP */
        if
        :: ((vip + 2) < BYTECODE_LEN) ->
            bytecode[vip + 2] = (bytecode[vip + 2] ^ register_acc) % 8;
        :: else -> skip;
        fi;

        vip = vip + 2;
        executed_steps++;
    :: (vip >= (BYTECODE_LEN - 1)) ->
        break;
    od;
}

init {
    /* Initial bytecode */
    bytecode[0] = 1; bytecode[1] = 3; /* op=1 (Add), arg=3 */
    bytecode[2] = 2; bytecode[3] = 4; /* op=2 (Xor), arg=4 (will be mutated before execution) */
    bytecode[4] = 1; bytecode[5] = 1; /* op=1 (Add), arg=1 (will be mutated before execution) */

    run SelfMutatingVCPU();
}

/* LTL Verification: VCPU finishes all steps with safe mutation */
ltl safe_self_mutation { <> (executed_steps == 3 && vip >= (BYTECODE_LEN - 1)) }
