; FilterValue

INCLUDE         memeditor.inc

.data
filterMsg       BYTE        "Use value %d to filter", 0ah, 0dh, 0

.code
; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
FilterValue PROC,
    filterVal:  DWORD                 ; use this value to select addresses
; Filter out addresses according to the value.
; No return value.
; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
    invoke      printf, OFFSET filterMsg, filterVal
    ; TODO
    ret
FilterValue ENDP

END
