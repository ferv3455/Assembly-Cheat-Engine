; Memory editor: command line version

INCLUDE         memeditor.inc

; <<<<<<<<<<<<<<<<<<<< PROC Main >>>>>>>>>>>>>>>>>>>>>>>>>
.data
inputNumMsg     BYTE        "%u", 0
inputLongMsg    BYTE        "%llu", 0
inputHexMsg     BYTE        "%x", 0
pidPromptMsg    BYTE        "Enter the PID of the program: ", 0
filterPromptMsg BYTE        "Enter the value: ", 0
filterTwoMsg    BYTE        "Enter the value after changing:", 0
addrPromptMsg   BYTE        "Enter the address to be edited: ", 0
valPromptMsg    BYTE        "Enter the new value: ", 0
sizePromptMsg   BYTE        "Enter the new size of memory: ", 0
inputReminder   BYTE        "Operation (1-new, 2-next, 3-edit, 4-size (currently %d), 0-quit): ", 0
successMsg      BYTE        "Successfully rewrite memory.", 0ah, 0dh, 0
scanVal         ScanValue   <0, 4>
scanMode        ScanMode    <4, COND_EQ, DEFAULT_MEMMIN, DEFAULT_MEMMAX>

.data?
command         DWORD       ?
pid             DWORD       ?
writeAddr       DWORD       ?
writeData       QWORD       ?

; <<<<<<<<<<<<<<<<<<<< PROC InputValue >>>>>>>>>>>>>>>>>>>>>>>>>
.data
inputQwordMsg   BYTE        "%llu", 0
inputDwordMsg   BYTE        "%u", 0
inputWordMsg    BYTE        "%hu", 0
inputByteMsg    BYTE        "%hhu", 0

.code
main PROC
    ; List all processes (show all)
    invoke      EnumProc, 0

    ; Enter the process id (select a window)
    invoke      printf, OFFSET pidPromptMsg
    invoke      scanf, OFFSET inputNumMsg, OFFSET pid

MainLoop:
    ; Main loop
    invoke      printf, OFFSET inputReminder, scanVal.valSize
    invoke      scanf, OFFSET inputNumMsg, OFFSET command
    mov         eax, command
    cmp         eax, 1
    je          Filter
    cmp         eax, 2
    je          Filter2
    cmp         eax, 3
    je          Edit
    cmp         eax, 4
    je          ChangeSize
    jmp         Quit

Filter:
    ; 1: Filter out the address (NEW)
    ; Input a value
    invoke      printf, OFFSET filterPromptMsg
    invoke      InputValue, OFFSET scanVal.value, scanVal.valSize

    ; Filter, print out and save certain addresses
    invoke      FilterValue, pid, 0, scanVal, scanMode
    jmp         MainLoop

Filter2:
    ; 2: Filter out the address (NEXT)
    ; Input a value
    invoke      printf, OFFSET filterTwoMsg
    invoke      InputValue, OFFSET scanVal.value, scanVal.valSize

    ; Filter, print out and save certain addresses
    invoke      FilterValueTwo, pid, 0, scanVal, scanMode.condition
    jmp         MainLoop

Edit:
    ; 3: Edit a given address
    ; Choose the address to modify
    invoke      printf, OFFSET addrPromptMsg
    invoke      scanf, OFFSET inputHexMsg, OFFSET writeAddr

    ; Enter the new value
    invoke      printf, OFFSET valPromptMsg
    invoke      InputValue, OFFSET writeData, scanVal.valSize

    ; Confirm
    invoke      Modify, pid, writeAddr, writeData, scanVal.valSize
    invoke      printf, OFFSET successMsg
    jmp         MainLoop

ChangeSize:
    ; 4: Change the size of modified memory
    ; Input new size
    invoke      printf, OFFSET sizePromptMsg
    invoke      scanf, OFFSET inputNumMsg, OFFSET scanVal.valSize
    jmp         MainLoop

Quit:
    ; 0: Terminate
    invoke      ExitProcess, 0
main ENDP


; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
InputValue PROC,
    dest:       PTR QWORD,      ; Destination address (always in the first byte)
    vSize:      DWORD           ; Size of data
; Use scanf to get different type of inputs. Save them in the given address.
; No return value.
; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
    .IF         vSize == TYPE_QWORD
        invoke      scanf, OFFSET inputQwordMsg, dest
    .ELSEIF     vSize == TYPE_DWORD
        invoke      scanf, OFFSET inputDwordMsg, dest
    .ELSEIF     vSize == TYPE_WORD
        invoke      scanf, OFFSET inputWordMsg, dest
    .ELSEIF     vSize == TYPE_BYTE
        invoke      scanf, OFFSET inputByteMsg, dest
    .ENDIF
    ret
InputValue ENDP

END
; END             main
