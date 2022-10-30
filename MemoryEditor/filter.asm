; FilterValue

INCLUDE         memeditor.inc

.data
; <<<<<<<<<<<<<<<<<<<< PROC Filter >>>>>>>>>>>>>>>>>>>>>>>>>
TYPE_QWORD      EQU         <8>
TYPE_DWORD      EQU         <4>
TYPE_WORD       EQU         <2>
TYPE_BYTE       EQU         <1>
bufDWORD        DWORD       ?
bufWORD         WORD        ?
bufBYTE         BYTE        ?

filterMsg       BYTE        "Use value %u to filter", 0ah, 0dh, 0
filterAnsMsg    BYTE        "Found address: %08X", 0ah, 0dh, 0
testMsg         BYTE        "val is %08X", 0ah, 0dh, 0
addrValMsg      BYTE        "%08X    %u", 0
msgBuffer       BYTE        24 DUP(0)
memMAX          DWORD       0BFFFFFFFH
memMIN          DWORD       0H
lastsearch      DWORD       10240 DUP(?)
totaladdr       DWORD       0
errorFilterMsg  BYTE        "Failed to filter", 0ah, 0dh, 0

; <<<<<<<<<<<<<<<<<<<< PROC Filter_2 >>>>>>>>>>>>>>>>>>>>>>>>>
filterTwoAnsMsg BYTE        "Found changed value's address: %08X", 0ah, 0dh, 0
findDoneMsg     BYTE        "Find Done!", 0ah, 0dh, 0

.code
; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
FilterValue PROC,
    filterVal:  DWORD,                 ; use this value to select addresses
    pid:        DWORD,                 ; which process
    hListBox:   DWORD,                 ; the handle of Listbox if GUI is used
    typeOfData: DWORD                  ; the type of the value to find
; Filter out addresses according to the value.
; No return value.
; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
    ; local variables used in iteration
    LOCAL       hMod[100]:      DWORD
    LOCAL       ansAddr:        DWORD
    LOCAL       cbNeeded:       DWORD
    LOCAL       mbi[28]:        DWORD
    LOCAL       nowAddr:        DWORD
    LOCAL       maxAddr:        DWORD
    LOCAL       ebxStore:       DWORD
    LOCAL       gui:            DWORD

    ; check whether GUI is used
    mov         gui, 0
    mov         eax, hListBox
    test        eax, eax
    jz          Begin
    mov         gui, 1

Begin:
    ; invoke      printf, OFFSET filterMsg, filterVal
    mov         totaladdr, 0
    invoke      OpenProcess, PROCESS_ALL_ACCESS, 0, pid ; open process according to pid
    test        eax, eax
    jz          filterProcReadFailed
    mov         ebx, eax
    mov         ebxStore, ebx
    invoke      EnumProcessModules, ebx, ADDR hMod, SIZEOF hMod, ADDR cbNeeded

    test        eax, eax
    jz          filterProcReadFailed
    ; invoke      ReadProcessMemory, ebx, DWORD PTR hMod[0], OFFSET buf, SIZEOF buf, ADDR numOfBytesRead
    ; test        eax, eax
    ; jz          filterProcReadFailed
    mov         edi, memMIN
    mov         nowAddr, edi
    mov         maxAddr, edi
    mov         eax, memMIN
    add         eax, memMAX
    mov         memMAX, eax
    ;mov         edi, memMIN

    mov         esi, OFFSET lastsearch

BLOCK:
    cmp         edi, memMAX
    ja          fail_RET
    mov         ebx, ebxStore
    invoke      VirtualQueryEx, ebx, edi, ADDR mbi, SIZEOF mbi
    test        eax, eax
    jz          fail_RET
    mov         edx, maxAddr
    add         edx, mbi[12]
    mov         maxAddr, edx

    mov         eax, mbi[16]
    cmp         eax, MEM_COMMIT
    je          PIECE
    mov         eax, mbi[12]
    add         edi, eax
    jmp         BLOCK

PIECE:
    cmp         edi, maxAddr
    je          BLOCK

    .IF          (typeOfData == TYPE_DWORD)
    invoke      ReadProcessMemory, ebx, edi, OFFSET bufDWORD, SIZEOF bufDWORD, 0
    test        eax, eax
    jz          accessFailed
    mov         eax, filterVal
    cmp         eax, bufDWORD
    je          SUCCESS_find
    add         edi, 4
    jmp         PIECE
    ret
    .ENDIF

    .IF          (typeOfData == TYPE_WORD)
    invoke      ReadProcessMemory, ebx, edi, OFFSET bufWORD, SIZEOF bufWORD, 0
    test        eax, eax
    jz          accessFailed
    mov         ax, WORD PTR filterVal
    cmp         ax, bufWORD
    je          SUCCESS_find
    add         edi, 2
    jmp         PIECE
    ret
    .ENDIF

    .IF          (typeOfData == TYPE_BYTE)
    invoke      ReadProcessMemory, ebx, edi, OFFSET bufBYTE, SIZEOF bufBYTE, 0
    test        eax, eax
    jz          accessFailed
    mov         al, BYTE PTR filterVal
    cmp         al, bufBYTE
    je          SUCCESS_find
    add         edi, 1
    jmp         PIECE
    ret
    .ENDIF

    ret
SUCCESS_find:
    mov         eax, totaladdr
    cmp         eax, LENGTH lastsearch
    jae         fail_RET
    mov         ansAddr, edi
    add         edi, typeOfData
    mov         eax, ansAddr
    mov         [esi], eax
    inc         totaladdr
    add         esi, TYPE lastsearch
    mov         eax, gui
    test        eax, eax
    jnz         updateListBox
    invoke      printf, OFFSET filterAnsMsg, ansAddr
    jmp         SUCCESS_end
updateListBox:
    mov         eax, totaladdr
    cmp         eax, 256
    ja          SUCCESS_end
    invoke      sprintf, OFFSET msgBuffer, OFFSET addrValMsg, ansAddr, filterVal
    invoke      SendMessage, hListBox, LB_ADDSTRING, 0, ADDR msgBuffer
    invoke      SendMessage, hListBox, LB_SETITEMDATA, eax, totaladdr
    invoke      UpdateWindow, hListBox
SUCCESS_end:
    jmp         PIECE
    ret
fail_RET:
    ret
accessFailed:
    add         edi, typeOfData
    jmp         PIECE
    ret
filterProcReadFailed:
    invoke      printf, OFFSET errorFilterMsg
    ret
FilterValue ENDP


; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
FilterValueTwo PROC,
    filterVal:  DWORD,                 ; use this value to select addresses
    pid:        DWORD,                 ; which process
    hListBox:   DWORD,                 ; the handle of Listbox if GUI is used
    typeOfData: DWORD                  ; the type of the value to find
; Select addresses according to the value from a given set.
; No return value.
; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
    LOCAL       tmpValDWORD:    DWORD
    LOCAL       tmpValWORD:     WORD
    LOCAL       tmpValBYTE:     BYTE
    LOCAL       handle:         DWORD
    LOCAL       count:          DWORD
    LOCAL       newCount:       DWORD
    LOCAL       gui:            DWORD

    ; check whether GUI is used
    mov         gui, 0
    mov         eax, hListBox
    test        eax, eax
    jz          Begin
    mov         gui, 1

Begin:
    invoke      OpenProcess, PROCESS_ALL_ACCESS, 0, pid                         ; open the process (according to pid)
    test        eax, eax
    jz          filterProcReadFailed

    mov         handle, eax
    mov         edi, OFFSET lastsearch
    mov         esi, edi
    mov         count, 0
    mov         newCount, 0
findLoop:
    mov         eax, count
    cmp         eax, totaladdr
    jae         findDone
    inc         count
    mov         ebx, [edi]
    
    .IF          (typeOfData == TYPE_DWORD)
    invoke      ReadProcessMemory, handle, ebx, ADDR tmpValDWORD, TYPE_DWORD, 0
    add         edi, TYPE lastsearch
    mov         eax, tmpValDWORD
    cmp         eax, filterVal
    je          findSuccess
    .ENDIF

    .IF          (typeOfData == TYPE_WORD)
    invoke      ReadProcessMemory, handle, ebx, ADDR tmpValWORD, TYPE_WORD, 0
    add         edi, TYPE lastsearch
    mov         ax, tmpValWORD
    cmp         ax, WORD PTR filterVal
    je          findSuccess
    .ENDIF

    .IF          (typeOfData == TYPE_BYTE)
    invoke      ReadProcessMemory, handle, ebx, ADDR tmpValBYTE, TYPE_BYTE, 0
    add         edi, TYPE lastsearch
    mov         al, tmpValBYTE
    cmp         al, BYTE PTR filterVal
    je          findSuccess
    .ENDIF

    jmp         findLoop
    ret
findSuccess:
    mov         [esi], ebx
    add         esi, TYPE lastsearch
    inc         newCount
    mov         eax, gui
    test        eax, eax
    jnz         updateListBox
    invoke      printf, OFFSET filterTwoAnsMsg, ebx
    jmp         SUCCESS_end
updateListBox:
    mov         eax, newCount
    cmp         eax, 256
    ja          SUCCESS_end
    invoke      sprintf, OFFSET msgBuffer, OFFSET addrValMsg, ebx, filterVal
    invoke      SendMessage, hListBox, LB_ADDSTRING, 0, ADDR msgBuffer
    invoke      SendMessage, hListBox, LB_SETITEMDATA, eax, newCount
    invoke      UpdateWindow, hListBox
SUCCESS_end:
    jmp         findLoop
    ret
findDone:
    ; invoke      printf, OFFSET findDoneMsg
    mov         eax, newCount
    mov         totaladdr, eax
    ret
filterProcReadFailed:
    invoke      printf, OFFSET errorFilterMsg
    ret
FilterValueTwo ENDP


; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
FetchAddr PROC, 
    index:      DWORD,                ; index in addresses
    address:    PTR DWORD,            ; the address of Address to be saved
; Get address according to the index.
; No return value.
; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
    mov         edi, address
    mov         eax, index
    dec         eax
    mov         ecx, TYPE lastsearch
    mul         ecx
    mov         ebx, lastsearch[eax]
    mov         [edi], ebx
    ret
FetchAddr ENDP

END
