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
EDIT_STYLE = WS_CHILD+WS_VISIBLE+WS_BORDER+ES_NUMBER
ADDR_STYLE = WS_CHILD+WS_VISIBLE
TEXT_STYLE = WS_CHILD+WS_VISIBLE
; LISTBOX_STYLE = WS_CHILD+WS_VISIBLE+WS_VSCROLL+LBS_NOTIFY+WS_BORDER+LBS_MULTICOLUMN
LISTBOX_STYLE = WS_CHILD+WS_VISIBLE+WS_VSCROLL+LBS_NOTIFY+WS_BORDER
COMBOBOX_STYLE = WS_CHILD+WS_VISIBLE+CBS_DROPDOWNLIST+CBS_HASSTRINGS

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
firstBtn        BYTE        "First", 0
filtLabel       BYTE        "Filtering Address: ", 0
valLabel        BYTE        "Value: ", 0
editLabel       BYTE        "Edit Memory: ", 0
addrLabel       BYTE        "Address: ", 0
newValLabel     BYTE        "New Value: ", 0
editBtn         BYTE        "Edit", 0
loadingLabel    BYTE        "LOADING ...", 0
scanTpLabel     BYTE        "Scan Type", 0
valTpLabel      BYTE        "Value Type", 0
memOptLabel     BYTE        "Memory Scan Options", 0
startLabel      BYTE        "Start", 0
stopLabel       BYTE        "Stop", 0


; <<<<<<<<<<<<<<<<<<<< Options of Scan Type >>>>>>>>>>>>>>>>>>>>>>>>>
scanTypeExact   BYTE        "Exact Value", 0
scanTypeBig     BYTE        "Bigger than...", 0
scanTypeSmall   BYTE        "Smaller than...", 0
scanTypeBwt     BYTE        "Value between...", 0
scanTypeUkwn    BYTE        "Unknown initial value", 0

; <<<<<<<<<<<<<<<<<<<< Options of Value Type >>>>>>>>>>>>>>>>>>>>>>>>>
valTypeByte     BYTE        "Byte", 0
valTypeWord     BYTE        "2 Bytes", 0
valTypeDWord    BYTE        "4 Bytes", 0

; <<<<<<<<<<<<<<<<<<<< Handles of Widgets >>>>>>>>>>>>>>>>>>>>>>>>>
hMainWnd        DWORD       ?
hListBox        DWORD       ?
hQuitBtn        DWORD       ?
hSelectBtn      DWORD       ?
hFiltLabel      DWORD       ?
hNewBtn         DWORD       ?
hFirstBtn       DWORD       ?
hNextBtn        DWORD       ?
hValLabel       DWORD       ?
hValEdit        DWORD       ?
hEditLabel      DWORD       ?
hAddrLabel      DWORD       ?
hAddrEdit       DWORD       ?
hNewValLabel    DWORD       ?
hNewValEdit     DWORD       ?
hEditBtn        DWORD       ?
hLoadingLabel   DWORD       ?
hScanTpLabel    DWORD       ?
hScanTpCmbox    DWORD       ?
hValTpLabel     DWORD       ?
hValTpCmbox     DWORD       ?
hMemOptLabel    DWORD       ?
hMemOptCmbox    DWORD       ?
hStartEdit      DWORD       ?
hStopEdit       DWORD       ?
hStartLabel     DWORD       ?
hStopLabel      DWORD       ?

; <<<<<<<<<<<<<<<<<<<< Main Logics >>>>>>>>>>>>>>>>>>>>>>>>>
state           DWORD       0
pid             DWORD       ?
scanVal         ScanValue   <0, 4>
scanMode        ScanMode    <4, COND_EQ, DEFAULT_MEMMIN, DEFAULT_MEMMAX>
writeAddr       DWORD       ?
writeData       DWORD       ?
addrMsg         BYTE        "%08X", 0
buffer          BYTE        16 DUP(0)
successMsg      BYTE        "Successfully rewrite memory.", 0
valTypes        DWORD       1, 2, 4

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
                    600, 640, NULL, NULL, hInstance, NULL   ; Main Window WIDTH, HEIGHT
    mov         hMainWnd, eax

    ; If CreateWindowEx failed, display a message & exit.
    .IF eax == 0
        jmp     Exit_Program
    .ENDIF

    ; <<<<<<<<<<<<<<<<<<<< Creating widgets >>>>>>>>>>>>>>>>>>>>>>>>>
    ; main listbox
    invoke      CreateWindowEx, 0, ADDR listboxClass, NULL, 
                    LISTBOX_STYLE, 20, 20, 330, 560,
                    hMainWnd, 1, hInstance, NULL
    mov         hListBox, eax
    invoke      EnumProc, hListBox

    ; quit button
    invoke      CreateWindowEx, 0, ADDR buttonClass, ADDR quitBtn,
                    BUTTON_STYLE, 360, 20, 200, 40,
                    hMainWnd, 2, hInstance, NULL
    mov         hQuitBtn, eax

    ; select button
    invoke      CreateWindowEx, 0, ADDR buttonClass, ADDR selBtn,
                    BUTTON_STYLE, 360, 70, 200, 40,
                    hMainWnd, 3, hInstance, NULL
    mov         hSelectBtn, eax

    ; filtering label
    invoke      CreateWindowEx, 0, ADDR textClass, ADDR filtLabel,
                    TEXT_STYLE, 360, 190, 160, 20,             
                    hMainWnd, 4, hInstance, NULL
    mov         hFiltLabel, eax
    
    ; new button
    invoke      CreateWindowEx, 0, ADDR buttonClass, ADDR newBtn,
                    BUTTON_STYLE, 360, 210, 80, 30,             
                    hMainWnd, 5, hInstance, NULL
    mov         hNewBtn, eax

    ; first button
    invoke      CreateWindowEx, 0, ADDR buttonClass, ADDR firstBtn,
                    BUTTON_STYLE, 360, 210, 80, 30,             
                    hMainWnd, 26, hInstance, NULL
    mov         hFirstBtn, eax
    
    ; next button
    invoke      CreateWindowEx, 0, ADDR buttonClass, ADDR nextBtn,
                    BUTTON_STYLE, 480, 210, 80, 30,             
                    hMainWnd, 6, hInstance, NULL
    mov         hNextBtn, eax

    ; value label
    invoke      CreateWindowEx, 0, ADDR textClass, ADDR valLabel,
                    TEXT_STYLE, 360, 250, 80, 30,             
                    hMainWnd, 7, hInstance, NULL
    mov         hValLabel, eax

    ; value edit
    invoke      CreateWindowEx, 0, ADDR editClass, NULL,
                    EDIT_STYLE, 440, 250, 120, 30,             
                    hMainWnd, 8, hInstance, NULL
    mov         hValEdit, eax

    ; edit label
    invoke      CreateWindowEx, 0, ADDR textClass, ADDR editLabel,
                    TEXT_STYLE, 360, 430, 260, 30,             
                    hMainWnd, 9, hInstance, NULL
    mov         hEditLabel, eax

    ; address label
    invoke      CreateWindowEx, 0, ADDR textClass, ADDR addrLabel,
                    TEXT_STYLE, 360, 460, 60, 30,             
                    hMainWnd, 10, hInstance, NULL
    mov         hAddrLabel, eax

    ; address edit
    invoke      CreateWindowEx, 0, ADDR editClass, NULL,
                    EDIT_STYLE, 440, 460, 120, 30,             
                    hMainWnd, 11, hInstance, NULL
    mov         hAddrEdit, eax

    ; new value label
    invoke      CreateWindowEx, 0, ADDR textClass, ADDR newValLabel,
                    TEXT_STYLE, 360, 500, 120, 30,             
                    hMainWnd, 12, hInstance, NULL
    mov         hNewValLabel, eax

    ; new value edit
    invoke      CreateWindowEx, 0, ADDR editClass, NULL,
                    EDIT_STYLE, 440, 500, 120, 30,             
                    hMainWnd, 13, hInstance, NULL
    mov         hNewValEdit, eax

    ; edit button
    invoke      CreateWindowEx, 0, ADDR buttonClass, ADDR editBtn,
                    BUTTON_STYLE, 360, 540, 200, 40,
                    hMainWnd, 14, hInstance, NULL
    mov         hEditBtn, eax

    ; loading label
    invoke      CreateWindowEx, 0, ADDR textClass, ADDR loadingLabel,
                    TEXT_STYLE, 360, 300, 120, 40,             
                    hMainWnd, 15, hInstance, NULL
    mov         hLoadingLabel, eax
    invoke      ShowWindow, hLoadingLabel, SW_HIDE

    ; scantype label
    invoke      CreateWindowEx, 0, ADDR textClass, ADDR scanTpLabel,
                    TEXT_STYLE, 360, 120, 80, 30,
                    hMainWnd, 16, hInstance, NULL
    mov         hScanTpLabel, eax

    ; scantype combobox
    invoke      CreateWindowEx, 0, ADDR comboClass, NULL,
                    COMBOBOX_STYLE, 440, 120, 120, 120,            
                    hMainWnd, 17, hInstance, NULL
    mov         hScanTpCmbox, eax
    invoke      SendMessage, hScanTpCmbox, CB_ADDSTRING, NULL, ADDR scanTypeExact
    invoke      SendMessage, hScanTpCmbox, CB_ADDSTRING, NULL, ADDR scanTypeBig
    invoke      SendMessage, hScanTpCmbox, CB_ADDSTRING, NULL, ADDR scanTypeSmall
    invoke      SendMessage, hScanTpCmbox, CB_ADDSTRING, NULL, ADDR scanTypeUkwn

    ; valuetype label
    invoke      CreateWindowEx, 0, ADDR textClass, ADDR valTpLabel,
                    TEXT_STYLE, 360, 160, 80, 30,             
                    hMainWnd, 18, hInstance, NULL
    mov         hValTpLabel, eax

    ; valuetype combobox
    invoke      CreateWindowEx, 0, ADDR comboClass, NULL,
                    COMBOBOX_STYLE, 440, 160, 120, 120,             
                    hMainWnd, 19, hInstance, NULL
    mov         hValTpCmbox, eax
    invoke      SendMessage, hValTpCmbox, CB_ADDSTRING, NULL, ADDR valTypeByte
    invoke      SendMessage, hValTpCmbox, CB_ADDSTRING, NULL, ADDR valTypeWord
    invoke      SendMessage, hValTpCmbox, CB_ADDSTRING, NULL, ADDR valTypeDWord
    invoke      SendMessage, hValTpCmbox, CB_SETCURSEL, 2, NULL

    ; memory scan option label
    invoke      CreateWindowEx, 0, ADDR textClass, ADDR memOptLabel,
                    TEXT_STYLE, 360, 290, 150, 30,
                    hMainWnd, 20, hInstance, NULL
    mov         hMemOptLabel, eax

    ; memory scan option combobox
    invoke      CreateWindowEx, 0, ADDR comboClass, NULL,
                    COMBOBOX_STYLE + WS_VSCROLL, 360, 315, 200, 120,             
                    hMainWnd, 21, hInstance, NULL
    mov         hMemOptCmbox, eax

    ; start label
    invoke      CreateWindowEx, 0, ADDR textClass, ADDR startLabel,
                    TEXT_STYLE, 360, 350, 40, 30,
                    hMainWnd, 22, hInstance, NULL
    mov         hStartLabel, eax

    ; stop label
    invoke      CreateWindowEx, 0, ADDR textClass, ADDR stopLabel,
                    TEXT_STYLE, 360, 390, 40, 30,
                    hMainWnd, 23, hInstance, NULL
    mov         hStopLabel, eax

    ; start edit
    invoke      CreateWindowEx, 0, ADDR editClass, NULL,
                    EDIT_STYLE, 400, 350, 160, 30,             
                    hMainWnd, 24, hInstance, NULL
    mov         hStartEdit, eax

    ; stop edit
    invoke      CreateWindowEx, 0, ADDR editClass, NULL,
                    EDIT_STYLE, 400, 390, 160, 30,             
                    hMainWnd, 25, hInstance, NULL
    mov         hStopEdit, eax

    ; <<<<<<<<<<<<<<<<<<<< Displaying MainWindow >>>>>>>>>>>>>>>>>>>>>>>>>
    invoke      ShowWindow, hMainWnd, SW_SHOW
    invoke      UpdateWindow, hMainWnd
    invoke      AdjWidgetState, 0

    ; <<<<<<<<<<<<<<<<<<<< Adjust Listbox Width >>>>>>>>>>>>>>>>>>>>>>>>>
    ; invoke      SendMessage, hListBox, LB_SETCOLUMNWIDTH, 360, 0

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
        .IF         ax == 2 && bx == BN_CLICKED            ; quit current process
            mov         state, 0
            invoke      AdjWidgetState, 0
            invoke      SendMessage, hListBox, LB_RESETCONTENT, 0, 0
            invoke      EnumProc, hListBox
            ; invoke      SendMessage, hListBox, LB_SETCOLUMNWIDTH, 360, 0
        .ELSEIF     state == 0           ; selecting process
            .IF             bx == LBN_SELCHANGE            ; listbox
                invoke      SendMessage, hListBox, LB_GETCURSEL, 0, 0
                invoke      SendMessage, hListBox, LB_GETITEMDATA, eax, 0
                invoke      FetchProc, eax, ADDR pid
            .ELSEIF         ax == 3 && bx == BN_CLICKED    ; select current process
                mov         state, 1
                invoke      AdjWidgetState, 1
                invoke      SendMessage, hListBox, LB_RESETCONTENT, 0, 0
                ; invoke      SendMessage, hListBox, LB_SETCOLUMNWIDTH, 180, 0
            .ENDIF
        .ELSEIF     state == 1           ; process selected, before new
            .IF             ax == 5 && bx == BN_CLICKED    ; create a new scan
                mov         state, 2
                invoke      AdjWidgetState, 2
            .ENDIF
        .ELSEIF     state == 2           ; ready for first scan
            .IF             ax == 26 && bx == BN_CLICKED   ; first scan
                mov         state, 3
                invoke      AdjWidgetState, 3
                jmp         NewScan
            .ENDIF
        .ELSEIF     state == 3           ; after first scan
            .IF             bx == BN_CLICKED    ; button
                .IF         ax == 5             ; new filtering
                    jmp         NewScan
                .ELSEIF     ax == 6             ; next filtering
                    jmp         NextScan
                .ELSEIF     ax == 14            ; edit
                    invoke      GetDlgItemInt, hMainWnd, 13, NULL, 0
                    mov         writeData, eax
                    invoke      Modify, pid, writeAddr, writeData, 4
                    invoke      MessageBox, hMainWnd, ADDR successMsg, ADDR windowName, MB_OK
                .ENDIF
            .ELSEIF         bx == LBN_SELCHANGE ; listbox
                jmp         SelectAddr
            .ENDIF
        .ENDIF
        jmp         WinProcExit

    .ELSE                        ; other message
        invoke      DefWindowProc, hWnd, localMsg, wParam, lParam
        jmp         WinProcExit
    .ENDIF
    jmp             WinProcExit

NewScan:
    ; Begin
    invoke          ShowWindow, hLoadingLabel, SW_SHOW
    invoke          UpdateWindow, hLoadingLabel
    invoke          SendMessage, hListBox, LB_RESETCONTENT, 0, 0

    ; Get value
    invoke          GetDlgItemInt, hMainWnd, 8, NULL, 0
    mov             scanVal.value, eax
    invoke          SendMessage, hValTpCmbox, CB_GETCURSEL, 0, 0
    mov             eax, valTypes[eax * TYPE valTypes]
    mov             scanVal.valSize, eax

    ; First scan
    invoke          FilterValue, pid, hListBox, scanVal, scanMode

    ; End
    invoke          ShowWindow, hLoadingLabel, SW_HIDE
    invoke          UpdateWindow, hLoadingLabel
    jmp             WinProcExit

NextScan:
    invoke          ShowWindow, hLoadingLabel, SW_SHOW
    invoke          UpdateWindow, hLoadingLabel
    invoke          SendMessage, hListBox, LB_RESETCONTENT, 0, 0
    invoke          GetDlgItemInt, hMainWnd, 8, NULL, 0
    mov             scanVal.value, eax
    invoke          FilterValueTwo, pid, hListBox, scanVal
    invoke          ShowWindow, hLoadingLabel, SW_HIDE
    invoke          UpdateWindow, hLoadingLabel
    jmp             WinProcExit

SelectAddr:
    invoke          SendMessage, hListBox, LB_GETCURSEL, 0, 0   
    invoke          SendMessage, hListBox, LB_GETITEMDATA, eax, 0
    invoke          FetchAddr, eax, ADDR writeAddr
    invoke          sprintf, OFFSET buffer, OFFSET addrMsg, writeAddr
    invoke          SetWindowText, hAddrEdit, OFFSET buffer
    jmp             WinProcExit

WinProcExit:
    ret
WinProc ENDP


; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
AdjWidgetState PROC,
    newState:   DWORD
; Adjust widget accessibility according to app state.
; No return value.
; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
    ; Process selection
    invoke      EnableWindow, hQuitBtn, 0
    invoke      EnableWindow, hSelectBtn, 0

    ; Value related
    invoke      EnableWindow, hFiltLabel, 0
    invoke      EnableWindow, hScanTpLabel, 0
    invoke      EnableWindow, hScanTpCmbox, 0
    invoke      EnableWindow, hValLabel, 0
    invoke      EnableWindow, hValEdit, 0

    ; Scan buttons
    invoke      EnableWindow, hNewBtn, 0
    invoke      ShowWindow, hNewBtn, SW_SHOW
    invoke      EnableWindow, hFirstBtn, 0
    invoke      ShowWindow, hFirstBtn, SW_HIDE
    invoke      EnableWindow, hNextBtn, 0

    ; Configurations
    invoke      EnableWindow, hValTpLabel, 0
    invoke      EnableWindow, hValTpCmbox, 0
    invoke      EnableWindow, hMemOptLabel, 0
    invoke      EnableWindow, hMemOptCmbox, 0
    invoke      EnableWindow, hStartLabel, 0
    invoke      EnableWindow, hStartEdit, 0
    invoke      EnableWindow, hStopLabel, 0
    invoke      EnableWindow, hStopEdit, 0

    ; Editing
    invoke      EnableWindow, hEditLabel, 0
    invoke      EnableWindow, hAddrLabel, 0
    invoke      EnableWindow, hAddrEdit, 0
    invoke      EnableWindow, hNewValLabel, 0
    invoke      EnableWindow, hNewValEdit, 0
    invoke      EnableWindow, hEditBtn, 0
    
    ; IF-conditions
    .IF             newState == 0
        invoke      EnableWindow, hSelectBtn, 1
    .ELSEIF         newState == 1
        invoke      EnableWindow, hQuitBtn, 1
        invoke      EnableWindow, hNewBtn, 1
    .ELSEIF         newState == 2
        invoke      ShowWindow, hNewBtn, SW_HIDE
        invoke      ShowWindow, hFirstBtn, SW_SHOW
        invoke      EnableWindow, hQuitBtn, 1
        invoke      EnableWindow, hFirstBtn, 1
        invoke      EnableWindow, hFiltLabel, 1
        invoke      EnableWindow, hScanTpLabel, 1
        invoke      EnableWindow, hScanTpCmbox, 1
        invoke      EnableWindow, hValLabel, 1
        invoke      EnableWindow, hValEdit, 1
        invoke      EnableWindow, hValTpLabel, 1
        invoke      EnableWindow, hValTpCmbox, 1
        invoke      EnableWindow, hMemOptLabel, 1
        invoke      EnableWindow, hMemOptCmbox, 1
        invoke      EnableWindow, hStartLabel, 1
        invoke      EnableWindow, hStartEdit, 1
        invoke      EnableWindow, hStopLabel, 1
        invoke      EnableWindow, hStopEdit, 1
    .ELSEIF         newState == 3
        invoke      EnableWindow, hQuitBtn, 1
        invoke      EnableWindow, hNewBtn, 1
        invoke      EnableWindow, hNextBtn, 1
        invoke      EnableWindow, hFiltLabel, 1
        invoke      EnableWindow, hScanTpLabel, 1
        invoke      EnableWindow, hScanTpCmbox, 1
        invoke      EnableWindow, hValLabel, 1
        invoke      EnableWindow, hValEdit, 1
        invoke      EnableWindow, hEditLabel, 1
        invoke      EnableWindow, hAddrLabel, 1
        invoke      EnableWindow, hAddrEdit, 1
        invoke      EnableWindow, hNewValLabel, 1
        invoke      EnableWindow, hNewValEdit, 1
        invoke      EnableWindow, hEditBtn, 1
    .ENDIF
    ret
AdjWidgetState ENDP


; END
END                 WinMain
