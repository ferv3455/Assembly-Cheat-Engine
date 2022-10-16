; FilterValue

INCLUDE         memeditor.inc

.data
; <<<<<<<<<<<<<<<<<<<< PROC Filter >>>>>>>>>>>>>>>>>>>>>>>>>
filterMsg       BYTE        "Use value %d to filter", 0ah, 0dh, 0
filterAnsMsg    BYTE        "Found address: %08X", 0ah, 0dh, 0
testMsg         BYTE        "val is %08X", 0ah, 0dh, 0
buf             DWORD       ?
memMAX          DWORD       007FFFFFH
memMIN          DWORD       0H
lastsearch      DWORD       1024 DUP(?)
totaladdr       DWORD       0
errorFilterMsg  BYTE        "Failed to filter", 0ah, 0dh, 0

; <<<<<<<<<<<<<<<<<<<< PROC Filter_2 >>>>>>>>>>>>>>>>>>>>>>>>>
filterTwoAnsMsg BYTE        "Found changed value's address: %08X", 0ah, 0dh, 0
findDoneMsg     BYTE        "Find Done!", 0ah, 0dh, 0

.code
; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
FilterValue PROC,
    filterVal:  DWORD,                 ; use this value to select addresses
    pid:        DWORD                  ; which process
; Filter out addresses according to the value.
; No return value.
; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
    ; local variables used in iteration
    LOCAL       hMod[100]       :DWORD
    LOCAL       ansAddr         :DWORD
    LOCAL       cbNeeded        :DWORD
    LOCAL       mbi[28]         :DWORD
    LOCAL       nowAddr         :DWORD
    LOCAL       maxAddr         :DWORD
    LOCAL       ebxStore        :DWORD

    invoke      printf, OFFSET filterMsg, filterVal
    mov         totaladdr, 0
    invoke      OpenProcess, PROCESS_ALL_ACCESS, 0, pid ; open process according to pid
    test        eax, eax
    jz          filterProcReadFailed
    mov         ebx, eax
    mov         ebxStore, ebx
    invoke      EnumProcessModules, ebx, ADDR hMod, SIZEOF hMod, ADDR cbNeeded
    ; invoke      printf, OFFSET testMsg, DWORD PTR hMod[0]
    test        eax, eax
    jz          filterProcReadFailed
    ; invoke      ReadProcessMemory, ebx, DWORD PTR hMod[0], OFFSET buf, SIZEOF buf, ADDR numOfBytesRead
    ; test        eax, eax
    ; jz          filterProcReadFailed
    mov         edi, hMod[0]
    mov         nowAddr, edi
    mov         maxAddr, edi
    mov         eax, hMod[0]
    add         eax, memMAX
    mov         memMAX, eax
    ;mov         edi, memMIN

    mov         esi, OFFSET lastsearch

BLOCK:
    cmp         edi, memMAX
    ja          fail_RET
    mov         ebx, ebxStore
    invoke      VirtualQueryEx, ebx, hMod[0], ADDR mbi, SIZEOF mbi
    test        eax, eax
    jz          fail_RET
    mov         edx, maxAddr
    add         edx, mbi[12]
    mov         maxAddr, edx
    ; invoke      printf, offset testMsg, maxAddr
    mov         eax, mbi[16]
    cmp         eax, MEM_COMMIT
    je          PIECE
    mov         eax, mbi[12]
    add         edi, eax
    jmp         BLOCK

PIECE:
    cmp         edi, maxAddr
    je          BLOCK
    ; invoke      printf, OFFSET testMsg, DWORD PTR edi
    invoke      ReadProcessMemory, ebx, edi, OFFSET buf, SIZEOF buf, 0
    test        eax, eax
    jz          accessFailed
    mov         eax, filterVal
    cmp         eax, buf
    je          SUCCESS_find
    add         edi, 4
    jmp         PIECE
    ret
SUCCESS_find:
    mov         ansAddr, edi
    invoke      printf, OFFSET filterAnsMsg, ansAddr
    add         edi, 4
    mov         eax, ansAddr
    mov         [esi], eax
    inc         totaladdr
    add         esi, TYPE lastsearch
    jmp         PIECE
    ret
fail_RET:
    ret
accessFailed:
    add         edi, 4
    jmp         PIECE
    ret
filterProcReadFailed:
    invoke      printf, OFFSET errorFilterMsg
    ret
FilterValue ENDP


; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
FilterValueTwo PROC,
    filterVal:  DWORD,                 ; use this value to select addresses
    pid:        DWORD                  ; which process
; Select addresses according to the value from a given set.
; No return value.
; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
    LOCAL       tmpVal        :DWORD
    LOCAL       handle        :DWORD
    LOCAL       count         :DWORD
    LOCAL       newCount      :DWORD

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
    invoke      ReadProcessMemory, handle, ebx, ADDR tmpVal, 4, 0
    add         edi, TYPE lastsearch
    mov         eax, tmpVal
    cmp         eax, filterVal
    je          findSuccess
    jmp         findLoop
    ret
findSuccess:
    invoke      printf, OFFSET filterTwoAnsMsg, ebx
    mov         [esi], ebx
    inc         newCount
    jmp         findLoop
    ret
findDone:
    invoke      printf, OFFSET findDoneMsg
    mov         eax, newCount
    mov         totaladdr, eax
    ret
filterProcReadFailed:
    invoke      printf, OFFSET errorFilterMsg
    ret
FilterValueTwo ENDP

END
