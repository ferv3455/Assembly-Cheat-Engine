# 运行时内存修改器

## 主要内容

- 内存修改器基本使用：可以看 https://www.youtube.com/watch?v=Mj1bnmWAadc&ab_channel=iwanMods （1 分 20 秒到 2 分 40 秒）。主要流程包括选择进程，选择过滤器数据及类型，第一次搜索，调整过滤器进行后续筛选，最后根据地址修改内容。
- 目前进度：基于控制台实现了最简单的内存修改程序的主要框架。（Main 过程）先列出所有的可选择进程，进行选择，后循环筛选地址（目前仅支持 4 字节的 DWORD，对应 int），然后输入地址和新的数值进行修改。（*可以用CppDemo.exe测试修改内存*）
- 现在的主要任务：
    - 筛选地址部分的实现（如何储存地址：地址数组/flag 数组/位向量）
    - 加入其它数据类型的支持（需要修改整体逻辑、参数）
    - 基本的 UI 界面（目前没有过高要求）

## 任务（预计截止到 10/14）

- **筛选地址**（判断内存大小？可以动态分配地址数组来储存，11.3，或用位向量保存全部 32 位地址，512MB）
- **基本的 UI**（现阶段先独立实现一个空白界面，可以在界面上输入一个数字，点一下鼠标，然后在界面上显示出来。涉及事件循环和事件捕捉，11.2）
- **其他类型、整合**（涉及到变量、指针和整体逻辑的整合调整）