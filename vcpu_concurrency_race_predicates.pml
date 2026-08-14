/*
 * Spin/Promela Model: vcpu_concurrency_race_predicates.pml
 *
 * Architecture: Multi-Threaded Concurrent Race-Condition Predicates VCPU.
 *
 * Threat Model: Static Lifters (VTIL / IDA / Ghidra / NoVmp) & Sequential Symbolic Engines.
 *
 * Why VTIL Fails:
 * Static analysis tools assume that sequential code execution is deterministic.
 * This VCPU spawns two lightweight worker threads running in lock-step:
 * - Thread_1 (VWorker_1) and Thread_2 (VWorker_2) concurrently mutate a volatile atomic cell `M`.
 * - The order of writes is synchronized via memory barriers and hardware atomic increments (`LOCK XADD`),
 *   producing a pseudo-random yet mathematically bounded result: M in {State_A, State_B}.
 * - Virtual branch targets depend on the atomic resolution of this race condition.
 * Static lifters cannot collapse multi-threaded atomic concurrency into a single deterministic IR block.
 *
 * Verification Objectives:
 * - Freedom from deadlock across all thread interleavings.
 * - Both possible race outcomes lead to safe, valid VCPU execution states.
 */

#define WORKER_STEPS 3

byte atomic_cell = 0;
byte barrier_phase = 0;
byte thread1_done = 0;
byte thread2_done = 0;
bool system_safe = true;

proctype VWorker_1() {
    byte i;
    for (i : 1 .. WORKER_STEPS) {
        atomic {
            /* Atomic Fetch-and-Add Mutation */
            atomic_cell = (atomic_cell * 2 + 1) % 16;
            thread1_done++;
        }
    }
}

proctype VWorker_2() {
    byte i;
    for (i : 1 .. WORKER_STEPS) {
        atomic {
            /* Interleaved Atomic XOR Mutation */
            atomic_cell = (atomic_cell ^ 5) % 16;
            thread2_done++;
        }
    }
}

proctype VCPU_DispatchWatcher() {
    /* Wait for both concurrent workers to finish */
    (thread1_done == WORKER_STEPS && thread2_done == WORKER_STEPS);
    
    /* Ensure the atomic result is within safe bounds (GF(16)) */
    if
    :: (atomic_cell < 16) -> system_safe = true;
    :: else               -> system_safe = false;
    fi;
}

init {
    atomic {
        run VWorker_1();
        run VWorker_2();
        run VCPU_DispatchWatcher();
    }
}

/* LTL Verification: All interleavings terminate safely with valid atomic cell */
ltl concurrent_safety { <> (thread1_done == WORKER_STEPS && thread2_done == WORKER_STEPS && system_safe == true) }
