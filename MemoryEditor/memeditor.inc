; (memeditor.inc)
.386
.model          flat, stdcall
option          casemap: none

INCLUDE         windows.inc
INCLUDE         kernel32.inc 
INCLUDE         user32.inc 
INCLUDE         psapi.inc

INCLUDELIB      msvcrt.lib
INCLUDELIB      Irvine32.lib
INCLUDELIB      kernel32.lib 
INCLUDELIB      user32.lib 
INCLUDELIB      psapi.lib

; Structs used in scanning addresses
ScanValue STRUCT
    value       DWORD       ?           ; use this value to select addresses
    valSize     DWORD       ?           ; the type of the value to find
ScanValue ENDS

ScanMode STRUCT
    step        DWORD       ?           ; address increment in scanning
    condition   DWORD       ?           ; signify >, >=, =, <=, <
    memMin      DWORD       ?           ; beginning of scan range
    memMax      DWORD       ?           ; end of scan range       
ScanMode ENDS

; Irvine32.lib
DumpRegs        PROTO
ExitProcess     PROTO, dwExitCode:DWORD

; msvcrt.lib
scanf           PROTO, C:PTR SBYTE, :VARARG
printf          PROTO, C:PTR SBYTE, :VARARG
sprintf         PROTO, C:VARARG

; process.asm
EnumProc        PROTO, hListBox:DWORD
FetchProc       PROTO, index:DWORD, pid:PTR DWORD
GetPidByTitle   PROTO, windowTitle:PTR BYTE, pid:PTR DWORD

; filter.asm
FilterValue     PROTO, pid:DWORD, hListBox:DWORD, scanVal:ScanValue, scanMode:ScanMode
FilterValueTwo  PROTO, pid:DWORD, hListBox:DWORD, scanVal:ScanValue
FetchAddr       PROTO, index:DWORD, address:PTR DWORD
MakeMessage     PROTO, dest:PTR BYTE, address:DWORD, value:DWORD, valSize:DWORD

; memedit.asm
Modify          PROTO, pid:DWORD, writeAddr:DWORD, writeData:DWORD, valSize:DWORD

; main.asm
InputValue      PROTO, dest:PTR DWORD, vSize:DWORD

; Type Constants
TYPE_QWORD      EQU         <8>
TYPE_DWORD      EQU         <4>
TYPE_WORD       EQU         <2>
TYPE_BYTE       EQU         <1>

; Range Constants
DEFAULT_MEMMIN  EQU         <0h>
DEFAULT_MEMMAX  EQU         <0BFFFFFFFh>

; Scan Conditions
COND_GT         EQU         <1>
COND_GE         EQU         <2>
COND_EQ         EQU         <3>
COND_LE         EQU         <4>
COND_LT         EQU         <5>
