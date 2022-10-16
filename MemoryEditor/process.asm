; EnumProc, GetPidByTitle

INCLUDE         memeditor.inc

.data
; <<<<<<<<<<<<<<<<<<<< PROC EnumProc >>>>>>>>>>>>>>>>>>>>>>>>>
procPids        DWORD       2048 DUP(?)
procCount       DWORD       ?
validPids       DWORD       2048 DUP(?)
validCount      DWORD       ?
enumMsg         BYTE        "%d processes found. Here are the ones that can be modified (only 32-bit user-level programs are supported):", 0ah, 0dh, 0
errorEnumMsg    BYTE        "Failed to enumerate", 0ah, 0dh, 0
procNameMsg     BYTE        "%u - %s", 0ah, 0dh, 0

; <<<<<<<<<<<<<<<<<<<< PROC GetPidByTitle >>>>>>>>>>>>>>>>>>>>>>>>>
pidMsg          BYTE        "Process PID: %u", 0ah, 0dh, 0
errorMsg        BYTE        "Window not found", 0ah, 0dh, 0

.code
; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
EnumProc PROC,
    hListBox:   DWORD                   ; the handle of Listbox if GUI is used
; Enumerate all processes.
; No return value.
; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
    ; local variables used in iteration
    local       procName[260]:  BYTE
    local       hMod:           DWORD
    local       cbNeeded:       DWORD
    local       gui:            DWORD

    ; check whether GUI is used
    mov         gui, 0
    mov         eax, hListBox
    test        eax, eax
    jz          findPID
    mov         gui, 1

    ; find all pids
findPID:
    invoke      EnumProcesses, OFFSET procPids, SIZEOF procPids, OFFSET procCount
    test        eax, eax                                                        ; check whether enumerating is successful
    jz          enumerateFailed                                                 ; if not successful, jump

    mov         edx, 0
    mov         eax, procCount
    mov         ebx, TYPE procPids
    div         ebx
    mov         procCount, eax

    mov         eax, gui
    test        eax, eax
    jnz         enumerateProc
    invoke      printf, OFFSET enumMsg, procCount                               ; show the number of processes

    ; save all processes
enumerateProc:
    mov         esi, OFFSET validPids
    mov         validCount, 0
    mov         ecx, procCount
    mov         edi, OFFSET procPids
L1:
    push        ecx
    invoke      OpenProcess, PROCESS_ALL_ACCESS, 0, [edi]                       ; open the process (according to pid)
    test        eax, eax                                                        ; check whether the process is successfully opened (use bitwise AND)
    jz          procReadOver                                                    ; if not successful, jump
    mov         ebx, eax
    invoke      EnumProcessModules, ebx, ADDR hMod, SIZEOF hMod, ADDR cbNeeded
    test        eax, eax
    jz          procReadOver
    invoke      GetModuleBaseName, ebx, hMod, ADDR procName, LENGTHOF procName

    mov         ebx, [edi]
    mov         [esi], ebx
    inc         validCount
    add         esi, TYPE validPids

    mov         eax, gui
    test        eax, eax
    jnz         updateListBox
    invoke      printf, ADDR procNameMsg, ebx, ADDR procName
    jmp         procReadOver
updateListBox:
    invoke      SendMessage, hListBox, LB_ADDSTRING, 0, ADDR procName
    invoke      SendMessage, hListBox, LB_SETITEMDATA, eax, validCount
procReadOver:
    add         edi, TYPE procPids
    pop         ecx
    dec         ecx
    jnz         L1
    ret

enumerateFailed:
    invoke      printf, OFFSET errorEnumMsg
    ret
EnumProc ENDP


; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
FetchProc PROC, 
    index:      DWORD,                ; index in procPids
    pid:        PTR DWORD             ; the address of PID to be saved
; Get process ID according to the index.
; No return value.
; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
    mov         edi, pid
    mov         eax, index
    dec         eax
    mov         ecx, TYPE validPids
    mul         ecx
    mov         ebx, validPids[eax]
    mov         [edi], ebx
    ret
FetchProc ENDP


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
