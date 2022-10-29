# 运行时内存修改器

## 基本概况

- 内存修改器基本使用：可以看 https://www.youtube.com/watch?v=Mj1bnmWAadc&ab_channel=iwanMods （1 分 20 秒到 2 分 40 秒）。主要流程包括选择进程，选择过滤器数据及类型，第一次搜索，调整过滤器进行后续筛选，最后根据地址修改内容。
- 目前进度：基于GUI窗口、控制台实现了最简单的内存修改程序的主要框架。先列出所有的可选择进程，进行选择，后循环筛选地址（目前仅支持 4 字节的 DWORD，对应 `unsigned int`），然后选择目标地址和新的数值进行修改。（*可以用CppDemo.exe、CppDemo2.exe测试修改内存*）

## 操作方式

可以参考Cheat Engine的使用，先选择进程，后多次搜索地址，最后选择地址进行修改。

## 目前任务&问题

- **筛选地址进一步Debug、优化：**
  - 使用CppDemo2.exe测试时发现，搜索过程存在若干问题（目前不确定问题原因，可用Cheat Engine尝试一下）。具体情形为：
    - 要修改`c`，第一次筛选出多个地址，第二次筛选出两个地址A,B，第三次筛选后会显示两个B，结果也是错误的。
    - 要修改`b`，无法筛选到地址，且filter地址步长修改为1后仍然无法搜索到地址。
  - 是否有必要搜索到7FFFFFFF？7开头的地址存储的内容是什么？
- **Debug**
  - `b`的值用Cheat Engine也无法查到，不知道是什么原因。
  - 根据Cheat Engine的查找结果，`c`的地址查找正确，可能是修改时出现问题，正在debug中。
- **UI的美化**
  - 根据设置窗口图标（参考Win32窗口程序运行说明，已经创建了Resource.rc）；
  - 调整按钮等控件的风格、布局、字体（设置字体可参考https://stackoverflow.com/a/224457）等，清晰即可。
- **新：加入其它数据类型的支持**
  - Filter部分：
    - 修改了两个函数的参数，把`filterVal:DWORD`改成两个参数`valPtr:PTR BYTE`和`valSize:DWORD`，分别表示地址和大小（字节）；
    - 思路：可用`mov edi,valPtr`存储地址，之后就可以直接用`mov eax,[edi]`、`mov ax,[edi]`等获取不同长度的数值（需要设计具体逻辑）；
    - 搜索时使用的**步长先都使用4**（不过这样可能会有搜不到的情形，可先测试较长的类型），之后可通过快速搜索/完全搜索调节。
  - 实现
    - 在Filter与FilterTwo过程中加入了对WORD、BYTE类型的支持，传入参数增加了1个，调用时最后一个参数可以传入TYPE_DWORD(其实就是数值4)/TYPE_WORD/TYPE_BYTE，而filterVal可不做改变，在过程中用强制类型转换转为了对应的类型。
  - GUI部分：
    - 设置一个新的`ComboBox`，需要使用`CBS_DROPDOWNLIST`的类型（下拉菜单）；
    - 其中各项为：Byte、2 Bytes (Word)、4 Bytes (DWord)、8 Bytes (QWord)，默认选择4 Bytes (DWord)；
    - 可微调UI布局，放在Filtering Address一栏中，表示的是Value的类型。
  - 事件逻辑：
    - 在扫描时自动获取数据类型，以此来读取不同类型的数值，并将地址和类型作为参数传入；
    - 如果选择新的数据类型，则不允许再进行next搜索。
- 其他的待完善内容（参考Cheat Engine）：
  - 可以选择快速搜索和完全搜索（每次地址增量为1、2、4等）
  - 浮点类型的查找
  - 支持十六进制格式的输入
  - 支持设置搜索的地址范围
  - 支持选择筛选方式（等于、大于、小于）
