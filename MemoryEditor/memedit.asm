; Modify

INCLUDE         memeditor.inc

.data
recvData        SDWORD      ?
succMsg         BYTE        "Successfully rewrite memory from %u to %u", 0ah, 0dh, 0
modifyErrorMsg  BYTE        "Failed to open the process", 0ah, 0dh, 0

.code
; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
Modify PROC,
    pid:        DWORD,                 ; process PID
    writeAddr:  DWORD,                 ; the address to modify
    writeData:  QWORD,                 ; new number
    valSize:    DWORD                  ; the type of the value to find
; Modify a value in the certain address.
; Return value: eax == 1 iff error.
; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
    .IF         valSize == 32
        mov         valSize, 4
    .ELSEIF     valSize == 64
        mov         valSize, 8
    .ENDIF

    invoke      OpenProcess, PROCESS_ALL_ACCESS, 0, pid                         ; open the process (according to pid)
    test        eax, eax                                                        ; check whether the process is successfully opened (use bitwise AND)
    jz          modifyFailed                                                    ; if not successful, jump
    mov         ebx, eax                                                        ; save handle
    invoke      ReadProcessMemory, ebx, writeAddr, ADDR recvData, valSize, 0    ; save the original data
    test        eax, eax
    jz          modifyFailed                                                    ; if not successful, jump
    invoke      WriteProcessMemory, ebx, writeAddr, ADDR writeData, valSize, 0  ; edit memory
    test        eax, eax
    jz          modifyFailed                                                    ; if not successful, jump
    ; invoke      printf, OFFSET succMsg, recvData, writeData                   ; successful
    mov         eax, 0
    ret
modifyFailed:
    invoke      printf, OFFSET modifyErrorMsg
    mov         eax, 1
    ret
Modify ENDP

END
