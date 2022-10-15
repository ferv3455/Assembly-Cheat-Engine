; EnumProc, GetPidByTitle

INCLUDE         memeditor.inc

.data
; <<<<<<<<<<<<<<<<<<<< PROC EnumProc >>>>>>>>>>>>>>>>>>>>>>>>>
procPids        DWORD       1024 DUP(?)
procCount       DWORD       ?
enumMsg         BYTE        "%d processes found. Here are the ones that can be modified (only 32-bit user-level programs are supported):", 0ah, 0dh, 0
errorEnumMsg    BYTE        "Failed to enumerate", 0ah, 0dh, 0
procNameMsg     BYTE        "%d - %s", 0ah, 0dh, 0

; <<<<<<<<<<<<<<<<<<<< PROC GetPidByTitle >>>>>>>>>>>>>>>>>>>>>>>>>
pidMsg          BYTE        "Process PID: %d", 0ah, 0dh, 0
errorMsg        BYTE        "Window not found", 0ah, 0dh, 0

.code
; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
EnumProc PROC
; Enumerate all processes.
; No return value.
; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
    ; local variables used in iteration
    local       procName[260]:  BYTE
    local       hMod:           DWORD
    local       cbNeeded:       DWORD

    ; find all pids
    invoke      EnumProcesses, OFFSET procPids, SIZEOF procPids, OFFSET procCount
    test        eax, eax                                                        ; check whether enumerating is successful
    jz          enumerateFailed                                                 ; if not successful, jump

    mov         edx, 0
    mov         eax, procCount
    mov         ebx, TYPE procPids
    div         ebx
    mov         procCount, eax
    invoke      printf, OFFSET enumMsg, procCount                               ; show the number of processes

    ; print all processes
    mov         ecx, procCount
    mov         edi, OFFSET procPids
L1:
    push        ecx
    invoke      OpenProcess, PROCESS_ALL_ACCESS, 0, [edi]                       ; open the process (according to pid)
    test        eax, eax                                                        ; check whether the process is successfully opened (use bitwise AND)
    jz          procReadFailed                                                  ; if not successful, jump
    mov         ebx, eax
    invoke      EnumProcessModules, ebx, ADDR hMod, SIZEOF hMod, ADDR cbNeeded
    test        eax, eax
    jz          procReadFailed
    invoke      GetModuleBaseName, ebx, hMod, ADDR procName, LENGTHOF procName
    invoke      printf, ADDR procNameMsg, DWORD PTR [edi], ADDR procName
procReadFailed:
    add         edi, TYPE procPids
    pop         ecx
    loop        L1
    ret

enumerateFailed:
    invoke      printf, OFFSET errorEnumMsg
    ret
EnumProc ENDP


; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
GetPidByTitle PROC,
    winTitle:   PTR BYTE,             ; window title
    pid:        PTR DWORD             ; the address of PID to be saved
; Get process ID according to the window title.
; (Not used any more)
; No return value.
; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
    invoke      FindWindow, 0, winTitle                                      ; find the window
    test        eax, eax                                                        ; check whether the window is successfully found (use bitwise AND)
    jz          windowNotFound                                                  ; if not successful, jump
    invoke      GetWindowThreadProcessId, eax, pid                              ; get process id
    mov         eax, [pid]
    invoke      printf, OFFSET pidMsg, eax                                      ; show the pid
    ret
windowNotFound:
    invoke      printf, OFFSET errorMsg
    ret
GetPidByTitle ENDP

; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
END
