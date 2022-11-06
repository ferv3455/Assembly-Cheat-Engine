; FilterValue

INCLUDE         memeditor.inc

.data
; <<<<<<<<<<<<<<<<<<<< PROC Filter >>>>>>>>>>>>>>>>>>>>>>>>>
bufQWORD        QWORD       ?
; bufWORD         WORD        ?
; bufBYTE         BYTE        ?

filterMsg       BYTE        "Use value %lu to filter", 0ah, 0dh, 0
filterAnsMsg    BYTE        "Found address: %08X", 0ah, 0dh, 0
testMsg         BYTE        "val is %08X", 0ah, 0dh, 0
msgBuffer       BYTE        64 DUP(0)
lastsearch      DWORD       262144 DUP(?)
totaladdr       DWORD       0
errorFilterMsg  BYTE        "Failed to filter", 0ah, 0dh, 0
newLineMsg      BYTE        0ah, 0dh, 0

; <<<<<<<<<<<<<<<<<<<< PROC Filter_2 >>>>>>>>>>>>>>>>>>>>>>>>>
filterTwoAnsMsg BYTE        "Found changed value's address: %08X", 0ah, 0dh, 0
findDoneMsg     BYTE        "Find Done!", 0ah, 0dh, 0

; <<<<<<<<<<<<<<<<<<<< PROC MakeMessage >>>>>>>>>>>>>>>>>>>>>>>>>
addrQwordMsg     BYTE        "%08X            %llu", 0
addrDwordMsg     BYTE        "%08X            %u", 0
addrWordMsg      BYTE        "%08X            %hu", 0
addrByteMsg      BYTE        "%08X            %hhu", 0
addrFloatMsg     BYTE		 "%08X            %f", 0
addrDoubleMsg    BYTE		 "%08X            %lf", 0

float2Msg        BYTE        "%.2lf", 0

.code

; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
FilterValue PROC, 
    pid:        DWORD,                 ; which process
    hListBox:   DWORD,                 ; the handle of Listbox if GUI is used
    scanVal:    ScanValue,             ; use this value to select addresses
    scanMode:   ScanMode               ; specification in scanning
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
    ; invoke      printf, OFFSET filterMsg, scanVal.value
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
    mov         edi, scanMode.memMin
    mov         nowAddr, edi
    mov         maxAddr, edi
    mov         eax, scanMode.memMin
    add         eax, scanMode.memMax
    mov         scanMode.memMax, eax
    ; mov         edi, scanMode.memMin

    mov         esi, OFFSET lastsearch

BLOCK:
    cmp         edi, scanMode.memMax
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

    .IF         scanVal.valSize == TYPE_QWORD
        invoke      ReadProcessMemory, ebx, edi, OFFSET bufQWORD, TYPE_QWORD, 0
        test        eax, eax
        jz          accessFailed
        lea         edx, bufQWORD
        mov         eax, [edx + 4]      ; higher
        lea         edx, scanVal.value
        mov         ecx, [edx + 4]
        mov         edx, scanMode.condition
        .IF         edx == COND_GT
            cmp         eax, ecx
            ja          SUCCESS_find
            jb          FAIL_compare
            mov         eax, DWORD PTR bufQWORD     ; lower
            mov         ecx, DWORD PTR scanVal.value
            cmp         eax, ecx
            ja          SUCCESS_find
        .ELSEIF     edx == COND_LT
            cmp         eax, ecx
            jb          SUCCESS_find
            ja          FAIL_compare
            mov         eax, DWORD PTR bufQWORD     ; lower
            mov         ecx, DWORD PTR scanVal.value
            cmp         eax, ecx
            jb          SUCCESS_find
        .ELSEIF     edx == COND_EQ
            cmp         eax, ecx
            jne         FAIL_compare
            mov         eax, DWORD PTR bufQWORD     ; lower
            mov         ecx, DWORD PTR scanVal.value
            cmp         eax, ecx
            je          SUCCESS_find
        .ELSEIF     edx == COND_GE
            cmp         eax, ecx
            ja          SUCCESS_find
            jb          FAIL_compare
            mov         eax, DWORD PTR bufQWORD     ; lower
            mov         ecx, DWORD PTR scanVal.value
            cmp         eax, ecx
            jae         SUCCESS_find
        .ELSEIF     edx == COND_LE
            cmp         eax, ecx
            jb          SUCCESS_find
            ja          FAIL_compare
            mov         eax, DWORD PTR bufQWORD     ; lower
            mov         ecx, DWORD PTR scanVal.value
            cmp         eax, ecx
            jbe         SUCCESS_find
        .ENDIF
    FAIL_compare:
        add         edi, scanMode.step
        jmp         PIECE


    .ELSEIF     scanVal.valSize == TYPE_DWORD
        invoke      ReadProcessMemory, ebx, edi, OFFSET bufQWORD, TYPE_DWORD, 0
        test        eax, eax
        jz          accessFailed
        mov         eax, DWORD PTR bufQWORD
        mov         edx, scanMode.condition
        .IF         edx == COND_GT
            cmp         eax, DWORD PTR scanVal.value
            ja          SUCCESS_find
        .ELSEIF     edx == COND_LT
            cmp         eax, DWORD PTR scanVal.value
            jb          SUCCESS_find
        .ELSEIF     edx == COND_EQ
            cmp         eax, DWORD PTR scanVal.value
            je          SUCCESS_find
        .ELSEIF     edx == COND_GE
            cmp         eax, DWORD PTR scanVal.value
            jae         SUCCESS_find
        .ELSEIF     edx == COND_LE
            cmp         eax, DWORD PTR scanVal.value
            jbe         SUCCESS_find
        .ENDIF
        add         edi, scanMode.step
        jmp         PIECE

    .ELSEIF     scanVal.valSize == TYPE_WORD
        invoke      ReadProcessMemory, ebx, edi, OFFSET bufQWORD, TYPE_WORD, 0
        test        eax, eax
        jz          accessFailed
        mov         ax, WORD PTR bufQWORD
        mov         edx, scanMode.condition
        .IF         edx == COND_GT
            cmp         ax, WORD PTR scanVal.value
            ja          SUCCESS_find
        .ELSEIF     edx == COND_LT
            cmp         ax, WORD PTR scanVal.value
            jb          SUCCESS_find
        .ELSEIF     edx == COND_EQ
            cmp         ax, WORD PTR scanVal.value
            je          SUCCESS_find
        .ELSEIF     edx == COND_GE
            cmp         ax, WORD PTR scanVal.value
            jae         SUCCESS_find
        .ELSEIF     edx == COND_LE
            cmp         ax, WORD PTR scanVal.value
            jbe         SUCCESS_find
        .ENDIF
        add         edi, scanMode.step
        jmp         PIECE

    .ELSEIF     scanVal.valSize == TYPE_BYTE
        invoke      ReadProcessMemory, ebx, edi, OFFSET bufQWORD, TYPE_BYTE, 0
        test        eax, eax
        jz          accessFailed
        mov         al, BYTE PTR bufQWORD
        mov         edx, scanMode.condition
        .IF         edx == COND_GT
            cmp         al, BYTE PTR scanVal.value
            ja          SUCCESS_find
        .ELSEIF     edx == COND_LT
            cmp         al, BYTE PTR scanVal.value
            jb          SUCCESS_find
        .ELSEIF     edx == COND_EQ
            cmp         al, BYTE PTR scanVal.value
            je          SUCCESS_find
        .ELSEIF     edx == COND_GE
            cmp         al, BYTE PTR scanVal.value
            jae         SUCCESS_find
        .ELSEIF     edx == COND_LE
            cmp         al, BYTE PTR scanVal.value
            jbe         SUCCESS_find
        .ENDIF
        add         edi, scanMode.step
        jmp         PIECE

    .ELSEIF      scanVal.valSize == TYPE_REAL4
        invoke      ReadProcessMemory, ebx, edi, OFFSET bufQWORD, 4, 0
        test        eax, eax
        jz          accessFailed
        finit
        fld         REAL4 PTR scanVal.value
        fld         REAL4 PTR bufQWORD
        mov         edx, scanMode.condition
        .IF         edx == COND_GT
            fcomi       ST(0), ST(1)
            ja          SUCCESS_find
        .ELSEIF     edx == COND_LT
            fcomi       ST(0), ST(1)
            jb          SUCCESS_find
        .ELSEIF     edx == COND_EQ
            fcomi       ST(0), ST(1)
            je          SUCCESS_find
        .ELSEIF     edx == COND_GE
            fcomi       ST(0), ST(1)
            jae         SUCCESS_find
        .ELSEIF     edx == COND_LE
            fcomi       ST(0), ST(1)
            jbe         SUCCESS_find
        .ENDIF
        add         edi, scanMode.step
        jmp         PIECE

    .ELSEIF      scanVal.valSize == TYPE_REAL8
        invoke      ReadProcessMemory, ebx, edi, OFFSET bufQWORD, 8, 0
        test        eax, eax
        jz          accessFailed
        finit
        
        fld         REAL8 PTR scanVal.value
        fld         REAL8 PTR bufQWORD
        mov         edx, scanMode.condition
        .IF         edx == COND_GT
            fcomi       ST(0), ST(1)
            ja          SUCCESS_find
        .ELSEIF     edx == COND_LT
            fcomi       ST(0), ST(1)
            jb          SUCCESS_find
        .ELSEIF     edx == COND_EQ
            fcomi       ST(0), ST(1)
            je          SUCCESS_find
        .ELSEIF     edx == COND_GE
            fcomi       ST(0), ST(1)
            jae         SUCCESS_find
        .ELSEIF     edx == COND_LE
            fcomi       ST(0), ST(1)
            jbe         SUCCESS_find
        .ENDIF
        add         edi, scanMode.step
        jmp         PIECE

    .ENDIF
    ret

SUCCESS_find:
    call        ShowFPUStack
    mov         eax, totaladdr
    cmp         eax, LENGTH lastsearch
    jae         fail_RET
    mov         ansAddr, edi
    add         edi, scanMode.step
    mov         eax, ansAddr
    mov         [esi], eax
    inc         totaladdr
    add         esi, TYPE lastsearch
    invoke      MakeMessage, OFFSET msgBuffer, ansAddr, bufQWORD, scanVal.valSize
    mov         eax, gui
    test        eax, eax
    jnz         updateListBox
    invoke      printf, OFFSET msgBuffer
    invoke      printf, OFFSET newLineMsg
    jmp         SUCCESS_end
updateListBox:
    mov         eax, totaladdr
    cmp         eax, 1024
    ja          SUCCESS_end
    invoke      SendMessage, hListBox, LB_ADDSTRING, 0, ADDR msgBuffer
    invoke      SendMessage, hListBox, LB_SETITEMDATA, eax, totaladdr
    invoke      UpdateWindow, hListBox
SUCCESS_end:
    jmp         PIECE
    ret
fail_RET:
    ret
accessFailed:
    add         edi, scanMode.step
    jmp         PIECE
    ret
filterProcReadFailed:
    invoke      printf, OFFSET errorFilterMsg
    ret
FilterValue ENDP


; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
FilterValueTwo PROC,
    pid:        DWORD,                 ; which process
    hListBox:   DWORD,                 ; the handle of Listbox if GUI is used
    scanVal:    ScanValue,             ; use this value to select addresses
    condition:  DWORD                  ; signify >, >=, =, <=, <
; Select addresses according to the value from a given set.
; No return value.
; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
    ; LOCAL       tmpValDWORD:    DWORD
    ; LOCAL       tmpValWORD:     WORD
    ; LOCAL       tmpValBYTE:     BYTE
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
    
    .IF          scanVal.valSize == TYPE_DWORD
        invoke      ReadProcessMemory, handle, ebx, OFFSET bufQWORD, TYPE_DWORD, 0
        add         edi, TYPE lastsearch
        lea         edx, bufQWORD
        mov         eax, [edx + 4]      ; higher
        lea         edx, scanVal.value
        mov         ecx, [edx + 4]
        mov         edx, condition
        .IF         edx == COND_GT
            cmp         eax, ecx
            ja          findSuccess
            jb          FAIL_compare
            mov         eax, DWORD PTR bufQWORD     ; lower
            mov         ecx, DWORD PTR scanVal.value
            cmp         eax, ecx
            ja          findSuccess
        .ELSEIF     edx == COND_LT
            cmp         eax, ecx
            jb          findSuccess
            ja          FAIL_compare
            mov         eax, DWORD PTR bufQWORD     ; lower
            mov         ecx, DWORD PTR scanVal.value
            cmp         eax, ecx
            jb          findSuccess
        .ELSEIF     edx == COND_EQ
            cmp         eax, ecx
            jne         FAIL_compare
            mov         eax, DWORD PTR bufQWORD     ; lower
            mov         ecx, DWORD PTR scanVal.value
            cmp         eax, ecx
            je          findSuccess
        .ELSEIF     edx == COND_GE
            cmp         eax, ecx
            ja          findSuccess
            jb          FAIL_compare
            mov         eax, DWORD PTR bufQWORD     ; lower
            mov         ecx, DWORD PTR scanVal.value
            cmp         eax, ecx
            jae         findSuccess
        .ELSEIF     edx == COND_LE
            cmp         eax, ecx
            jb          findSuccess
            ja          FAIL_compare
            mov         eax, DWORD PTR bufQWORD     ; lower
            mov         ecx, DWORD PTR scanVal.value
            cmp         eax, ecx
            jbe         findSuccess
        .ENDIF
    FAIL_compare:
    .ELSEIF      scanVal.valSize == TYPE_DWORD
        invoke      ReadProcessMemory, handle, ebx, OFFSET bufQWORD, TYPE_DWORD, 0
        add         edi, TYPE lastsearch
        mov         eax, DWORD PTR bufQWORD
        mov         edx, condition
        .IF         edx == COND_GT
            cmp         eax, DWORD PTR scanVal.value
            ja          findSuccess
        .ELSEIF     edx == COND_LT
            cmp         eax, DWORD PTR scanVal.value
            jb          findSuccess
        .ELSEIF     edx == COND_EQ
            cmp         eax, DWORD PTR scanVal.value
            je          findSuccess
        .ELSEIF     edx == COND_GE
            cmp         eax, DWORD PTR scanVal.value
            jae         findSuccess
        .ELSEIF     edx == COND_LE
            cmp         eax, DWORD PTR scanVal.value
            jbe         findSuccess
        .ENDIF
    .ELSEIF      scanVal.valSize == TYPE_WORD
        invoke      ReadProcessMemory, handle, ebx, OFFSET bufQWORD, TYPE_WORD, 0
        add         edi, TYPE lastsearch
        mov         ax, WORD PTR bufQWORD
        mov         edx, condition
        .IF         edx == COND_GT
            cmp         ax, WORD PTR scanVal.value
            ja          findSuccess
        .ELSEIF     edx == COND_LT
            cmp         ax, WORD PTR scanVal.value
            jb          findSuccess
        .ELSEIF     edx == COND_EQ
            cmp         ax, WORD PTR scanVal.value
            je          findSuccess
        .ELSEIF     edx == COND_GE
            cmp         ax, WORD PTR scanVal.value
            jae         findSuccess
        .ELSEIF     edx == COND_LE
            cmp         ax, WORD PTR scanVal.value
            jbe         findSuccess
        .ENDIF
    .ELSEIF      scanVal.valSize == TYPE_BYTE
        invoke      ReadProcessMemory, handle, ebx, OFFSET bufQWORD, TYPE_BYTE, 0
        add         edi, TYPE lastsearch
        mov         al, BYTE PTR bufQWORD
        mov         edx, condition
        .IF         edx == COND_GT
            cmp         al, BYTE PTR scanVal.value
            ja          findSuccess
        .ELSEIF     edx == COND_LT
            cmp         al, BYTE PTR scanVal.value
            jb          findSuccess
        .ELSEIF     edx == COND_EQ
            cmp         al, BYTE PTR scanVal.value
            je          findSuccess
        .ELSEIF     edx == COND_GE
            cmp         al, BYTE PTR scanVal.value
            jae         findSuccess
        .ELSEIF     edx == COND_LE
            cmp         al, BYTE PTR scanVal.value
            jbe         findSuccess
        .ENDIF
    .ELSEIF      scanVal.valSize == TYPE_REAL4
        invoke      ReadProcessMemory, handle, ebx, OFFSET bufQWORD, 4, 0
        add         edi, TYPE lastsearch
        fld         REAL4 PTR scanVal.value
        fld         REAL4 PTR bufQWORD
        mov         edx, condition
        .IF         edx == COND_GT
            fcomi       ST(0), ST(1)
            ja          findSuccess
        .ELSEIF     edx == COND_LT
            fcomi       ST(0), ST(1)
            jb          findSuccess
        .ELSEIF     edx == COND_EQ
            fcomi       ST(0), ST(1)
            je          findSuccess
        .ELSEIF     edx == COND_GE
            fcomi       ST(0), ST(1)
            jae         findSuccess
        .ELSEIF     edx == COND_LE
            fcomi       ST(0), ST(1)
            jbe         findSuccess
        .ENDIF
    .ELSEIF      scanVal.valSize == TYPE_REAL8
        invoke      ReadProcessMemory, handle, ebx, OFFSET bufQWORD, 8, 0
        add         edi, TYPE lastsearch
        fld         REAL8 PTR scanVal.value
        fld         REAL8 PTR bufQWORD
        mov         edx, condition
        .IF         edx == COND_GT
            fcomi       ST(0), ST(1)
            ja          findSuccess
        .ELSEIF     edx == COND_LT
            fcomi       ST(0), ST(1)
            jb          findSuccess
        .ELSEIF     edx == COND_EQ
            fcomi       ST(0), ST(1)
            je          findSuccess
        .ELSEIF     edx == COND_GE
            fcomi       ST(0), ST(1)
            jae         findSuccess
        .ELSEIF     edx == COND_LE
            fcomi       ST(0), ST(1)
            jbe         findSuccess
        .ENDIF
    .ENDIF

    jmp         findLoop
    ret
findSuccess:
    mov         [esi], ebx
    add         esi, TYPE lastsearch
    invoke      MakeMessage, OFFSET msgBuffer, ebx, bufQWORD, scanVal.valSize
    inc         newCount
    mov         eax, gui
    test        eax, eax
    jnz         updateListBox
    invoke      printf, OFFSET msgBuffer
    invoke      printf, OFFSET newLineMsg
    jmp         SUCCESS_end
updateListBox:
    mov         eax, newCount
    cmp         eax, 256
    ja          SUCCESS_end
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
    address:    PTR DWORD             ; the address of Address to be saved
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


; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
MakeMessage PROC, 
    dest:       PTR BYTE,           ; message buffer
    address:    DWORD,              ; address
    value:      QWORD,              ; data value
    valSize:    DWORD               ; the size of data
; Generate listbox message according to the address and value.
; No return value.
; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
    LOCAL       tmp:      REAL8
    .IF         valSize == TYPE_QWORD
        invoke      sprintf, dest, OFFSET addrQwordMsg, address, value
    .ELSEIF     valSize == TYPE_DWORD
        invoke      sprintf, dest, OFFSET addrDwordMsg, address, DWORD PTR value
    .ELSEIF     valSize == TYPE_WORD
        invoke      sprintf, dest, OFFSET addrWordMsg, address, WORD PTR value
    .ELSEIF     valSize == TYPE_BYTE
        invoke      sprintf, dest, OFFSET addrByteMsg, address, BYTE PTR value
    .ELSEIF     valSize == TYPE_REAL4
        invoke      printf, OFFSET filterMsg, value
        finit
        fld         REAL4 PTR value
        fstp        tmp
        invoke      printf, OFFSET float2Msg, tmp
        invoke      sprintf, dest, OFFSET addrDoubleMsg, address, tmp
    .ELSEIF     valSize == TYPE_REAL8
        invoke      sprintf, dest, OFFSET addrDoubleMsg, address, tmp
    .ENDIF
    ret
MakeMessage ENDP


END
