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
FilterValue     PROTO, filterVal:DWORD, pid:DWORD, hListBox:DWORD
FilterValueTwo  PROTO, filterVal:DWORD, pid:DWORD, hListBox:DWORD
FetchAddr       PROTO, index:DWORD, address:PTR DWORD

; memedit.asm
Modify          PROTO, pid:DWORD, writeAddr:DWORD, writeData:DWORD
