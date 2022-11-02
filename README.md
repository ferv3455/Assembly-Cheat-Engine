# 运行时内存修改器

## 基本概况

- 内存修改器基本使用：类似于[Cheat Engine](https://www.cheatengine.org/)，可以看 https://www.youtube.com/watch?v=Mj1bnmWAadc&ab_channel=iwanMods （1分20秒到2分40秒）。主要流程包括选择进程，选择过滤器数据及类型，第一次搜索，调整过滤器进行后续筛选，最后根据地址修改内容。
- 内存修改器程序的开发围绕Cheat Engine进行，尽可能多地实现其中的主要功能。

## 操作方式

可以参考Cheat Engine的使用。先在界面中选择进程（控制台：输入进程的PID），进入查找修改的环节。先选择数据类型（字节数），然后使用自定义数值多次搜索地址，最后选择地址进行修改。

## 目前进度

- 基于GUI窗口、控制台程序实现了简单的内存修改程序。先列出所有的可选择进程，进行选择，后循环筛选地址，然后选择目标地址和新的数值进行修改。（*可以用简单测试CppDemo.exe、数据类型测试CppDemo3.exe来测试修改内存*）
- 目前先**基于控制台窗口程序版本**进行功能开发（程序入口位于`main.asm`中的`main`过程）：
  - **基本的地址搜索、内存修改功能（10/16完成，已移植到GUI）**
  - **上述功能Debug+支持更多的数据类型（10/30完成）**：在`Filter`与`FilterTwo`过程中加入了对`WORD`、`BYTE`类型的支持，传入参数增加了1个，调用时最后一个参数可以传入`TYPE_DWORD`(其实就是数值4)/`TYPE_WORD`/`TYPE_BYTE`，而`filterVal`可不做改变，在过程中用强制类型转换转为了对应的类型。

## 剩余任务&重点

- **Filter部分优化**：
  - 根据下面的过程定义添加Filter的参数，实现搜索地址步长选择、搜索条件选择（如大于小于）、搜索范围选择；
  - 部分常量添加在了`memeditor.inc`文件中。
  - COND_GT 1
  - COND_GE 2
  - COND_EQ 3
  - COND_LE 4
  - COND_LT 5
- 需求: 如用户未输入memMin及memMax,使用memMIN=0, memMAX=0xBFFFFFFF（
  memeditor.inc中定义的DEFAULT_MEMMIN/MAX）, 若用户输入的memMin为负数或memMax大于0xFFFFFFFF, 则直接报错。
- FilterValueTwo不需要添加参数，因为是在第一步得到的地址列表中搜索
```nasm
; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
FilterValue PROC,
    filterVal:  DWORD,                 ; use this value to select addresses
    valSize:    DWORD,                 ; the type of the value to find
    pid:        DWORD,                 ; which process
    hListBox:   DWORD,                 ; the handle of Listbox if GUI is used
    step:       DWORD,                 ; address increment in scanning
    condition:  DWORD,                 ; signify >, >=, =, <=, < (1 to 5, see memeditor.inc)
    memMin:     DWORD,                 ; beginning of scan range
    memMax:     DWORD                  ; end of scan range
; Filter out addresses according to the value.
; No return value.
; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
```
- **GUI部分优化**：调整布局（窗口、控件大小位置等），**模仿Cheat Engine的布局**
  - 整体调整：设置窗口图标（参考Win32窗口程序运行说明，已经创建了Resource.rc），优化按钮等控件的风格、布局、字体（设置字体可参考https://stackoverflow.com/a/224457）等；
  - 数据类型选择：添加设置一个新的`ComboBox`，使用`CBS_DROPDOWNLIST`的类型（下拉菜单），添加对应的标签“Value Type”。其中各项的名称为：Byte、2 Bytes (Word)、4 Bytes (DWord)、8 Bytes (QWord)，默认选择4 Bytes (DWord)；
  - 搜索模式选择（地址的步长）：同上添加`ComboBox`，标签为“Scan Type”。其中各项名称为：Fast Scan、1-Byte Alignment、2-Byte Alignment、4-Byte Alignment、8-Byte Alignment，默认选择Fast Scan；
  - 搜索条件选择：同上添加`ComboBox`，放在原来的搜索数值输入框的左侧。其中各项名称为：>、>=、=、<=、<，默认选择=；
  - 搜索范围选择：添加两个输入框，限定搜索的范围，标签为“Scan Range”。
- **全局事件逻辑**：收尾，完成整体事件循环
  - 选择新的数据类型、搜索模式、搜索范围必须在第一次搜索前完成，不允许接着进行next搜索；
  - 搜索条件可以在第一次搜索后重新选择；
  - 支持十六进制格式的输入（直接在原来的两个输入框中读取十六进制，或在同样的位置创建一个新的输入框）；
  - 完善所有的异常处理。
- 可选内容（参考Cheat Engine）：
  - `QWORD`的支持（或许可以将值存在edx、eax中，类似处理？）
  - 浮点类型的查找（可以判断一下工作量）；
  - 更多的测试（找一找可以修改的游戏，可用于展示）。

## 遇到过的问题&关键点

- **搜索地址重复或无法搜索到地址**：使用CppDemo2.exe测试时发现，搜索变量`b`、`c`的过程存在若干问题。其原因是MSVC编译器在编译C++程序时进行了优化，如添加变量之间的依赖关系等，使得变量不按照预期方式存储。
