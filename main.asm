; Memory editor: command line version

.386
.MODEL          flat, stdcall
OPTION          casemap: none

INCLUDE         windows.inc
INCLUDE         kernel32.inc 
INCLUDE         user32.inc 
INCLUDE         psapi.inc

INCLUDELIB      msvcrt.lib
INCLUDELIB      Irvine32.lib
INCLUDELIB      kernel32.lib 
INCLUDELIB      user32.lib 
INCLUDELIB      psapi.lib

DumpRegs        PROTO
ExitProcess     PROTO, dwExitCode:DWORD

scanf           PROTO, C:PTR SBYTE, :VARARG
printf          PROTO, C:PTR SBYTE, :VARARG

.data
; ===================================================DATA BEGINS=========================================================
; <<<<<<<<<<<<<<<<<<<< PROC Main >>>>>>>>>>>>>>>>>>>>>>>>>
inputNumMsg     BYTE        "%d", 0
inputHexMsg     BYTE        "%x", 0
pidPromptMsg    BYTE        "Enter the PID of the program: ", 0
filterPromptMsg BYTE        "Enter the value: ", 0
addrPromptMsg   BYTE        "Enter the address to be edited: ", 0
valPromptMsg    BYTE        "Enter the new value: ", 0
command         DWORD       ?

; <<<<<<<<<<<<<<<<<<<< PROC EnumProc >>>>>>>>>>>>>>>>>>>>>>>>>                    TO BE MODIFIED
procPids        DWORD       1024 DUP(?)                                         ; array of pids
procCount       DWORD       ?                                                   ; total number of pids
enumMsg         BYTE        "%d processes found. Here are the ones can be modified (only 32-bit user-level programs are supported):", 0ah, 0dh, 0
errorEnumMsg    BYTE        "Failed to enumerate", 0ah, 0dh, 0
procNameMsg     BYTE        "%d - %s", 0ah, 0dh, 0

; <<<<<<<<<<<<<<<<<<<< PROC GetPidByTitle >>>>>>>>>>>>>>>>>>>>>>>>>               TO BE MODIFIED
windowTitle     BYTE        128 DUP(?)                                          ; window title
pidMsg          BYTE        "Process PID: %d", 0ah, 0dh, 0
errorMsg        BYTE        "Window not found", 0ah, 0dh, 0

; <<<<<<<<<<<<<<<<<<<< PROC Filter >>>>>>>>>>>>>>>>>>>>>>>>>                      TO BE MODIFIED
filterVal       DWORD       ?                                                   ; the value for filtering addresses
filterMsg       BYTE        "Use value %d to filter", 0ah, 0dh, 0

; <<<<<<<<<<<<<<<<<<<< PROC Modify >>>>>>>>>>>>>>>>>>>>>>>>>                      TO BE MODIFIED
pid             DWORD       ?                                                   ; process pid
writeAddr       DWORD       ?                                                   ; data address
writeData       SDWORD      ?                                                   ; new data
recvData        SDWORD      ?
succMsg         BYTE        "Successfully rewrite memory from %d to %d", 0ah, 0dh, 0
modifyErrorMsg  BYTE        "Failed to open the process", 0ah, 0dh, 0

.code
; ===================================================CODE BEGINS=========================================================

; Program Entrance
Main PROC
    ; List all processes (show all)
    call        EnumProc

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
    call        FilterValue
    jmp         MainLoop

Edit:
    ; 2: Edit a given address
    ; Choose the address to modify
    invoke      printf, OFFSET addrPromptMsg
    invoke      scanf, OFFSET inputHexMsg, OFFSET writeAddr
    ; mov         writeAddr, 00fbf740h

    ; Enter the new value
    invoke      printf, OFFSET valPromptMsg
    invoke      scanf, OFFSET inputNumMsg, OFFSET writeData
    ; mov         writeData, 25

    ; Confirm
    call        Modify
    jmp         MainLoop

Quit:
    ; 0: Terminate
    invoke      ExitProcess, 0
Main ENDP

; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««

; Enumerate all processes.
EnumProc PROC
    ; local variables used in iteration
    LOCAL       procName[260]   :BYTE
    LOCAL       hMod            :DWORD
    LOCAL       cbNeeded        :DWORD

    ; find all pids
    invoke      EnumProcesses, OFFSET procPids, SIZEOF procPids, OFFSET procCount
    test        eax, eax                                                        ; check whether the window is successfully found (use bitwise AND)
    jz          enumerateFailed                                                 ; if not successful, jump
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

; Get process ID according to the window title. (Not used any more)
GetPidByTitle PROC
    invoke      FindWindow, 0, OFFSET windowTitle                               ; find the window
    test        eax, eax                                                        ; check whether the window is successfully found (use bitwise AND)
    jz          windowNotFound                                                  ; if not successful, jump
    invoke      GetWindowThreadProcessId, eax, OFFSET pid                       ; get process id
    invoke      printf, OFFSET pidMsg, pid                                      ; show the pid
    ret
windowNotFound:
    invoke      printf, OFFSET errorMsg
    ret
GetPidByTitle ENDP

; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««

; Filter out addresses according to the value.
FilterValue PROC
    invoke      printf, OFFSET filterMsg, filterVal
    ; TODO
    ret
FilterValue ENDP

; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««

; Modify a value in the certain address.
Modify PROC
    invoke      OpenProcess, PROCESS_ALL_ACCESS, 0, pid                         ; open the process (according to pid)
    test        eax, eax                                                        ; check whether the process is successfully opened (use bitwise AND)
    jz          procOpenFailed                                                  ; if not successful, jump
    mov         ebx, eax                                                        ; save handle
    invoke      ReadProcessMemory, ebx, writeAddr, OFFSET recvData, 4, 0        ; save the original data
    invoke      WriteProcessMemory, ebx, writeAddr, OFFSET writeData, 4, 0      ; edit memory
    invoke      printf, OFFSET succMsg, recvData, writeData                     ; successful
    ret
procOpenFailed:
    invoke      printf, OFFSET modifyErrorMsg
    ret
Modify ENDP

; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««

END Main
