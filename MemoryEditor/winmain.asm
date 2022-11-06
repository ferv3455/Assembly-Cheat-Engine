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
NUM_EDIT_STYLE = WS_CHILD+WS_VISIBLE+WS_BORDER+ES_NUMBER
TEXT_EDIT_STYLE = WS_CHILD+WS_VISIBLE+WS_BORDER
ADDR_STYLE = WS_CHILD+WS_VISIBLE
TEXT_STYLE = WS_CHILD+WS_VISIBLE
LISTBOX_STYLE = WS_CHILD+WS_VISIBLE+WS_VSCROLL+LBS_NOTIFY+WS_BORDER
COMBOBOX_STYLE = WS_CHILD+WS_VISIBLE+CBS_DROPDOWNLIST+CBS_HASSTRINGS

.data
; <<<<<<<<<<<<<<<<<<<< Popup Messages >>>>>>>>>>>>>>>>>>>>>>>>>
errorTitle      BYTE        "Error", 0
noProcessText   BYTE        "No process is selected!", 0
enumFailText    BYTE        "Process enumeration failed!", 0
scanFailText    BYTE        "Scanning failed!", 0
modifyFailText  BYTE        "Editing failed!", 0
successMsg      BYTE        "Successfully rewrite memory.", 0

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
scanTpLabel     BYTE        "Condition: ", 0
valTpLabel      BYTE        "Value Type: ", 0
memOptLabel     BYTE        "Memory Scan Options:", 0
startLabel      BYTE        "Start: ", 0
stopLabel       BYTE        "Stop: ", 0


; <<<<<<<<<<<<<<<<<<<< Options of Scan Type >>>>>>>>>>>>>>>>>>>>>>>>>
scanTypeExact   BYTE        "Exact Value", 0
scanTypeBig     BYTE        "Greater than", 0
scanTypeBigEq   BYTE        "Not less than", 0
scanTypeSmall   BYTE        "Less than", 0
scanTypeSmallEq BYTE        "Not greater than", 0

; <<<<<<<<<<<<<<<<<<<< Options of Value Type >>>>>>>>>>>>>>>>>>>>>>>>>
valTypeByte     BYTE        "Byte", 0
valTypeWord     BYTE        "2 Bytes (Word)", 0
valTypeDWord    BYTE        "4 Bytes (DWord)", 0
valTypeQWord    BYTE        "8 Bytes (QWord)", 0
valTypeFloat    BYTE        "32-bit Float", 0
valTypeDouble   BYTE        "64-bit Double", 0

; <<<<<<<<<<<<<<<<<<<< Options of Address Step >>>>>>>>>>>>>>>>>>>>>>>>>
stepFast        BYTE        "Fast Scan", 0
stepByte        BYTE        "1-Byte Alignment", 0
stepWord        BYTE        "2-Byte Alignment", 0
stepDWord       BYTE        "4-Byte Alignment", 0

; <<<<<<<<<<<<<<<<<<<< Font names >>>>>>>>>>>>>>>>>>>>>>>>>
fontName        BYTE        "Segoe UI", 0
codeName        BYTE        "Courier New", 0

; <<<<<<<<<<<<<<<<<<<< Handles of Widgets >>>>>>>>>>>>>>>>>>>>>>>>>
hMainFont       DWORD       ?
hCodeFont       DWORD       ?
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
pid             DWORD       0
scanVal         ScanValue   <0, 4>
scanMode        ScanMode    <4, COND_EQ, DEFAULT_MEMMIN, DEFAULT_MEMMAX>
writeAddr       DWORD       ?
writeData       QWORD       ?
addrMsg         BYTE        "%08X", 0
hexMsg          BYTE        "%x", 0
longMsg         BYTE        "%llu", 0
intMsg          BYTE        "%u", 0
shortMsg        BYTE        "%hu", 0
byteMsg         BYTE        "%hhu", 0
floatMsg        BYTE        "%f", 0
doubleMsg       BYTE        "%lf", 0
buffer          BYTE        16 DUP(0)
valTypes        DWORD       TYPE_BYTE, TYPE_WORD, TYPE_DWORD, TYPE_QWORD, TYPE_REAL4, TYPE_REAL8

; <<<<<<<<<<<<<<<<<<<< Other data format >>>>>>>>>>>>>>>>>>>>>>>>>
msg             MSGStruct   <>
winRect         RECT        <>
hInstance       DWORD       ?

MainWin         WNDCLASS    <NULL, WinProc, NULL, NULL, NULL, NULL, NULL,  \
                            COLOR_WINDOW, NULL, windowClass>

.code
WinMain PROC
    ; <<<<<<<<<<<<<<<<<<<< Creating Fonts >>>>>>>>>>>>>>>>>>>>>>>>>
    invoke      CreateFont, 18, 0, 0, 0, FW_DONTCARE, FALSE, FALSE, FALSE,
                    DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
                    CLEARTYPE_QUALITY, DEFAULT_PITCH + FF_DONTCARE, OFFSET fontName
    mov         hMainFont, eax
    invoke      CreateFont, 16, 0, 0, 0, FW_DONTCARE, FALSE, FALSE, FALSE,
                    DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
                    CLEARTYPE_QUALITY, DEFAULT_PITCH + FF_DONTCARE, OFFSET codeName
    mov         hCodeFont, eax

    ; <<<<<<<<<<<<<<<<<<<< Creating Main Window >>>>>>>>>>>>>>>>>>>>>>>>>
    ; Get a handle to the current process.
    invoke      GetModuleHandle, NULL
    mov         hInstance, eax
    mov         MainWin.hInstance, eax

    ; Load the program's icon and cursor.
    IDI_ICON1 = 103
    invoke      LoadIcon, hInstance, IDI_ICON1
    mov         MainWin.hIcon, eax
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
                    LISTBOX_STYLE, 20, 20, 330, 575,
                    hMainWnd, 1, hInstance, NULL
    mov         hListBox, eax
    invoke      EnumProc, hListBox
    test        eax, eax
    jz          EnumSuccess
    invoke      MessageBox, hMainWnd, ADDR enumFailText, ADDR errorTitle, MB_OK
EnumSuccess:

    ; quit button
    invoke      CreateWindowEx, 0, ADDR buttonClass, ADDR quitBtn,
                    BUTTON_STYLE, 360, 20, 200, 30,
                    hMainWnd, 2, hInstance, NULL
    mov         hQuitBtn, eax

    ; select button
    invoke      CreateWindowEx, 0, ADDR buttonClass, ADDR selBtn,
                    BUTTON_STYLE, 360, 55, 200, 30,
                    hMainWnd, 3, hInstance, NULL
    mov         hSelectBtn, eax

    ; filtering label
    invoke      CreateWindowEx, 0, ADDR textClass, ADDR filtLabel,
                    TEXT_STYLE, 360, 110, 160, 20,             
                    hMainWnd, 4, hInstance, NULL
    mov         hFiltLabel, eax
    
    ; new button
    invoke      CreateWindowEx, 0, ADDR buttonClass, ADDR newBtn,
                    BUTTON_STYLE, 360, 135, 80, 30,             
                    hMainWnd, 5, hInstance, NULL
    mov         hNewBtn, eax

    ; first button
    invoke      CreateWindowEx, 0, ADDR buttonClass, ADDR firstBtn,
                    BUTTON_STYLE, 360, 135, 80, 30,             
                    hMainWnd, 26, hInstance, NULL
    mov         hFirstBtn, eax
    
    ; next button
    invoke      CreateWindowEx, 0, ADDR buttonClass, ADDR nextBtn,
                    BUTTON_STYLE, 480, 135, 80, 30,             
                    hMainWnd, 6, hInstance, NULL
    mov         hNextBtn, eax

    ; value label
    invoke      CreateWindowEx, 0, ADDR textClass, ADDR valLabel,
                    TEXT_STYLE, 360, 205, 80, 24,             
                    hMainWnd, 7, hInstance, NULL
    mov         hValLabel, eax

    ; value edit
    invoke      CreateWindowEx, 0, ADDR editClass, NULL,
                    TEXT_EDIT_STYLE, 440, 205, 120, 24,             
                    hMainWnd, 8, hInstance, NULL
    mov         hValEdit, eax

    ; edit label
    invoke      CreateWindowEx, 0, ADDR textClass, ADDR editLabel,
                    TEXT_STYLE, 360, 455, 260, 24,             
                    hMainWnd, 9, hInstance, NULL
    mov         hEditLabel, eax

    ; address label
    invoke      CreateWindowEx, 0, ADDR textClass, ADDR addrLabel,
                    TEXT_STYLE, 360, 485, 80, 24,             
                    hMainWnd, 10, hInstance, NULL
    mov         hAddrLabel, eax

    ; address edit
    invoke      CreateWindowEx, 0, ADDR editClass, NULL,
                    TEXT_EDIT_STYLE, 440, 485, 120, 24,             
                    hMainWnd, 11, hInstance, NULL
    mov         hAddrEdit, eax

    ; new value label
    invoke      CreateWindowEx, 0, ADDR textClass, ADDR newValLabel,
                    TEXT_STYLE, 360, 510, 80, 24,             
                    hMainWnd, 12, hInstance, NULL
    mov         hNewValLabel, eax

    ; new value edit
    invoke      CreateWindowEx, 0, ADDR editClass, NULL,
                    TEXT_EDIT_STYLE, 440, 510, 120, 24,             
                    hMainWnd, 13, hInstance, NULL
    mov         hNewValEdit, eax

    ; edit button
    invoke      CreateWindowEx, 0, ADDR buttonClass, ADDR editBtn,
                    BUTTON_STYLE, 360, 545, 200, 30,
                    hMainWnd, 14, hInstance, NULL
    mov         hEditBtn, eax

    ; loading label
    invoke      CreateWindowEx, 0, ADDR textClass, ADDR loadingLabel,
                    TEXT_STYLE, 360, 20, 200, 600,             
                    hMainWnd, 15, hInstance, NULL
    mov         hLoadingLabel, eax
    invoke      ShowWindow, hLoadingLabel, SW_HIDE

    ; scantype label
    invoke      CreateWindowEx, 0, ADDR textClass, ADDR scanTpLabel,
                    TEXT_STYLE, 360, 175, 80, 24,
                    hMainWnd, 16, hInstance, NULL
    mov         hScanTpLabel, eax

    ; scantype combobox
    invoke      CreateWindowEx, 0, ADDR comboClass, NULL,
                    COMBOBOX_STYLE, 440, 175, 120, 120,            
                    hMainWnd, 17, hInstance, NULL
    mov         hScanTpCmbox, eax
    invoke      SendMessage, hScanTpCmbox, CB_ADDSTRING, NULL, ADDR scanTypeBig
    invoke      SendMessage, hScanTpCmbox, CB_ADDSTRING, NULL, ADDR scanTypeBigEq
    invoke      SendMessage, hScanTpCmbox, CB_ADDSTRING, NULL, ADDR scanTypeExact
    invoke      SendMessage, hScanTpCmbox, CB_ADDSTRING, NULL, ADDR scanTypeSmallEq
    invoke      SendMessage, hScanTpCmbox, CB_ADDSTRING, NULL, ADDR scanTypeSmall
    invoke      SendMessage, hScanTpCmbox, CB_SETCURSEL, 2, NULL

    ; valuetype label
    invoke      CreateWindowEx, 0, ADDR textClass, ADDR valTpLabel,
                    TEXT_STYLE, 360, 330, 80, 24,             
                    hMainWnd, 18, hInstance, NULL
    mov         hValTpLabel, eax

    ; valuetype combobox
    invoke      CreateWindowEx, 0, ADDR comboClass, NULL,
                    COMBOBOX_STYLE, 440, 330, 120, 160,             
                    hMainWnd, 19, hInstance, NULL
    mov         hValTpCmbox, eax
    invoke      SendMessage, hValTpCmbox, CB_ADDSTRING, NULL, ADDR valTypeByte
    invoke      SendMessage, hValTpCmbox, CB_ADDSTRING, NULL, ADDR valTypeWord
    invoke      SendMessage, hValTpCmbox, CB_ADDSTRING, NULL, ADDR valTypeDWord
    invoke      SendMessage, hValTpCmbox, CB_ADDSTRING, NULL, ADDR valTypeQWord
    invoke      SendMessage, hValTpCmbox, CB_ADDSTRING, NULL, ADDR valTypeFloat
    invoke      SendMessage, hValTpCmbox, CB_ADDSTRING, NULL, ADDR valTypeDouble
    invoke      SendMessage, hValTpCmbox, CB_SETCURSEL, 2, NULL

    ; memory scan option label
    invoke      CreateWindowEx, 0, ADDR textClass, ADDR memOptLabel,
                    TEXT_STYLE, 360, 275, 150, 24,
                    hMainWnd, 20, hInstance, NULL
    mov         hMemOptLabel, eax

    ; memory scan option combobox
    invoke      CreateWindowEx, 0, ADDR comboClass, NULL,
                    COMBOBOX_STYLE + WS_VSCROLL, 360, 300, 200, 120,             
                    hMainWnd, 21, hInstance, NULL
    mov         hMemOptCmbox, eax
    invoke      SendMessage, hMemOptCmbox, CB_ADDSTRING, NULL, ADDR stepFast
    invoke      SendMessage, hMemOptCmbox, CB_ADDSTRING, NULL, ADDR stepByte
    invoke      SendMessage, hMemOptCmbox, CB_ADDSTRING, NULL, ADDR stepWord
    invoke      SendMessage, hMemOptCmbox, CB_ADDSTRING, NULL, ADDR stepDWord
    invoke      SendMessage, hMemOptCmbox, CB_SETCURSEL, 0, NULL

    ; start label
    invoke      CreateWindowEx, 0, ADDR textClass, ADDR startLabel,
                    TEXT_STYLE, 360, 360, 40, 24,
                    hMainWnd, 22, hInstance, NULL
    mov         hStartLabel, eax

    ; stop label
    invoke      CreateWindowEx, 0, ADDR textClass, ADDR stopLabel,
                    TEXT_STYLE, 360, 390, 40, 24,
                    hMainWnd, 23, hInstance, NULL
    mov         hStopLabel, eax

    ; start edit
    invoke      CreateWindowEx, 0, ADDR editClass, NULL,
                    TEXT_EDIT_STYLE, 400, 360, 160, 24,             
                    hMainWnd, 24, hInstance, NULL
    mov         hStartEdit, eax
    invoke      sprintf, OFFSET buffer, OFFSET addrMsg, DEFAULT_MEMMIN
    invoke      SetWindowText, hStartEdit, OFFSET buffer

    ; stop edit
    invoke      CreateWindowEx, 0, ADDR editClass, NULL,
                    TEXT_EDIT_STYLE, 400, 390, 160, 24,             
                    hMainWnd, 25, hInstance, NULL
    mov         hStopEdit, eax
    invoke      sprintf, OFFSET buffer, OFFSET addrMsg, DEFAULT_MEMMAX
    invoke      SetWindowText, hStopEdit, OFFSET buffer

    ; <<<<<<<<<<<<<<<<<<<< Set fonts of all windows >>>>>>>>>>>>>>>>>>>>>>>>>
    invoke      SetChildFont, hMainWnd, hMainFont
    invoke      EnumChildWindows, hMainWnd, SetChildFont, hMainFont
    invoke      SetChildFont, hListBox, hCodeFont

    ; <<<<<<<<<<<<<<<<<<<< Displaying MainWindow >>>>>>>>>>>>>>>>>>>>>>>>>
    invoke      ShowWindow, hMainWnd, SW_SHOW
    invoke      UpdateWindow, hMainWnd
    invoke      AdjWidgetState, 0

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
            mov         pid, 0
            mov         state, 0
            invoke      AdjWidgetState, 0
            invoke      SendMessage, hListBox, LB_RESETCONTENT, 0, 0
            invoke      EnumProc, hListBox
            test        eax, eax
            jz          EnumSuccess
            invoke      MessageBox, hMainWnd, ADDR enumFailText, 
                            ADDR errorTitle, MB_OK
            jmp         WinProcExit
        EnumSuccess:

        .ELSEIF     state == 0           ; selecting process
            .IF             bx == LBN_SELCHANGE            ; listbox
                invoke      SendMessage, hListBox, LB_GETCURSEL, 0, 0
                invoke      SendMessage, hListBox, LB_GETITEMDATA, eax, 0
                invoke      FetchProc, eax, ADDR pid
            .ELSEIF         ax == 3 && bx == BN_CLICKED    ; select current process
                mov         edx, pid
                test        edx, edx
                jnz         ProcessSelected
                invoke      MessageBox, hMainWnd, ADDR noProcessText,
	                            ADDR errorTitle, MB_OK
                jmp         WinProcExit
            ProcessSelected:
                mov         state, 1
                invoke      AdjWidgetState, 1
                invoke      SendMessage, hListBox, LB_RESETCONTENT, 0, 0
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
                    mov         state, 2
                    invoke      AdjWidgetState, 2
                .ELSEIF     ax == 6             ; next filtering
                    jmp         NextScan
                .ELSEIF     ax == 14            ; edit
                    jmp         ModifyAddr
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
    invoke          SendMessage, hValTpCmbox, CB_GETCURSEL, 0, 0
    mov             eax, valTypes[eax * TYPE valTypes]
    mov             scanVal.valSize, eax
    invoke          ReadValue, OFFSET scanVal.value, 8, scanVal.valSize

    ; Get configurations
    invoke          SendMessage, hScanTpCmbox, CB_GETCURSEL, 0, 0
    mov             scanMode.condition, eax

    invoke          SendMessage, hMemOptCmbox, CB_GETCURSEL, 0, 0
    .IF             eax == 0
        mov             eax, scanVal.valSize
        mov             scanMode.step, eax
        .IF             eax > 4
            mov             scanMode.step, 4
        .ENDIF
    .ELSEIF         eax == 1
        mov         scanMode.step, 1
    .ELSEIF         eax == 2
        mov         scanMode.step, 2
    .ELSEIF         eax == 3
        mov         scanMode.step, 4
    .ENDIF

    invoke          ReadValue, OFFSET scanMode.memMin, 24, 1024
    invoke          ReadValue, OFFSET scanMode.memMax, 25, 1024

    ; First scan
    invoke          FilterValue, pid, hListBox, scanVal, scanMode
    test            eax, eax
    jz              ScanFailed

    ; End
    invoke          ShowWindow, hLoadingLabel, SW_HIDE
    invoke          UpdateWindow, hLoadingLabel
    jmp             WinProcExit

NextScan:
    ; Begin
    invoke          ShowWindow, hLoadingLabel, SW_SHOW
    invoke          UpdateWindow, hLoadingLabel
    invoke          SendMessage, hListBox, LB_RESETCONTENT, 0, 0

    ; Get value
    invoke          SendMessage, hValTpCmbox, CB_GETCURSEL, 0, 0
    mov             eax, valTypes[eax * TYPE valTypes]
    mov             scanVal.valSize, eax
    invoke          ReadValue, OFFSET scanVal.value, 8, scanVal.valSize

    ; Get configurations
    invoke          SendMessage, hScanTpCmbox, CB_GETCURSEL, 0, 0
    mov             scanMode.condition, eax

    ; Next scan
    invoke          FilterValueTwo, pid, hListBox, scanVal, scanMode.condition
    test            eax, eax
    jz              ScanFailed

    ; End
    invoke          ShowWindow, hLoadingLabel, SW_HIDE
    invoke          UpdateWindow, hLoadingLabel
    jmp             WinProcExit

ScanFailed:
    invoke          MessageBox, hMainWnd, ADDR scanFailText, ADDR errorTitle, MB_OK
    jmp             WinProcExit

SelectAddr:
    invoke          SendMessage, hListBox, LB_GETCURSEL, 0, 0   
    invoke          SendMessage, hListBox, LB_GETITEMDATA, eax, 0
    invoke          FetchAddr, eax, ADDR writeAddr
    invoke          sprintf, OFFSET buffer, OFFSET addrMsg, writeAddr
    invoke          SetWindowText, hAddrEdit, OFFSET buffer
    jmp             WinProcExit

ModifyAddr:
    invoke          ReadValue, OFFSET writeAddr, 11, 1024
    invoke          ReadValue, OFFSET writeData, 13, scanVal.valSize
    invoke          Modify, pid, writeAddr, writeData, scanVal.valSize
    test            eax, eax
    jnz             ModifyFailed
    invoke          MessageBox, hMainWnd, ADDR successMsg, ADDR windowName, MB_OK
    jmp             WinProcExit

ModifyFailed:
    invoke          MessageBox, NULL, ADDR modifyFailText, ADDR errorTitle, MB_OK
    jmp             WinProcExit

WinProcExit:
    ret
WinProc ENDP


; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
SetChildFont PROC,
    hwnd:       DWORD,
    lParam:     DWORD
; Set widget font.
; Always return TRUE.
; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
    invoke          SendMessage, hwnd, WM_SETFONT, lParam, TRUE
    mov             eax, TRUE
    ret
SetChildFont ENDP


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
    invoke      EnableWindow, hFiltLabel, 1
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
    invoke      EnableWindow, hEditLabel, 1
    invoke      EnableWindow, hAddrLabel, 1
    invoke      EnableWindow, hAddrEdit, 1
    invoke      EnableWindow, hNewValLabel, 1
    invoke      EnableWindow, hNewValEdit, 1
    invoke      EnableWindow, hEditBtn, 1
    
    ; IF-conditions
    .IF             newState == 0
        invoke      EnableWindow, hSelectBtn, 1
        invoke      EnableWindow, hFiltLabel, 0
        invoke      EnableWindow, hEditLabel, 0
        invoke      EnableWindow, hAddrLabel, 0
        invoke      EnableWindow, hAddrEdit, 0
        invoke      EnableWindow, hNewValLabel, 0
        invoke      EnableWindow, hNewValEdit, 0
        invoke      EnableWindow, hEditBtn, 0
    .ELSEIF         newState == 1
        invoke      EnableWindow, hQuitBtn, 1
        invoke      EnableWindow, hNewBtn, 1
    .ELSEIF         newState == 2
        invoke      ShowWindow, hNewBtn, SW_HIDE
        invoke      ShowWindow, hFirstBtn, SW_SHOW
        invoke      EnableWindow, hQuitBtn, 1
        invoke      EnableWindow, hFirstBtn, 1
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


; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
ReadValue PROC,
    dest:       PTR QWORD,      ; Destination address (always in the first byte)
    id:         DWORD,          ; child window id
    vSize:      DWORD           ; Size of data
; Get different type of input from the widget. Save it in the given address.
; No return value.
; ««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««    
    invoke      GetDlgItemText, hMainWnd, id, OFFSET buffer, LENGTHOF buffer
    .IF         vSize == TYPE_QWORD
        invoke      sscanf, OFFSET buffer, OFFSET longMsg, dest
    .ELSEIF     vSize == TYPE_DWORD
        invoke      sscanf, OFFSET buffer, OFFSET intMsg, dest
    .ELSEIF     vSize == TYPE_WORD
        invoke      sscanf, OFFSET buffer, OFFSET shortMsg, dest
    .ELSEIF     vSize == TYPE_BYTE
        invoke      sscanf, OFFSET buffer, OFFSET byteMsg, dest
    .ELSEIF     vSize == TYPE_REAL4
        invoke      sscanf, OFFSET buffer, OFFSET floatMsg, dest
    .ELSEIF     vSize == TYPE_REAL8
        invoke      sscanf, OFFSET buffer, OFFSET doubleMsg, dest
    .ELSE
        invoke      sscanf, OFFSET buffer, OFFSET hexMsg, dest
    .ENDIF
    ret
ReadValue ENDP


; END
END                 WinMain
