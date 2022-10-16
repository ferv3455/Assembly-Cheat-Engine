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
EDIT_STYLE = WS_CHILD+WS_VISIBLE+ES_NUMBER
ADDR_STYLE = WS_CHILD+WS_VISIBLE
TEXT_STYLE = WS_CHILD+WS_VISIBLE
LISTBOX_STYLE = WS_CHILD+WS_VISIBLE+LBS_NOTIFY

.data
; <<<<<<<<<<<<<<<<<<<< Popup Messages >>>>>>>>>>>>>>>>>>>>>>>>>
popupTitle      BYTE        "Popup Window", 0
buttonText      BYTE        "This window was activated by a Button message", 0
editText        BYTE        "This window was activated by a Edit Control message", 0
listboxFormat   BYTE        "This window was activated by Listbox item %d", 0
listboxText     BYTE        50 DUP(?)

; <<<<<<<<<<<<<<<<<<<< Classes of Widgets >>>>>>>>>>>>>>>>>>>>>>>>>
windowClass     BYTE        "ASMWin", 0
buttonClass     BYTE        "Button", 0
editClass       BYTE        "Edit", 0
textClass       BYTE        "Static", 0
comboClass      BYTE        "ComboBox", 0
listboxClass    BYTE        "ListBox", 0

; <<<<<<<<<<<<<<<<<<<< Titles of Widgets >>>>>>>>>>>>>>>>>>>>>>>>>
windowName      BYTE        "Memory Editor", 0
quitBtn         BYTE        "Quit Process", 0
selBtn          BYTE        "Select Process", 0
newBtn          BYTE        "New", 0
nextBtn         BYTE        "Next", 0
filtLabel       BYTE        "Filtering Address: ", 0
valLabel        BYTE        "Value: ", 0
editLabel       BYTE        "Edit Memory: ", 0
addrLabel       BYTE        "Address: ", 0
newValLabel     BYTE        "New Value: ", 0
editBtn         BYTE        "Edit", 0

; <<<<<<<<<<<<<<<<<<<< Handles of Widgets >>>>>>>>>>>>>>>>>>>>>>>>>
hMainWnd        DWORD       ?
hListBox        DWORD       ?
; hMainEdit       DWORD       ?
hQuitBtn        DWORD       ?
hSelectBtn      DWORD       ?
hFiltLabel      DWORD       ?
hNewBtn         DWORD       ?
hNextBtn        DWORD       ?
hValLabel       DWORD       ?
hValEdit        DWORD       ?
hEditLabel      DWORD       ?
hAddrLabel      DWORD       ?
hAddrEdit       DWORD       ?
hNewValLabel    DWORD       ?
hNewValEdit     DWORD       ?
hEditBtn        DWORD       ?

; <<<<<<<<<<<<<<<<<<<< Main Logics >>>>>>>>>>>>>>>>>>>>>>>>>
state           DWORD       0
pid             DWORD       ?
filterVal       DWORD       ?
writeAddr       DWORD       ?
writeData       DWORD       ?
addrMsg         BYTE        "%08X", 0
buffer          BYTE        16 DUP(0)
successMsg      BYTE        "Successfully rewrite memory.", 0

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
    ; main listbox
    invoke      CreateWindowEx, 0, ADDR listboxClass, NULL, 
                    LISTBOX_STYLE, 20, 20, 260, 520,
                    hMainWnd, 1, hInstance, NULL
    mov         hListBox, eax
    invoke      EnumProc, hListBox

    ; quit button
    invoke      CreateWindowEx, 0, ADDR buttonClass, ADDR quitBtn,
                    BUTTON_STYLE, 300, 20, 260, 40,
                    hMainWnd, 2, hInstance, NULL
    mov         hQuitBtn, eax
    invoke      EnableWindow, hQuitBtn, 0

    ; select button
    invoke      CreateWindowEx, 0, ADDR buttonClass, ADDR selBtn,
                    BUTTON_STYLE, 300, 80, 260, 40,
                    hMainWnd, 3, hInstance, NULL
    mov         hSelectBtn, eax

    ; filtering label
    invoke      CreateWindowEx, 0, ADDR textClass, ADDR filtLabel,
                    TEXT_STYLE, 300, 170, 260, 20,             
                    hMainWnd, 4, hInstance, NULL
    mov         hFiltLabel, eax
    
    ; new button
    invoke      CreateWindowEx, 0, ADDR buttonClass, ADDR newBtn,
                    BUTTON_STYLE, 300, 200, 120, 40,             
                    hMainWnd, 5, hInstance, NULL
    mov         hNewBtn, eax
    invoke      EnableWindow, hNewBtn, 0
    
    ; next button
    invoke      CreateWindowEx, 0, ADDR buttonClass, ADDR nextBtn,
                    BUTTON_STYLE, 440, 200, 120, 40,             
                    hMainWnd, 6, hInstance, NULL
    mov         hNextBtn, eax
    invoke      EnableWindow, hNextBtn, 0

    ; value label
    invoke      CreateWindowEx, 0, ADDR textClass, ADDR valLabel,
                    TEXT_STYLE, 300, 260, 80, 40,             
                    hMainWnd, 7, hInstance, NULL
    mov         hValLabel, eax

    ; value edit
    invoke      CreateWindowEx, 0, ADDR editClass, NULL,
                    EDIT_STYLE, 380, 260, 180, 40,             
                    hMainWnd, 8, hInstance, NULL
    mov         hValEdit, eax
    invoke      EnableWindow, hValEdit, 0

    ; edit label
    invoke      CreateWindowEx, 0, ADDR textClass, ADDR editLabel,
                    TEXT_STYLE, 300, 340, 260, 40,             
                    hMainWnd, 9, hInstance, NULL
    mov         hEditLabel, eax

    ; address label
    invoke      CreateWindowEx, 0, ADDR textClass, ADDR addrLabel,
                    TEXT_STYLE, 300, 380, 120, 40,             
                    hMainWnd, 10, hInstance, NULL
    mov         hAddrLabel, eax

    ; address edit
    invoke      CreateWindowEx, 0, ADDR editClass, NULL,
                    BUTTON_STYLE, 380, 380, 180, 40,             
                    hMainWnd, 11, hInstance, NULL
    mov         hAddrEdit, eax
    invoke      EnableWindow, hAddrEdit, 0

    ; new value label
    invoke      CreateWindowEx, 0, ADDR textClass, ADDR newValLabel,
                    TEXT_STYLE, 300, 440, 120, 40,             
                    hMainWnd, 12, hInstance, NULL
    mov         hNewValLabel, eax

    ; new value edit
    invoke      CreateWindowEx, 0, ADDR editClass, NULL,
                    BUTTON_STYLE, 380, 440, 180, 40,             
                    hMainWnd, 13, hInstance, NULL
    mov         hNewValEdit, eax
    invoke      EnableWindow, hNewValEdit, 0

    ; edit button
    invoke      CreateWindowEx, 0, ADDR buttonClass, ADDR editBtn,
                    BUTTON_STYLE, 300, 500, 260, 40,
                    hMainWnd, 14, hInstance, NULL
    mov         hEditBtn, eax
    invoke      EnableWindow, hEditBtn, 0

    ; <<<<<<<<<<<<<<<<<<<< Displaying MainWindow >>>>>>>>>>>>>>>>>>>>>>>>>
    invoke      ShowWindow, hMainWnd, SW_SHOW
    invoke      UpdateWindow, hMainWnd

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
        .IF             bx == BN_CLICKED    ; button
            .IF         ax == 2             ; quit current process
                mov         state, 0
                invoke      SendMessage, hListBox, LB_RESETCONTENT, 0, 0
                invoke      EnumProc, hListBox
                invoke      EnableWindow, hQuitBtn, 0
                invoke      EnableWindow, hSelectBtn, 1
                invoke      EnableWindow, hNewBtn, 0
                invoke      EnableWindow, hNextBtn, 0
                invoke      EnableWindow, hValEdit, 0
                invoke      EnableWindow, hAddrEdit, 0
                invoke      EnableWindow, hNewValEdit, 0
                invoke      EnableWindow, hEditBtn, 0
            .ENDIF
        .ENDIF

        .IF         state == 0          ; selecting process
            .IF             bx == LBN_SELCHANGE ; listbox
                invoke      SendMessage, hListBox, LB_GETCURSEL, 0, 0
                invoke      SendMessage, hListBox, LB_GETITEMDATA, eax, 0
                invoke      FetchProc, eax, ADDR pid
            .ELSEIF         bx == BN_CLICKED    ; button
                .IF         ax == 3             ; select current process
                    mov         state, 1
                    invoke      SendMessage, hListBox, LB_RESETCONTENT, 0, 0
                    invoke      EnableWindow, hQuitBtn, 1
                    invoke      EnableWindow, hSelectBtn, 0
                    invoke      EnableWindow, hNewBtn, 1
                    invoke      EnableWindow, hValEdit, 1
                    invoke      EnableWindow, hAddrEdit, 1
                    invoke      EnableWindow, hNewValEdit, 1
                    invoke      EnableWindow, hEditBtn, 1
                .ENDIF
            .ENDIF
        .ELSEIF     state == 1           ; before first
            .IF             bx == BN_CLICKED    ; button
                .IF         ax == 5             ; new filtering
                    invoke      SendMessage, hListBox, LB_RESETCONTENT, 0, 0
                    invoke      GetDlgItemInt, hMainWnd, 8, NULL, 0
                    mov         filterVal, eax
                    invoke      FilterValue, filterVal, pid, hListBox
                    invoke      EnableWindow, hNextBtn, 1
                    mov         state, 2
                .ENDIF
            .ELSEIF         bx == LBN_SELCHANGE ; listbox
                invoke          SendMessage, hListBox, LB_GETCURSEL, 0, 0
                invoke          SendMessage, hListBox, LB_GETITEMDATA, eax, 0
                invoke          FetchAddr, eax, ADDR writeAddr
                invoke          sprintf, OFFSET buffer, OFFSET addrMsg, writeAddr
                invoke          SetWindowText, hAddrEdit, OFFSET buffer
                mov             state, 3
            .ENDIF
        .ELSEIF     state == 2           ; after first
            .IF             bx == BN_CLICKED    ; button
                .IF         ax == 5             ; new filtering
                    invoke      SendMessage, hListBox, LB_RESETCONTENT, 0, 0
                    invoke      GetDlgItemInt, hMainWnd, 8, NULL, 0
                    mov         filterVal, eax
                    invoke      FilterValue, filterVal, pid, hListBox
                    invoke      EnableWindow, hNextBtn, 1
                .ELSEIF     ax == 6             ; next filtering
                    invoke      SendMessage, hListBox, LB_RESETCONTENT, 0, 0
                    invoke      GetDlgItemInt, hMainWnd, 8, NULL, 0
                    mov         filterVal, eax
                    invoke      FilterValueTwo, filterVal, pid, hListBox
                .ENDIF
            .ELSEIF         bx == LBN_SELCHANGE ; listbox
                invoke          SendMessage, hListBox, LB_GETCURSEL, 0, 0
                invoke          SendMessage, hListBox, LB_GETITEMDATA, eax, 0
                invoke          FetchAddr, eax, ADDR writeAddr
                invoke          sprintf, OFFSET buffer, OFFSET addrMsg, writeAddr
                invoke          SetWindowText, hAddrEdit, OFFSET buffer
                mov             state, 3
            .ENDIF
        .ELSEIF     state == 3           ; address selected
            .IF             bx == BN_CLICKED    ; button
                .IF         ax == 5             ; new filtering
                    invoke      SendMessage, hListBox, LB_RESETCONTENT, 0, 0
                    invoke      GetDlgItemInt, hMainWnd, 8, NULL, 0
                    mov         filterVal, eax
                    invoke      FilterValue, filterVal, pid, hListBox
                    invoke      EnableWindow, hNextBtn, 1
                    mov         state, 2
                .ELSEIF     ax == 6             ; next filtering
                    invoke      SendMessage, hListBox, LB_RESETCONTENT, 0, 0
                    invoke      GetDlgItemInt, hMainWnd, 8, NULL, 0
                    mov         filterVal, eax
                    invoke      FilterValueTwo, filterVal, pid, hListBox
                    mov         state, 2
                .ELSEIF     ax == 14            ; edit
                    invoke      GetDlgItemInt, hMainWnd, 13, NULL, 0
                    mov         writeData, eax
                    invoke      Modify, pid, writeAddr, writeData
                    invoke      MessageBox, hMainWnd, ADDR successMsg, ADDR windowName, MB_OK
                .ENDIF
            .ELSEIF         bx == LBN_SELCHANGE ; listbox
                invoke          SendMessage, hListBox, LB_GETCURSEL, 0, 0
                invoke          SendMessage, hListBox, LB_GETITEMDATA, eax, 0
                invoke          FetchAddr, eax, ADDR writeAddr
                invoke          sprintf, OFFSET buffer, OFFSET addrMsg, writeAddr
                invoke          SetWindowText, hAddrEdit, OFFSET buffer
            .ENDIF
        .ENDIF
        jmp         WinProcExit

    .ELSE                        ; other message
        invoke      DefWindowProc, hWnd, localMsg, wParam, lParam
        jmp         WinProcExit
    .ENDIF

WinProcExit:
    ret
WinProc ENDP

END                 WinMain
