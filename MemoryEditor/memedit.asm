; Modify

INCLUDE         memeditor.inc

.data
; <<<<<<<<<<<<<<<<<<<< PROC Modify >>>>>>>>>>>>>>>>>>>>>>>>>                      TO BE MODIFIED
recvData        SDWORD      ?
succMsg         BYTE        "Successfully rewrite memory from %d to %d", 0ah, 0dh, 0
modifyErrorMsg  BYTE        "Failed to open the process", 0ah, 0dh, 0

.code
; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««

; Modify a value in the certain address.
Modify PROC pid:DWORD, writeAddr:DWORD, writeData:DWORD
    invoke      OpenProcess, PROCESS_ALL_ACCESS, 0, pid                         ; open the process (according to pid)
    test        eax, eax                                                        ; check whether the process is successfully opened (use bitwise AND)
    jz          procOpenFailed                                                  ; if not successful, jump
    mov         ebx, eax                                                        ; save handle
    invoke      ReadProcessMemory, ebx, writeAddr, ADDR recvData, 4, 0        ; save the original data
    invoke      WriteProcessMemory, ebx, writeAddr, ADDR writeData, 4, 0      ; edit memory
    invoke      printf, OFFSET succMsg, recvData, writeData                     ; successful
    ret
procOpenFailed:
    invoke      printf, OFFSET modifyErrorMsg
    ret
Modify ENDP

; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
END