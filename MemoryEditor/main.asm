; Memory editor: command line version

INCLUDE         memeditor.inc

.data
inputNumMsg     BYTE        "%d", 0
inputHexMsg     BYTE        "%x", 0
pidPromptMsg    BYTE        "Enter the PID of the program: ", 0
filterPromptMsg BYTE        "Enter the value: ", 0
addrPromptMsg   BYTE        "Enter the address to be edited: ", 0
valPromptMsg    BYTE        "Enter the new value: ", 0
command         DWORD       ?

pid             DWORD       ?
filterVal       DWORD       ?
writeAddr       DWORD       ?
writeData       DWORD       ?

.code
main PROC
    ; List all processes (show all)
    invoke      EnumProc

    ; Enter the process id (select a window)
    invoke      printf, OFFSET pidPromptMsg
    invoke      scanf, OFFSET inputNumMsg, OFFSET pid

MainLoop:
    ; Main loop
    invoke      scanf, OFFSET inputNumMsg, OFFSET command
    mov         eax, command
    test        eax, eax
    jz          Quit
    cmp         eax, 1
    je          Filter
    jmp         Edit

Filter:
    ; 1: Filter out the address
    ; Input a value
    invoke      printf, OFFSET filterPromptMsg
    invoke      scanf, OFFSET inputNumMsg, OFFSET filterVal

    ; Filter, print out and save certain addresses
    invoke      FilterValue, filterVal
    jmp         MainLoop

Edit:
    ; 2: Edit a given address
    ; Choose the address to modify
    invoke      printf, OFFSET addrPromptMsg
    invoke      scanf, OFFSET inputHexMsg, OFFSET writeAddr

    ; Enter the new value
    invoke      printf, OFFSET valPromptMsg
    invoke      scanf, OFFSET inputNumMsg, OFFSET writeData

    ; Confirm
    invoke      Modify, pid, writeAddr, writeData
    jmp         MainLoop

Quit:
    ; 0: Terminate
    invoke      ExitProcess, 0
main ENDP

END main
