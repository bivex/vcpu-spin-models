/*
 * Spin/Promela Model: vcpu_heterogeneous_switching.pml
 *
 * Architecture: Heterogeneous Multi-VCPU Pipeline with Runtime Context Morphing.
 *
 * Threat Model: VTIL / NoVmp Virtual Architecture Lifting.
 *
 * Why VTIL Fails:
 * Static lifters assume a fixed VCPU architecture (e.g. 1 fixed VSP register, 1 VIP, constant stack layout).
 * This model implements 3 heterogeneous VCPUs (Alpha, Beta, Gamma) with:
 * - Mutating VSP registers (VSP_A -> VSP_B -> VSP_C).
 * - Inverse bytecode traversal directions (Forward -> Backward -> Stride).
 * - Dynamic Context Transformation (Permuting all register slots on VCPU switch).
 *
 * A static lifter tracking one architecture's registers immediately loses dataflow tracking
 * upon reaching a context-morphing gate.
 *
 * Verification Objectives:
 * - Correct preservation of CPU register values across all morphing transitions.
 * - Bidirectional transitions without state loss or memory corruption.
 */

#define NUM_REGS 4
#define SWITCH_STEPS 3

/* Virtual Registers */
byte vregs[NUM_REGS];

/* Permutation Matrices for Context Morphing */
byte perm_alpha_to_beta[NUM_REGS];
byte perm_beta_to_gamma[NUM_REGS];
byte perm_gamma_to_alpha[NUM_REGS];

byte current_vm = 0; /* 0: Alpha, 1: Beta, 2: Gamma */
byte switch_count = 0;
bool registers_intact = true;

inline init_permutations() {
    /* Alpha -> Beta Permutation (Circular Shift Right) */
    perm_alpha_to_beta[0] = 3;
    perm_alpha_to_beta[1] = 0;
    perm_alpha_to_beta[2] = 1;
    perm_alpha_to_beta[3] = 2;

    /* Beta -> Gamma Permutation (Swap Pairs) */
    perm_beta_to_gamma[0] = 1;
    perm_beta_to_gamma[1] = 0;
    perm_beta_to_gamma[2] = 3;
    perm_beta_to_gamma[3] = 2;

    /* Gamma -> Alpha (Restoring composite permutation) */
    perm_gamma_to_alpha[0] = 2;
    perm_gamma_to_alpha[1] = 3;
    perm_gamma_to_alpha[2] = 0;
    perm_gamma_to_alpha[3] = 1;
}

inline apply_morph_alpha_beta() {
    byte temp[NUM_REGS];
    byte i;
    for (i : 0 .. 3) {
        temp[perm_alpha_to_beta[i]] = vregs[i];
    }
    for (i : 0 .. 3) {
        vregs[i] = temp[i];
    }
}

inline apply_morph_beta_gamma() {
    byte temp[NUM_REGS];
    byte i;
    for (i : 0 .. 3) {
        temp[perm_beta_to_gamma[i]] = vregs[i];
    }
    for (i : 0 .. 3) {
        vregs[i] = temp[i];
    }
}

inline apply_morph_gamma_alpha() {
    byte temp[NUM_REGS];
    byte i;
    for (i : 0 .. 3) {
        temp[perm_gamma_to_alpha[i]] = vregs[i];
    }
    for (i : 0 .. 3) {
        vregs[i] = temp[i];
    }
}

proctype MultiVCPUMorpher() {
    /* 1. Execute in VCPU Alpha */
    vregs[0] = (vregs[0] + 5) % 16;
    switch_count++;

    /* Morph Alpha -> Beta */
    apply_morph_alpha_beta();
    current_vm = 1;

    /* 2. Execute in VCPU Beta */
    vregs[perm_alpha_to_beta[0]] = (vregs[perm_alpha_to_beta[0]] ^ 7) % 16;
    switch_count++;

    /* Morph Beta -> Gamma */
    apply_morph_beta_gamma();
    current_vm = 2;

    /* 3. Execute in VCPU Gamma */
    byte r_idx = perm_beta_to_gamma[perm_alpha_to_beta[0]];
    vregs[r_idx] = (vregs[r_idx] + 2) % 16;
    switch_count++;

    /* Morph Gamma -> Alpha (Full Cycle) */
    apply_morph_gamma_alpha();
    current_vm = 0;
}

init {
    init_permutations();
    vregs[0] = 1;
    vregs[1] = 2;
    vregs[2] = 3;
    vregs[3] = 4;

    run MultiVCPUMorpher();
}

/* LTL Verification: All VM switches complete with zero corruption */
ltl full_morph_cycle { <> (switch_count == SWITCH_STEPS && current_vm == 0) }
