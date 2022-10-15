; FilterValue

INCLUDE         memeditor.inc

.data
filterMsg       BYTE        "Use value %d to filter", 0ah, 0dh, 0

.code
; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««

; Filter out addresses according to the value.
FilterValue PROC filterVal:DWORD
    invoke      printf, OFFSET filterMsg, filterVal
    ; TODO
    ret
FilterValue ENDP

; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
END
