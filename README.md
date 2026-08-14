# Formal VCPU Models Resilient to VTIL Deobfuscation (SPIN / Promela)

Данный репозиторий содержит **17 формальных моделей Promela** для верификатора моделей **SPIN**, реализующих математически доказанные архитектурные паттерны VCPU, которые нейтрализуют символьный анализ, снятие SSA-форм, SMT/Z3 солверы и девиртуализацию в **VTIL**, **NoVmp** и динамических эмуляторах.

---

## 1. Архитектурная матрица алгоритмов и механизмов защиты

| Файл модели | Архитектурный паттерн | Почему ломается VTIL / SMT-анализ |
| :--- | :--- | :--- |
| [**`models/quad_vcpu_mesh.pml`**](./models/quad_vcpu_mesh.pml) | **4-VCPU Asynchronous Pipelined Mesh** | Конвейерная сеть из 4 асинхронных VCPU (Dispatcher $\to$ Crypto $\to$ Memory $\to$ ALU). У программы отсутствует единый поток и статический CFG. |
| [**`models/vmprotect.pml`**](./models/vmprotect.pml) | **Comprehensive Polymorphic VCPU Pipeline** | Полная модель VCPU: биективные перестановки регистров, относительный VSP со 128-байтной зоной, скользящий крипто-поток, флаги VFLAGS и прямое ветвление Threaded Code. |
| [`models/01_rolling_state.pml`](./models/01_rolling_state.pml) | **Rolling Cryptographic State** | Необратимый скользящий ключ $VKey_{n+1} = f(VKey_n, Op)$. Обратный taint-анализ и вычисление адресов упираются в неразрешимое рекуррентное уравнение состояния (Path Explosion). |
| [`models/02_coroutine_dual.pml`](./models/02_coroutine_dual.pml) | **Interleaved Co-routine Dual VCPU** | Асинхронный конвейер двух VCPU (Master $\leftrightarrow$ Slave) с барьерами синхронизации. VTIL не умеет строить межпоточный граф и ломает Dead Code Elimination. |
| [`models/03_memory_aliasing.pml`](./models/03_memory_aliasing.pml) | **Non-Linear Polymorphic Memory Aliasing** | Нелинейное S-Box проецирование слотов стека. Разрушает предположение `Pointer = VSP + Offset` в `stack_pinning_pass`. Свёртка стека блокируется. |
| [`models/04_opaque_feedback.pml`](./models/04_opaque_feedback.pml) | **Diophantine Recurrence Invariant Predicates** | Диофантовы инварианты уравнения Пелля ($x^2 - 2y^2 = 1 \pmod{17}$) на аккумуляторе состояния. Вычисление переходов требует решения нелинейных диофантовых уравнений по всей трассе. |
| [`models/05_heterogeneous_switching.pml`](./models/05_heterogeneous_switching.pml) | **Heterogeneous Multi-VCPU & Context Morphing** | Динамическая смена архитектур $\text{VCPU}_\alpha \to \text{VCPU}_\beta \to \text{VCPU}_\gamma$ с перестановкой регистровых слотов на лету. Лифтер теряет соответствие регистров. |
| [`models/06_self_mutating_bytecode.pml`](./models/06_self_mutating_bytecode.pml) | **Self-Modifying Rolling Bytecode** | Хэндлер на шаге $N$ переписывает байткод будущих шагов $N+1, N+2$. Статический дизассемблер строит невалидный IR, расходящийся с рантаймом. |
| [`models/07_homomorphic_risc.pml`](./models/07_homomorphic_risc.pml) | **Homomorphic 2-Instruction Complete ISA** | Полная редукция системы команд к логическому базису Шеффера (NAND/NOR). Превращает простые операции в каскады из 25+ узлов, превышая лимиты глубины упрощения VTIL. |
| [`models/08_concurrency_race.pml`](./models/08_concurrency_race.pml) | **Multi-Threaded Concurrent Race Predicates** | Синхронизированные атомарные гонки (`LOCK XADD`), определяющие ветвления. Не сворачиваются в детерминированный однопоточный IR. |
| [`models/09_mba_polynomial.pml`](./models/09_mba_polynomial.pml) | **Dynamic Non-Linear Polynomial MBA Invariants** | Нелинейные нулевые полиномы над кольцом $\mathbb{Z}_{2^n}$. Дерево абстрактного синтаксиса (AST) разрастается экспоненциально, приводя к тайм-ауту SMT/Z3 солверов. |
| [`models/10_exception_dispatch.pml`](./models/10_exception_dispatch.pml) | **Trap & Hardware Exception-Driven Dispatch (SEH)** | Хэндлеры не содержат инструкций ветвления (`jmp`/`call`), а вызывают аппаратные исключения (`#DE`/`#UD`). Поток восстанавливается через фильтр SEH, разрушая статический CFG. |
| [`models/11_ephemeral_jit.pml`](./models/11_ephemeral_jit.pml) | **Self-Synthesizing Ephemeral JIT Trampolines** | Хэндлеры генерируются JIT-синтезатором в RAM на 1 цикл и немедленно стираются эпилогом. В бинарнике полностью отсутствует статический пул хэндлеров. |
| [`models/12_timing_entanglement.pml`](./models/12_timing_entanglement.pml) | **Hardware Cycle Counter (RDTSC) Entanglement** | Ключ дешифрации привязан к аппаратному интервалу `RDTSC` $[\Delta_{min}, \Delta_{max}]$. Пошаговая отладка или символьная эмуляция уводят выполнение в ложный тар-пит. |
| [`models/13_multipath_superposition.pml`](./models/13_multipath_superposition.pml) | **Speculative Multi-Path Superposition** | Одновременное безусловное исполнение Real и Decoy путей с алгебраическим схлопыванием суперпозиции. Лифтер генерирует $2^N$ квадратичных $\Phi$-узлов. |
| [`models/14_virtual_interrupts.pml`](./models/14_virtual_interrupts.pml) | **Preemptive Virtual APIC & Async Trap Pipeline** | Внутренний таймер (`V_IRQ`) прерывает байткод на середине инструкции с вызовом `V_ISR` и `V_IRET`, разрушая линейную атомарность блоков. |
| [`models/15_chaffing_ghost.pml`](./models/15_chaffing_ghost.pml) | **Chaffed & Entangled Control Flow (Ghost Blocks)** | Каждая инструкция окружена Ghost-блоками, пишущими в живую память с последующей нулевой кольцевой компенсацией $\sum \Delta_{ghost} \equiv 0 \pmod N$. Dead Code Elimination бессилен. |

---

## 2. Структура репозитория

```text
vcpu-spin-models/
├── Makefile                # Быстрый запуск сборки и очистки
├── README.md               # Полное руководство и спецификации моделей
├── run_verification.sh     # Скрипт автоматизированной SPIN-верификации
└── models/                 # Каталог формальных моделей Promela
    ├── quad_vcpu_mesh.pml  # Модель 4-VCPU асинхронной распределенной сети
    ├── vmprotect.pml       # Комплексная модель VCPU
    ├── 01_rolling_state.pml
    ├── 02_coroutine_dual.pml
    ├── 03_memory_aliasing.pml
    ├── 04_opaque_feedback.pml
    ├── 05_heterogeneous_switching.pml
    ├── 06_self_mutating_bytecode.pml
    ├── 07_homomorphic_risc.pml
    ├── 08_concurrency_race.pml
    ├── 09_mba_polynomial.pml
    ├── 10_exception_dispatch.pml
    ├── 11_ephemeral_jit.pml
    ├── 12_timing_entanglement.pml
    ├── 13_multipath_superposition.pml
    ├── 14_virtual_interrupts.pml
    └── 15_chaffing_ghost.pml
```

---

## 3. Запуск верификации

Для автоматической проверки всех 17 моделей:

```bash
make verify
# или
./run_verification.sh
```

Для очистки временных файлов:
```bash
make clean
```
