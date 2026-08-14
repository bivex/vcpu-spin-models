/*
 * Spin/Promela Model: vcpu_memory_aliasing.pml
 *
 * Architecture: Non-Linear Polymorphic Memory Aliasing VCPU.
 *
 * Threat Model: VTIL Memory Simplification Pass (stack_pinning_pass, memory_disambiguation).
 *
 * Why VTIL Fails:
 * VTIL's memory disambiguation engine assumes memory accesses can be reduced to
 * linear affine forms: Pointer = Base + Offset.
 * When the VCPU introduces non-linear indirection tables (Secret S-Boxes & Dynamic Stack Pivots)
 * where the actual physical address of virtual stack slots is:
 *    Addr(VSP_slot) = HeapBase + SBox[(VSP ^ Key) & 3] * 4 + Offset
 * VTIL cannot prove that two memory references are distinct, resulting in symbolic
 * memory aliasing explosions where no stores can be folded.
 *
 * Verification Objectives:
 * - Determinism and bijective mapping of non-linear slot indices (no collisions).
 * - Correct preservation of stack values across aliased operations.
 */

#define SLOTS 4
#define MEM_SIZE 16

byte sbox[SLOTS];
byte phys_memory[MEM_SIZE];
byte vsp_logical = 0;
byte test_key = 3;
byte written_count = 0;

inline init_sbox() {
    /* Bijective non-linear permutation of 4 slots */
    sbox[0] = 2;
    sbox[1] = 0;
    sbox[2] = 3;
    sbox[3] = 1;
}

inline get_physical_index(logical_idx, key, out_phys) {
    byte mapped_slot = sbox[(logical_idx ^ key) % SLOTS];
    out_phys = (mapped_slot * 4) % MEM_SIZE;
}

proctype MemoryAliasedVCPU() {
    byte phys_addr = 0;
    byte read_back_val = 0;
    byte i = 0;

    /* Write 4 values using non-linear polymorphic aliasing */
    for (i : 0 .. 3) {
        get_physical_index(i, test_key, phys_addr);
        phys_memory[phys_addr] = (i + 10);
        written_count++;
    }

    /* Verify that every logical slot reads back its exact written value */
    for (i : 0 .. 3) {
        get_physical_index(i, test_key, phys_addr);
        read_back_val = phys_memory[phys_addr];
        assert(read_back_val == (i + 10));
    }
}

init {
    init_sbox();
    run MemoryAliasedVCPU();
}

/* LTL Verification: All slots written and verified with zero collisions */
ltl no_alias_collision { <> (written_count == SLOTS) }
