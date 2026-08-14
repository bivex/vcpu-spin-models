/*
 * Spin/Promela Model: vcpu_virtual_interrupts.pml
 *
 * Architecture: Preemptive Virtual Interrupt Controller & Asynchronous Trap Pipeline.
 *
 * Threat Model: Static Sequential Basic-Block Disassemblers (VTIL, Ghidra, IDA Pro).
 *
 * Why VTIL Fails:
 * Static lifters assume machine instructions execute in a contiguous atomic sequence.
 * This VCPU implements an internal Virtual Programmable Interrupt Controller (V_APIC):
 *   1. An asynchronous virtual timer periodically asserts an interrupt request (`V_IRQ`).
 *   2. The VCPU is preempted mid-stream, saving its virtual context frame (`V_FLAGS`, `VIP`, `VSP`).
 *   3. It executes a Virtual Interrupt Service Routine (V_ISR) that updates keys and shifts state.
 *   4. An explicit `V_IRET` restores the preempted frame and resumes bytecode execution.
 * Since control flow breaks unpredictably at non-branch instructions, static basic-block boundaries
 * completely break down.
 *
 * Verification Objectives:
 * - Absence of deadlock during nested virtual interrupt handling.
 * - Exact context restoration after `V_IRET`.
 * - Safe termination of user program.
 */

#define MAIN_STEPS 4
#define IRQ_LIMIT 2

chan irq_line = [0] of { byte }; /* Async interrupt line */
chan irq_ack  = [0] of { byte }; /* Interrupt acknowledge line */

byte main_vip = 0;
byte isr_executions = 0;
byte main_progress = 0;
bool vcpu_interrupted = false;
bool vcpu_done = false;

/* Virtual APIC / Hardware Timer Process */
proctype Virtual_APIC() {
    byte i;
    for (i : 1 .. IRQ_LIMIT) {
        if
        :: !vcpu_done ->
            irq_line ! 1;    /* Trigger V_IRQ */
            irq_ack ? 1;     /* Wait for V_ISR completion */
        :: vcpu_done ->
            break;
        fi;
    }
}

/* Preemptive Virtual CPU Executor Process */
proctype Preemptive_VCPU() {
    byte saved_vip = 0;

    do
    :: (main_progress < MAIN_STEPS) ->
        if
        /* Case 1: Normal instruction step */
        :: (main_progress < MAIN_STEPS) ->
            main_vip++;
            main_progress++;

        /* Case 2: Asynchronous V_IRQ interrupt caught mid-execution */
        :: irq_line ? 1 ->
            vcpu_interrupted = true;
            saved_vip = main_vip; /* Save virtual frame */

            /* Execute Virtual Interrupt Service Routine (V_ISR) */
            isr_executions++;

            /* V_IRET: Restore frame */
            main_vip = saved_vip;
            vcpu_interrupted = false;
            irq_ack ! 1;
        fi;
    :: (main_progress >= MAIN_STEPS) ->
        vcpu_done = true;
        break;
    od;
}

init {
    atomic {
        run Virtual_APIC();
        run Preemptive_VCPU();
    }
}

/* LTL Verification: VCPU finishes all main steps with zero stuck interrupts */
ltl interrupt_safety { <> (vcpu_done == true && main_progress == MAIN_STEPS && vcpu_interrupted == false) }
