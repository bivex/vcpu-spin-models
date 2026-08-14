# Formal VCPU Models Resilient to VTIL Deobfuscation (SPIN / Promela)

Данный репозиторий содержит **19 формальных моделей Promela** для верификатора моделей **SPIN**, реализующих математически доказанные архитектурные паттерны VCPU, которые нейтрализуют символьный анализ, снятие SSA-форм, SMT/Z3 солверы и девиртуализацию в **VTIL**, **NoVmp** и динамических эмуляторах.

---

## 📚 Документация в папке `docs/`

* 📖 [**Микроархитектурная оптимизация VCPU под Intel Core i7**](./docs/i7_microarchitecture_optimization.md) — математические формулы задержек L1/L2/L3 MESI шины, взрыв сложности SMT-солвера $N! \cdot 2^{1.5N} \cdot N^3$, результаты исследования пространства состояний SPIN и обоснование оптимального числа $N=4 \dots 8$ VCPU.
* 🛡️ [**Анализ уязвимостей VTIL и механизмы защиты**](./docs/vtil_vulnerabilities_matrix.md) — детальный разбор исходного кода `VTIL-Core` (`stack_pinning_pass`, `directives.hpp`, `branch_correction_pass`, `dead_code_elimination_pass`, `symbolic_rewrite_pass`) и доказательства сбоев алгоритмов девиртуализации.

---

## 1. Архитектурная матрица Promela-моделей

| Файл модели | Архитектурный паттерн | Описание защиты |
| :--- | :--- | :--- |
| [**`models/i7_multicore_vcpu_optimizer.pml`**](./models/i7_multicore_vcpu_optimizer.pml) | **Intel Core i7 Hardware Emulator** | Параметрическая модель $N$-ядерного VCPU с учётом задержек кэшей L1/L2, MESI-инвалидации L3 и вычисления Парето-оптимума. |
| [**`models/quad_vmprotect.pml`**](./models/quad_vmprotect.pml) | **Quad-VCPU Distributed Ring Pipeline** | 4 изолированных гетерогенных процессора с уникальными перестановками, `OpcodeCryptor` и миграцией по почтовым ящикам. |
| [**`models/quad_vcpu_mesh.pml`**](./models/quad_vcpu_mesh.pml) | **4-VCPU Asynchronous Pipelined Mesh** | Конвейерная сеть из 4 асинхронных VCPU (Dispatcher $\to$ Crypto $\to$ Memory $\to$ ALU) без монолитного потока управления. |
| [**`models/vmprotect.pml`**](./models/vmprotect.pml) | **Comprehensive Polymorphic VCPU** | Полная модель VCPU: биективные перестановки регистров, относительный VSP со 128-байтной зоной, `VKey` и Threaded Code. |
| [`models/01_rolling_state.pml`](./models/01_rolling_state.pml) | **Rolling Cryptographic State** | Необратимый скользящий ключ $VKey_{n+1} = f(VKey_n, Op)$. Обратный taint-анализ упирается в неразрешимое уравнение. |
| [`models/02_coroutine_dual.pml`](./models/02_coroutine_dual.pml) | **Interleaved Co-routine Dual VCPU** | Асинхронный конвейер двух VCPU (Master $\leftrightarrow$ Slave) с барьерами синхронизации, ломающий DCE. |
| [`models/03_memory_aliasing.pml`](./models/03_memory_aliasing.pml) | **Non-Linear Polymorphic Memory Aliasing** | Нелинейное S-Box проецирование слотов стека, разрушающее `stack_pinning_pass`. |
| [`models/04_opaque_feedback.pml`](./models/04_opaque_feedback.pml) | **Diophantine Recurrence Invariant Predicates** | Диофантовы инварианты уравнения Пелля ($x^2 - 2y^2 = 1 \pmod{17}$) на аккумуляторе состояния. |
| [`models/05_heterogeneous_switching.pml`](./models/05_heterogeneous_switching.pml) | **Heterogeneous Multi-VCPU Morphing** | Динамическая смена архитектур $\text{VCPU}_\alpha \to \text{VCPU}_\beta \to \text{VCPU}_\gamma$ с перестановкой регистров. |
| [`models/06_self_mutating_bytecode.pml`](./models/06_self_mutating_bytecode.pml) | **Self-Modifying Rolling Bytecode** | Хэндлер на шаге $N$ переписывает байткод будущих шагов $N+1, N+2$. |
| [`models/07_homomorphic_risc.pml`](./models/07_homomorphic_risc.pml) | **Homomorphic 2-Instruction ISA** | Полная редукция системы команд к логическому базису Шеффера (NAND/NOR). |
| [`models/08_concurrency_race.pml`](./models/08_concurrency_race.pml) | **Multi-Threaded Concurrent Race Predicates** | Синхронизированные атомарные гонки (`LOCK XADD`), определяющие ветвления. |
| [`models/09_mba_polynomial.pml`](./models/09_mba_polynomial.pml) | **Dynamic Polynomial MBA Invariants** | Нелинейные нулевые полиномы над кольцом $\mathbb{Z}_{2^n}$, вызывающие тайм-аут SMT/Z3 солверов. |
| [`models/10_exception_dispatch.pml`](./models/10_exception_dispatch.pml) | **Trap & Exception-Driven Dispatch (SEH)** | Хэндлеры вызывают аппаратные исключения (`#DE`/`#UD`) вместо `jmp`/`call`, разрушая статический CFG. |
| [`models/11_ephemeral_jit.pml`](./models/11_ephemeral_jit.pml) | **Self-Synthesizing Ephemeral JIT** | Хэндлеры генерируются в RAM на 1 цикл и немедленно затираются нулями. |
| [`models/12_timing_entanglement.pml`](./models/12_timing_entanglement.pml) | **Hardware RDTSC Entanglement** | Ключ дешифрации привязан к аппаратному интервалу `RDTSC` $[\Delta_{min}, \Delta_{max}]$. |
| [`models/13_multipath_superposition.pml`](./models/13_multipath_superposition.pml) | **Speculative Multi-Path Superposition** | Одновременное исполнение Real и Decoy путей со схлопыванием суперпозиции ($2^N$ $\Phi$-узлов). |
| [`models/14_virtual_interrupts.pml`](./models/14_virtual_interrupts.pml) | **Preemptive Virtual APIC & Async Traps** | Внутренний таймер (`V_IRQ`) прерывает байткод на середине инструкции с вызовом `V_ISR` и `V_IRET`. |
| [`models/15_chaffing_ghost.pml`](./models/15_chaffing_ghost.pml) | **Chaffed & Entangled Control Flow** | Ghost-блоки, пишущие в живую память с последующей кольцевой компенсацией $\sum \Delta_{ghost} \equiv 0$. |

---

## 2. Структура репозитория

```text
vcpu-spin-models/
├── Makefile                # Быстрый запуск сборки и очистки
├── README.md               # Главный обзорный документ
├── run_verification.sh     # Скрипт автоматизированной SPIN-верификации
├── docs/                   # Подробная документация
│   ├── i7_microarchitecture_optimization.md # Исследование i7 и Парето-оптимума
│   └── vtil_vulnerabilities_matrix.md       # Анализ уязвимостей и сбоев VTIL
├── scripts/
│   └── find_optimal_vcpu_count.py           # Автоматический поиск оптимального N
└── models/                 # Каталог формальных моделей Promela
    ├── i7_multicore_vcpu_optimizer.pml
    ├── quad_vmprotect.pml
    ├── quad_vcpu_mesh.pml
    ├── vmprotect.pml
    └── 01..15_*.pml
```

---

## 3. Запуск верификации

### Запуск верификации всех 19 моделей:
```bash
make verify
# или
./run_verification.sh
```

### Запуск микроархитектурного оптимизатора i7:
```bash
python3 scripts/find_optimal_vcpu_count.py
```

### Очистка временных файлов:
```bash
make clean
```
