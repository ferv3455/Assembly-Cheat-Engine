; (memeditor.inc)
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

; msvcrt.lib
scanf           PROTO, C:PTR SBYTE, :VARARG
printf          PROTO, C:PTR SBYTE, :VARARG

; process.asm
EnumProc        PROTO
GetPidByTitle   PROTO, windowTitle:PTR BYTE, pid:PTR DWORD

; filter.asm
FilterValue     PROTO, filterVal:DWORD

; memedit.asm
Modify          PROTO, pid:DWORD, writeAddr:DWORD, writeData:DWORD