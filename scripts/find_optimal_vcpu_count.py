#!/usr/bin/env python3
import subprocess
import os
import re
import math

DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODEL_I7 = os.path.join(DIR, "models", "i7_multicore_vcpu_optimizer.pml")
MODEL_I3 = os.path.join(DIR, "models", "i3_multicore_vcpu_optimizer.pml")
BUILD_DIR = os.path.join(DIR, ".spin_build")

os.makedirs(BUILD_DIR, exist_ok=True)

def evaluate_cpu_target(cpu_name, model_path, physical_cores, llc_contention_k, os_penalty_cycles):
    print("=" * 105)
    print(f"     MICROARCHITECTURE: {cpu_name.upper()} ({physical_cores} Physical Cores) - VCPU OPTIMIZATION")
    print("=" * 105)
    print(f"{'VCPU (N)':<10} | {'States':<8} | {'Transitions':<12} | {'Cycles':<12} | {'Solver Cost':<16} | {'Security %':<12} | {'Rating'}")
    print("-" * 105)
    
    results = []
    for n in [1, 2, 3, 4, 5, 6, 7, 8, 10, 12]:
        cmd_spin = f"spin -a -DN_VCPUS={n} {model_path}"
        subprocess.run(cmd_spin, shell=True, cwd=BUILD_DIR, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
        
        cmd_gcc = "gcc -O2 -w pan.c -o pan"
        subprocess.run(cmd_gcc, shell=True, cwd=BUILD_DIR, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
        
        cmd_pan = "./pan -a -N ring_completion"
        res = subprocess.run(cmd_pan, shell=True, cwd=BUILD_DIR, capture_output=True, text=True)
        output = res.stdout
        
        states_match = re.search(r"(\d+)\s+states,\s+stored", output)
        trans_match = re.search(r"(\d+)\s+transitions", output)
        
        states = int(states_match.group(1)) if states_match else 0
        transitions = int(trans_match.group(1)) if trans_match else 0
        
        # Microarchitectural Cost Calculation
        mesi_hops = max(0, n - 1)
        base_cycles = n * 4 + mesi_hops * 45
        contention_multiplier = 1.0 + llc_contention_k * (n ** 1.4)
        os_penalty = (n - physical_cores) * os_penalty_cycles if n > physical_cores else 0
        total_cycles = int(base_cycles * contention_multiplier + os_penalty)
        
        # Deobfuscation Complexity Metric
        perm_entropy = math.factorial(min(n, 12))
        smt_path_complexity = 2 ** (n * 1.5)
        raw_protection_score = perm_entropy * smt_path_complexity * (n ** 3)
        log_protection_score = math.log10(max(1.0, raw_protection_score))
        security_pct = min(100.0, (log_protection_score / 10.0) * 100.0)
        
        if security_pct < 35:
            rating = "[!] Vulnerable to VTIL"
        elif security_pct < 65 and n <= physical_cores:
            rating = "[*] SWEET SPOT (Optimal)"
        elif n <= physical_cores:
            rating = "[★] MAXIMUM SHIELD (Fortress)"
        else:
            rating = "[-] OS Thread Thrashing (Overkill)"
            
        data = {
            "n": n,
            "states": states,
            "transitions": transitions,
            "cycles": total_cycles,
            "prot_log10": log_protection_score,
            "security_pct": security_pct,
            "rating": rating
        }
        results.append(data)
        print(f"{data['n']:<10} | {data['states']:<8} | {data['transitions']:<12} | {data['cycles']:<12} | 10^{data['prot_log10']:<13.2f} | {data['security_pct']:<10.1f}% | {rating}")
        
    print("-" * 105)
    print()
    return results

# Run for Intel Core i3 (4 Cores, 12MB LLC, 1800-cycle context switch penalty)
evaluate_cpu_target("Intel Core i3", MODEL_I3, physical_cores=4, llc_contention_k=0.08, os_penalty_cycles=1800)

# Run for Intel Core i7 (8 Cores, 24-36MB LLC, 1500-cycle context switch penalty)
evaluate_cpu_target("Intel Core i7", MODEL_I7, physical_cores=8, llc_contention_k=0.04, os_penalty_cycles=1500)

subprocess.run(f"rm -rf {BUILD_DIR}", shell=True)
