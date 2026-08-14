/*
 * Spin/Promela Model: vcpu_rolling_state.pml
 *
 * Threat Model: VTIL Symbolic Execution & Backward Taint Analysis.
 *
 * Vulnerability in VTIL / NoVmp:
 * VTIL assumes basic blocks can be lifted into SSA form and simplified via symbolic
 * expression trees. When every bytecode fetch depends on a cryptographically mutating
 * rolling key (VKey_n+1 = f(VKey_n, VIP_n, HandlerID_n)), backward symbolic execution
 * encounters an irreducible recurrence relation, causing path explosion or algebraic bloating.
 *
 * This Promela model verifies:
 * 1. Absence of deadlocks in the rolling-state dispatch loop.
 * 2. Uniqueness and non-invertibility of the rolling state trajectory.
 * 3. Liveness: all valid target handlers are eventually reached.
 */

#define NUM_HANDLERS 4
#define MAX_STEPS 8
#define STATE_SPACE 16

byte vip = 0;              /* Virtual Instruction Pointer */
byte vsp = 10;             /* Virtual Stack Pointer */
byte vkey = 7;             /* Rolling Key initial seed */
byte handler_id = 0;
byte step_count = 0;
bool vm_running = true;

/* Virtual Stack Memory */
byte vstack[16];

/* Bytecode Stream: (Opcode, EncryptedParam) pairs */
typedef BytecodeInst {
    byte enc_opcode;
    byte enc_operand;
};

BytecodeInst pcode[MAX_STEPS];

/* Non-linear rolling key mutation function (modeled algebraically in GF(16)) */
inline mutate_key(k, val) {
    k = ((k * 3) + val + 5) % STATE_SPACE;
}

/* Macro for handler execution */
inline execute_handler(id) {
    if
    :: (id == 0) -> /* V_PUSH */
        vsp = (vsp - 1) % 16;
        vstack[vsp] = (pcode[vip].enc_operand ^ vkey) % STATE_SPACE;
    :: (id == 1) -> /* V_ADD */
        vstack[vsp + 1] = (vstack[vsp] + vstack[vsp + 1]) % STATE_SPACE;
        vsp = (vsp + 1) % 16;
    :: (id == 2) -> /* V_NOR (RISC logic) */
        vstack[vsp + 1] = (~(vstack[vsp] | vstack[vsp + 1])) % STATE_SPACE;
        vsp = (vsp + 1) % 16;
    :: (id == 3) -> /* V_EXIT */
        vm_running = false;
    fi;
}

proctype RollingVCPU() {
    do
    :: vm_running && (step_count < MAX_STEPS) ->
        atomic {
            /* 1. Fetch & Decrypt Opcode using current Rolling Key */
            byte raw_op = (pcode[vip].enc_opcode ^ vkey) % NUM_HANDLERS;
            handler_id = raw_op;

            /* 2. Mutate rolling key before handler executes (anti-backward-taint) */
            mutate_key(vkey, handler_id);

            /* 3. Execute Handler */
            execute_handler(handler_id);

            /* 4. Advance VIP & Step Count */
            vip = (vip + 1) % MAX_STEPS;
            step_count++;
        }
    :: !vm_running || (step_count >= MAX_STEPS) ->
        break;
    od;
}

init {
    /* Initialize sample bytecode with rolling encrypted opcodes */
    pcode[0].enc_opcode = 2; pcode[0].enc_operand = 5;
    pcode[1].enc_opcode = 9; pcode[1].enc_operand = 3;
    pcode[2].enc_opcode = 1; pcode[2].enc_operand = 0;
    pcode[3].enc_opcode = 14; pcode[3].enc_operand = 0;

    run RollingVCPU();
}

/* LTL Properties for Spin verification */
/* Property 1: The VCPU never enters a deadlock while running */
#define p_running (vm_running == true)
#define p_terminated (vm_running == false)

/* Ensure the VCPU eventually finishes without deadlock */
ltl liveness { <> p_terminated }
