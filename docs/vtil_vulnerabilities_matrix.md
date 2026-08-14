# Анализ уязвимостей VTIL и механизмы обхода

Данный документ содержит детальный анализ архитектурных ограничений промежуточного представления **VTIL (Virtual-machine Translation Intermediate Language)** на основе исходного кода [`VTIL-Core`](https://github.com/vtil-project/VTIL-Core) и показывает, почему разработанные Promela-модели VCPU гарантированно нейтрализуют попытки девиртуализации.

---

## 1. Провал свёртки стека (`stack_pinning_pass.cpp`)

* **Исходный код VTIL:** [`VTIL-Compiler/optimizer/stack_pinning_pass.cpp:61`](file:///Volumes/External/Code/VTIL-Core/VTIL-Compiler/optimizer/stack_pinning_pass.cpp#L61)
  ```cpp
  auto sp_curr = ctrace( { it, REG_SP } ) + it->sp_offset;
  auto sp_next = ctrace( { std::next( it ), REG_SP } );

  // Если разница строго сворачивается в константу:
  if ( auto shift_offset = ( sp_next - sp_curr ).get<intptr_t>() )
  {
      blk->shift_sp( *shift_offset, true, it );
      ...
  }
  ```
* **Механизм защиты:** [`models/03_memory_aliasing.pml`](../models/03_memory_aliasing.pml)
  * VTIL требует, чтобы относительное смещение стека между инструкциями было известно статически как константа `intptr_t`.
  * При использовании нелинейного S-Box проецирования слотов стека (`Slot = SBox[Offset]`) выражение `(sp_next - sp_curr).get<intptr_t>()` возвращает `std::nullopt`.
  * **Результат:** Проход `stack_pinning_pass` полностью пропускает блок, виртуальный стек $VSP$ не сворачивается в плоский физический стек.

---

## 2. Неспособность редуцировать нелинейные MBA-полиномы (`directives.hpp`)

* **Исходный код VTIL:** [`VTIL-SymEx/simplifier/directives.hpp:37-40`](file:///Volumes/External/Code/VTIL-Core/VTIL-SymEx/simplifier/directives.hpp#L37-L40)
  ```cpp
  // TODO: Arithmetic operators, */% etc.
  static const std::pair<instance, instance> universal_simplifiers[] = {
      { -(-A), A }, { ~(~A), A }, { A+0, A }, { A-A, 0 }, ...
  };
  ```
* **Механизм защиты:** [`models/09_mba_polynomial.pml`](../models/09_mba_polynomial.pml) и [`models/04_opaque_feedback.pml`](../models/04_opaque_feedback.pml)
  * Таблица `universal_simplifiers` в движке `VTIL-SymEx` содержит исключительно простые линейные булевы тождества. В VTIL полностью отсутствует модуль полиномиального деления и кольцевой алгебры над $\mathbb{Z}_{2^n}$.
  * При подаче тождеств вида $x^2 - y^2 - (x-y)(x+y) \equiv 0 \pmod{16}$ дерево выражений разрастается монотонно, пока не сработает исключение `join_depth_exception` (*"Reached the maximum join depth limit"*).
  * **Результат:** Срыв символьного упрощения, декомпилятор выдаёт километровые нечитаемые формулы вместо оригинальных инструкций.

---

## 3. Лавинообразный взрыв ложных ветвлений (`branch_correction_pass.cpp`)

* **Исходный код VTIL:** [`VTIL-Compiler/optimizer/branch_correction_pass.cpp:78-79`](file:///Volumes/External/Code/VTIL-Core/VTIL-Compiler/optimizer/branch_correction_pass.cpp#L78-L79)
  ```cpp
  bool plausible = false;
  for ( auto& branch : branch_info.destinations )
      plausible |= ( branch == target ).get<bool>().value_or( true );
  ```
* **Механизм защиты:** [`models/04_opaque_feedback.pml`](../models/04_opaque_feedback.pml) и [`models/12_timing_entanglement.pml`](../models/12_timing_entanglement.pml)
  * При анализе непрозрачных предикатов (на базе диофантовых уравнений Пелля или микроархитектурных таймингов) выражение `(branch == target).get<bool>()` не может быть разрешено статически и возвращает `std::nullopt`.
  * Из-за явного вызова `.value_or( true )` VTIL принимает решение, что **все фиктивные (decoy) ветвления являются истинными**.
  * **Результат:** Взрыв графа базовых блоков (CFG State Explosion) с генерацией сотен ложных путей исполнения.

---

## 4. Невозможность удаления фиктивного кода (`dead_code_elimination_pass.cpp`)

* **Исходный код VTIL:** [`VTIL-Compiler/optimizer/dead_code_elimination_pass.cpp:84-85`](file:///Volumes/External/Code/VTIL-Core/VTIL-Compiler/optimizer/dead_code_elimination_pass.cpp#L84-L85)
  ```cpp
  if ( !( ptr.flags & register_stack_pointer ) )
      used = true; // Запись в любую память, кроме известного стека, считается живой!
  ```
* **Механизм защиты:** [`models/15_chaffing_ghost.pml`](../models/15_chaffing_ghost.pml)
  * Алгоритм Dead Code Elimination (DCE) в VTIL удаляет инструкции только в том случае, если гарантировано, что адрес записи принадлежит стеку (`register_stack_pointer`).
  * Ghost-блоки, записывающие промежуточные значения в динамические структуры памяти с последующей кольцевой компенсацией $\sum \Delta_{ghost} \equiv 0$, принудительно помечаются как `used = true`.
  * **Результат:** VTIL не способен вычистить мусорные инструкции из графа.

---

## 5. Фрагментация графа при обработке исключений (`symbolic_rewrite_pass.cpp`)

* **Исходный код VTIL:** [`VTIL-Compiler/optimizer/symbolic_rewrite_pass.cpp:41-67`](file:///Volumes/External/Code/VTIL-Core/VTIL-Compiler/optimizer/symbolic_rewrite_pass.cpp#L41-L67)
  ```cpp
  vm.hooks.execute = [ & ] ( const instruction& ins ) {
      if ( ins.base->is_branching() ) return vm_exit_reason::unknown_instruction;
      if ( ins.is_volatile() ) return vm_exit_reason::unknown_instruction;
      if ( ins.sp_reset ) return vm_exit_reason::unknown_instruction;
      ...
  };
  ```
* **Механизм защиты:** [`models/10_exception_dispatch.pml`](../models/10_exception_dispatch.pml) и [`models/14_virtual_interrupts.pml`](../models/14_virtual_interrupts.pml)
  * Символьная виртуальная машина `symbolic_vm` прерывает трассировку при встрече любых нестандартных прерываний, системных ловушек или сбросов стека.
  * При использовании механизма SEH-диспетчеризации (аппаратные исключения `#DE`/`#UD`) вместо классических `jmp`/`call` лифтер останавливает анализ базового блока.
  * **Результат:** Граф потока управления распадается на изолированные инструкции-сироты (Orphan Blocks), которые невозможно связать воедино.
