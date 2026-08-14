/*
 * Spin/Promela Model: vcpu_exception_dispatch.pml
 *
 * Architecture: Trap & Hardware Exception-Driven Dispatch (SEH / Signal-Based VCPU).
 *
 * Threat Model: Static Control Flow Graph (CFG) Construction & Linear Disassembly in VTIL.
 *
 * Why VTIL Fails:
 * VTIL builds basic blocks based on traditional branch instructions (`jmp`, `call`, `ret`, `cjmp`).
 * In this VCPU, every handler ends by intentionally triggering a CPU hardware fault/trap
 * (e.g. Division by Zero `#DE`, Access Violation `#AV`, Invalid Opcode `#UD`).
 * The OS Structured Exception Handler (SEH / Vectored Exception Handler):
 *   1. Intercepts the exception context frame.
 *   2. Extracts the faulted instruction address.
 *   3. Decrypts the address of the next virtual handler into `Context.Rip`.
 *   4. Returns `EXCEPTION_CONTINUE_EXECUTION`.
 * For VTIL and static lifters, every single basic block terminates in an unhandled exception or abort,
 * completely fragmenting the lifted program into disconnected orphan instructions.
 *
 * Verification Objectives:
 * - Deterministic fault-and-resume cycle without unhandled crash.
 * - Complete execution of all instruction steps via pure SEH dispatch.
 */

#define STEPS 5

mtype = { FAULT_DIV_ZERO, FAULT_INVALID_OP, FAULT_ACCESS_VIOL, RESUME_OK };

chan seh_trap_channel = [0] of { mtype, byte }; /* { fault_type, faulty_vip } */
chan seh_resume_channel = [0] of { byte };       /* { next_handler_vip } */

byte vip = 0;
byte executed_steps = 0;
bool vm_finished = false;

/* Virtual Machine Worker Thread */
proctype VCPU_Executor() {
    do
    :: (vip < STEPS) ->
        /* Trigger deliberate architectural trap instead of branching */
        if
        :: (vip % 2 == 0) ->
            seh_trap_channel ! FAULT_DIV_ZERO, vip;
        :: else ->
            seh_trap_channel ! FAULT_INVALID_OP, vip;
        fi;

        /* Wait for SEH to patch instruction pointer and resume context */
        seh_resume_channel ? vip;
        executed_steps++;
    :: (vip >= STEPS) ->
        vm_finished = true;
        break;
    od;
}

/* Vectored / Structured Exception Handler (OS-Level Shim) */
proctype SEH_Dispatcher() {
    mtype fault;
    byte faulted_ip;

    do
    :: !vm_finished ->
        seh_trap_channel ? fault, faulted_ip;

        /* Exception filter: decrypt next handler address from faulted context */
        byte next_vip = faulted_ip + 1;

        /* Resume thread execution */
        seh_resume_channel ! next_vip;
    :: vm_finished ->
        break;
    od;
}

init {
    atomic {
        run SEH_Dispatcher();
        run VCPU_Executor();
    }
}

/* LTL Verification: All trap-driven steps execute and finish cleanly without deadlock */
ltl seh_liveness { <> (vm_finished == true && executed_steps == STEPS) }
