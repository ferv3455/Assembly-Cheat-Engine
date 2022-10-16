; Windowed app with buttons

INCLUDE                memeditor.inc

; <<<<<<<<<<<<<<<<<<<< Window class >>>>>>>>>>>>>>>>>>>>>>>>>
WNDCLASS STRUC
    style           DWORD ?
    lpfnWndProc     DWORD ?
    cbClsExtra      DWORD ?
    cbWndExtra      DWORD ?
    hInstance       DWORD ?
    hIcon           DWORD ?
    hCursor         DWORD ?
    hbrBackground   DWORD ?
    lpszMenuName    DWORD ?
    lpszClassName   DWORD ?
WNDCLASS ENDS

; <<<<<<<<<<<<<<<<<<<< Message Struct >>>>>>>>>>>>>>>>>>>>>>>>>
MSGStruct STRUCT
    msgWnd          DWORD ?
    msgMessage      DWORD ?
    msgWparam       DWORD ?
    msgLparam       DWORD ?
    msgTime         DWORD ?
    msgPt           POINT <>
MSGStruct ENDS

; <<<<<<<<<<<<<<<<<<<< Widget Styles >>>>>>>>>>>>>>>>>>>>>>>>>
MAIN_WINDOW_STYLE = WS_VISIBLE+WS_CAPTION+WS_SYSMENU+WS_MINIMIZEBOX+WS_THICKFRAME
BUTTON_STYLE = WS_CHILD+WS_VISIBLE+BS_PUSHBUTTON
EDIT_STYLE = WS_CHILD+WS_VISIBLE
TEXT_STYLE = WS_CHILD+WS_VISIBLE
; TODO: only if necessary

.data
; <<<<<<<<<<<<<<<<<<<< Popup Messages >>>>>>>>>>>>>>>>>>>>>>>>>
popupTitle      BYTE        "Popup Window",0
buttonText      BYTE        "This window was activated by a Button message",0
editText        BYTE        "This window was activated by a Edit Control message",0

; <<<<<<<<<<<<<<<<<<<< Classes of Widgets >>>>>>>>>>>>>>>>>>>>>>>>>
windowClass     BYTE        "ASMWin", 0
buttonClass     BYTE        "Button", 0
editClass       BYTE        "Edit", 0
textClass       BYTE        "Static", 0
comboClass      BYTE        "ComboBox", 0
listboxClass    BYTE        "ListBox", 0

; <<<<<<<<<<<<<<<<<<<< Titles of Widgets >>>>>>>>>>>>>>>>>>>>>>>>>
windowName      BYTE        "Memory Editor", 0
btnName         BYTE        "Press here", 0
editName        BYTE        "123124", 0
textName        BYTE        "This is a label.", 0
; TODO

; <<<<<<<<<<<<<<<<<<<< Handles of Widgets >>>>>>>>>>>>>>>>>>>>>>>>>
hMainWnd        DWORD       ?
hButton         DWORD       ?
hEdit           DWORD       ?
hText           DWORD       ?
; TODO

; <<<<<<<<<<<<<<<<<<<< Other data format >>>>>>>>>>>>>>>>>>>>>>>>>
msg             MSGStruct   <>
winRect         RECT        <>
hInstance       DWORD       ?

MainWin         WNDCLASS    <NULL, WinProc, NULL, NULL, NULL, NULL, NULL,  \
                            COLOR_WINDOW, NULL, windowClass>

.code
WinMain PROC
    ; <<<<<<<<<<<<<<<<<<<< Creating Main Window >>>>>>>>>>>>>>>>>>>>>>>>>
    ; Get a handle to the current process.
    invoke      GetModuleHandle, NULL
    mov         hInstance, eax
    mov         MainWin.hInstance, eax

    ; Load the program's icon and cursor.
    invoke      LoadCursor, NULL, IDC_ARROW
    mov         MainWin.hCursor, eax

    ; Register the window class.
    invoke      RegisterClass, ADDR MainWin
    .IF eax == 0
        jmp     Exit_Program
    .ENDIF

    ; Create the application's main window.
    ; Returns a handle to the main window in EAX.
    invoke      CreateWindowEx, 0, ADDR windowClass, ADDR windowName, 
                    MAIN_WINDOW_STYLE, CW_USEDEFAULT, CW_USEDEFAULT, 
                    600, 600, NULL, NULL, hInstance, NULL   ; Main Window WIDTH, HEIGHT
    mov         hMainWnd, eax

    ; If CreateWindowEx failed, display a message & exit.
    .IF eax == 0
        jmp     Exit_Program
    .ENDIF

    ; <<<<<<<<<<<<<<<<<<<< Creating widgets >>>>>>>>>>>>>>>>>>>>>>>>>
    ; Create a button
    invoke      CreateWindowEx, 0, ADDR buttonClass, ADDR btnName, 
                    BUTTON_STYLE, 0, 0, 100, 25,            ; X, Y, WIDTH, HEIGHT
                    hMainWnd, 1, hInstance, NULL
    mov         hButton, eax

    ; Create a text edit
    invoke      CreateWindowEx, 0, ADDR editClass, ADDR editName, 
                    EDIT_STYLE, 0, 30, 100, 25,
                    hMainWnd, 2, hInstance, NULL
    mov         hEdit, eax

    ; Create a text label
    invoke      CreateWindowEx, 0, ADDR textClass, ADDR textName, 
                    TEXT_STYLE, 0, 60, 100, 25,
                    hMainWnd, 3, hInstance, NULL
    mov         hButton, eax

    ; TODO

    ; <<<<<<<<<<<<<<<<<<<< Displaying all widgets >>>>>>>>>>>>>>>>>>>>>>>>>
    invoke      ShowWindow, hMainWnd, SW_SHOW
    invoke      UpdateWindow, hMainWnd
    invoke      ShowWindow, hButton, SW_SHOW
    invoke      UpdateWindow, hButton
    invoke      ShowWindow, hEdit, SW_SHOW
    invoke      UpdateWindow, hEdit
    ; TODO

    ; <<<<<<<<<<<<<<<<<<<< Message-handling loop >>>>>>>>>>>>>>>>>>>>>>>>>
Message_Loop:
    ; Get next message from the queue.
    invoke      GetMessage, ADDR msg, NULL,NULL,NULL

    ; Quit if no more messages.
    .IF eax == 0
        jmp     Exit_Program
    .ENDIF

    ; Relay the message to the program's WinProc.
    invoke      TranslateMessage, ADDR msg
    invoke      DispatchMessage, ADDR msg
    jmp         Message_Loop

Exit_Program:
    invoke      ExitProcess, 0
WinMain ENDP

; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
WinProc PROC,
    hWnd:       DWORD,              ; handler
    localMsg:   DWORD,              ; message
    wParam:     DWORD,              ; wParam
    lParam:     DWORD               ; lParam
; The application's message handler, which handles
; application-specific messages. All other messages
; are forwarded to the default Windows message
; handler.
; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
    mov             eax, localMsg
    .IF eax == WM_CLOSE            ; close window
        invoke      PostQuitMessage, 0
        jmp         WinProcExit

    .ELSEIF eax == WM_COMMAND   ; commands (including click, edit)
        mov         ebx, wParam
        mov         eax, wParam     ; AX: LOWORD
        ror         ebx, 16         ; BX: HIWORD

        ; Processing different message types
        ; .IF         bx == BN_CLICKED    ; click
        ;     invoke  MessageBox, hWnd, ADDR buttonText, ADDR popupTitle, MB_OK
        ; .ELSEIF     bx == EN_CHANGE     ; edit control changed
        ;     invoke  MessageBox, hWnd, ADDR editText, ADDR popupTitle, MB_OK
        ; .ENDIF
        jmp         WinProcExit

    .ELSE                        ; other message
        invoke      DefWindowProc, hWnd, localMsg, wParam, lParam
        jmp         WinProcExit
    .ENDIF

WinProcExit:
    ret
WinProc ENDP

END
