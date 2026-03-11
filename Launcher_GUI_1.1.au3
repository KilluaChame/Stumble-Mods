#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <SliderConstants.au3>
#include <ListBoxConstants.au3>

#RequireAdmin

; ===============================
; VERSÃO E INFORMAÇÕES
; ===============================
Global Const $APP_VERSION = "1.1"
Global Const $APP_AUTHOR = "Mateus Chame"

; ===============================
; IDIOMA (PT = Português, EN = Inglês)
; ===============================
Global $LANGUAGE = "PT" ; Altere para "EN" para Inglês

; ===============================
; DICIONÁRIO DE TRADUÇÕES
; ===============================
Global $STRINGS[2][18] = [ _
    ["PT", "Aim Assist", "Plataforma Timer", "AFK Farm", "Transparência do Overlay (Fantasma)", "Iniciar", "Parar", "Fechar Todos [F11]", "Sobre - Stumble Mods", "Versão", "Desenvolvido por", "Uma suite completa de automação para Stumble Guys", "Módulos", "Pressione F11 para fechar todos os módulos", "Calibrar Pixels [AFK]", "Selecione o ponto:", "Capturar [Enter]", "Salvar e Fechar"], _
    ["EN", "Aim Assist", "Platform Timer", "AFK Farm", "Overlay Transparency (Ghost)", "Start", "Stop", "Close All [F11]", "About - Stumble Mods", "Version", "Developed by", "A complete automation suite for Stumble Guys", "Modules", "Press F11 to close all modules", "Calibrate Pixels [AFK]", "Select point:", "Capture [Enter]", "Save and Close"]]

; ===============================
; HOTKEYS
; ===============================
HotKeySet("{F7}", "_HK_AIM")
HotKeySet("{F8}", "_HK_PLAT")
HotKeySet("{F10}", "_HK_AFK")
HotKeySet("{F11}", "_HK_CLOSE_ALL")
HotKeySet("{F12}", "_HK_TOGGLE_LANGUAGE")

; ===============================
; CAMINHOS (Baseado em @ScriptDir - Portável)
; ===============================
Global Const $SCRIPT_AIMBOT = @ScriptDir & "\Aimbot\Aimbot_Teclado1.1_F7Close.exe"
Global Const $SCRIPT_PLATAFORMA = @ScriptDir & "\Plataforma\PlataformaTimer.exe"
Global Const $SCRIPT_AFK = @ScriptDir & "\AFK_FARM\AFK_Test_Modos.exe"
Global Const $SCRIPT_CALIBRAGEM = @ScriptDir & "\Calibragem\Calibragem.exe"
Global Const $OVERLAY_EXE = @ScriptDir & "\Overlay.exe"
Global Const $STATUS_INI = @ScriptDir & "\status.ini"
Global Const $PIXELS_INI = @ScriptDir & "\pixels.ini"

; ===============================
; SONS (Padrão Windows)
; ===============================
Global Const $SOUND_START = "C:\Windows\Media\Speech On.wav"
Global Const $SOUND_STOP = "C:\Windows\Media\Speech Off.wav"
Global Const $SOUND_EXIT = "C:\Windows\Media\Notify.wav"

; ===============================
; CORES
; ===============================
Global Const $COR_FUNDO    = 0x1E1E1E
Global Const $COR_BRANCO   = 0xFFFFFF
Global Const $COR_VERDE    = 0x2ECC71
Global Const $COR_VERMELHO = 0xE74C3C

; ===============================
; PIDs
; ===============================
Global $PID_Aimbot = 0
Global $PID_Plataforma = 0
Global $PID_AFK = 0
Global $PID_Overlay = 0

; Limpa processos antigos ao iniciar para evitar bugs
ProcessClose("Overlay.exe")

; ===============================
; STATUS INICIAL
; ===============================
IniWrite($STATUS_INI, "AIM", "on", "0")
IniWrite($STATUS_INI, "PLATAFORMA", "on", "0")
IniWrite($STATUS_INI, "AFK", "on", "0")
If IniRead($STATUS_INI, "CONFIG", "Alpha", "") = "" Then IniWrite($STATUS_INI, "CONFIG", "Alpha", "150")

; ===============================
; ABRE OVERLAY
; ===============================
If FileExists($OVERLAY_EXE) Then $PID_Overlay = Run($OVERLAY_EXE)

; ===============================
; GUI
; ===============================
Global $hGUI = GUICreate("Stumble Mods Launcher v" & $APP_VERSION, 340, 380)
GUISetBkColor($COR_FUNDO)

GUICtrlCreateLabel(_T(1), 20, 20, 120, 20)
GUICtrlSetColor(-1, $COR_BRANCO)
Global $btnAim = GUICtrlCreateButton(_T(5), 150, 15, 90, 30)
_SetButtonGreen($btnAim)

GUICtrlCreateLabel(_T(2), 20, 80, 140, 20)
GUICtrlSetColor(-1, $COR_BRANCO)
Global $btnPlat = GUICtrlCreateButton(_T(5), 150, 75, 90, 30)
_SetButtonGreen($btnPlat)

GUICtrlCreateLabel(_T(3), 20, 140, 120, 20)
GUICtrlSetColor(-1, $COR_BRANCO)
Global $btnAFK = GUICtrlCreateButton(_T(5), 150, 135, 90, 30)
_SetButtonGreen($btnAFK)

GUICtrlCreateLabel(_T(4), 20, 200, 300, 20)
GUICtrlSetColor(-1, $COR_BRANCO)
Global $sldAlpha = GUICtrlCreateSlider(20, 220, 300, 30)
GUICtrlSetLimit($sldAlpha, 255, 30)
GUICtrlSetData($sldAlpha, IniRead($STATUS_INI, "CONFIG", "Alpha", "150"))

Global $btnExit = GUICtrlCreateButton(_T(7), 70, 275, 160, 32)
_SetButtonRed($btnExit)

Global $btnLang = GUICtrlCreateButton($LANGUAGE, 240, 275, 40, 32)
GUICtrlSetFont($btnLang, 10, 800)
GUICtrlSetBkColor($btnLang, 0x3498DB)
GUICtrlSetColor($btnLang, $COR_BRANCO)

Global $btnAbout = GUICtrlCreateButton("?", 290, 275, 40, 32)
GUICtrlSetFont($btnAbout, 12, 800)
GUICtrlSetBkColor($btnAbout, 0x3498DB)
GUICtrlSetColor($btnAbout, $COR_BRANCO)

Global $btnCalibrar = GUICtrlCreateButton(_T(14), 20, 310, 300, 32)
GUICtrlSetBkColor($btnCalibrar, 0xF39C12)
GUICtrlSetColor($btnCalibrar, $COR_BRANCO)

GUISetState(@SW_SHOW)

; ===============================
; LOOP PRINCIPAL
; ===============================
Global $iLastAlpha = -1

While 1
    $msg = GUIGetMsg()
    Switch $msg
        Case $GUI_EVENT_CLOSE, $btnExit
            _FecharTudo()
        Case $btnAim
            _Toggle("AIM", $btnAim, $PID_Aimbot, $SCRIPT_AIMBOT)
        Case $btnPlat
            _Toggle("PLATAFORMA", $btnPlat, $PID_Plataforma, $SCRIPT_PLATAFORMA)
        Case $btnAFK
            _Toggle("AFK", $btnAFK, $PID_AFK, $SCRIPT_AFK)
        Case $btnAbout
            _MostrarSobre()
        Case $btnLang
            _AlternarIdioma()
        Case $btnCalibrar
            If FileExists($SCRIPT_CALIBRAGEM) Then Run($SCRIPT_CALIBRAGEM)
    EndSwitch

    Local $iCurrAlpha = GUICtrlRead($sldAlpha)
    If $iCurrAlpha <> $iLastAlpha Then
        IniWrite($STATUS_INI, "CONFIG", "Alpha", $iCurrAlpha)
        $iLastAlpha = $iCurrAlpha
    EndIf

    Sleep(20)
WEnd

; ===============================
; FUNÇÕES
; ===============================
Func _HK_AIM()
    _Toggle("AIM", $btnAim, $PID_Aimbot, $SCRIPT_AIMBOT)
EndFunc

Func _HK_PLAT()
    _Toggle("PLATAFORMA", $btnPlat, $PID_Plataforma, $SCRIPT_PLATAFORMA)
EndFunc

Func _HK_AFK()
    _Toggle("AFK", $btnAFK, $PID_AFK, $SCRIPT_AFK)
EndFunc

Func _HK_CLOSE_ALL()
    _FecharTudo()
EndFunc

Func _HK_TOGGLE_LANGUAGE()
    _AlternarIdioma()
EndFunc

Func _T($index)
    Local $langIndex = ($LANGUAGE = "EN") ? 1 : 0
    Return $STRINGS[$langIndex][$index]
EndFunc

Func _AlternarIdioma()
    If $LANGUAGE = "PT" Then
        $LANGUAGE = "EN"
    Else
        $LANGUAGE = "PT"
    EndIf
    
    GUICtrlSetData($btnLang, $LANGUAGE)
    
    ; Atualizar textos na GUI
    GUICtrlSetData($btnAim, _T(5))
    GUICtrlSetData($btnPlat, _T(5))
    GUICtrlSetData($btnAFK, _T(5))
    GUICtrlSetData($btnExit, _T(7))
    GUICtrlSetData($btnCalibrar, _T(14))
    
    ToolTip(_T(4) & ": " & _T(1), 10, 10)
    Sleep(2000)
    ToolTip("")
EndFunc

Func _Toggle($section, ByRef $btn, ByRef $pid, $path)
    If $pid = 0 Then
        $pid = Run($path)
        If @error Then 
            MsgBox(16, "Erro", "Não foi possível encontrar o arquivo:" & @CRLF & $path)
            Return
        EndIf
        SoundPlay($SOUND_START)
        IniWrite($STATUS_INI, $section, "on", "1")
        GUICtrlSetData($btn, _T(6))
        _SetButtonRed($btn)
    Else
        ProcessClose($pid)
        SoundPlay($SOUND_STOP)
        $pid = 0
        IniWrite($STATUS_INI, $section, "on", "0")
        GUICtrlSetData($btn, _T(5))
        _SetButtonGreen($btn)
    EndIf
EndFunc

Func _FecharTudo()
    SoundPlay($SOUND_EXIT)
    Sleep(300) 
    If $PID_Aimbot <> 0 Then ProcessClose($PID_Aimbot)
    If $PID_Plataforma <> 0 Then ProcessClose($PID_Plataforma)
    If $PID_AFK <> 0 Then ProcessClose($PID_AFK)
    If $PID_Overlay <> 0 Then ProcessClose($PID_Overlay)
    Exit
EndFunc

Func _SetButtonGreen($btn)
    GUICtrlSetBkColor($btn, $COR_VERDE)
    GUICtrlSetColor($btn, $COR_BRANCO)
EndFunc

Func _SetButtonRed($btn)
    GUICtrlSetBkColor($btn, $COR_VERMELHO)
    GUICtrlSetColor($btn, $COR_BRANCO)
EndFunc

Func _MostrarSobre()
    Local $txtSobre = "Stumble Mods Launcher" & @CRLF & @CRLF & _
        _T(9) & ": " & $APP_VERSION & @CRLF & _
        _T(10) & ": " & $APP_AUTHOR & @CRLF & @CRLF & _
        _T(11) & @CRLF & @CRLF & _
        _T(12) & ":" & @CRLF & _
        "  • Aim Assist (F7)" & @CRLF & _
        "  • " & _T(2) & " (F8)" & @CRLF & _
        "  • " & _T(3) & " (F10)" & @CRLF & @CRLF & _
        _T(13)
    
    MsgBox(0, _T(8), $txtSobre)
EndFunc

; Função auxiliar para transparência (igual ao overlay)
Func _SetTransparentColor($hWnd, $iColor)
    DllCall("user32.dll", "int", "SetLayeredWindowAttributes", "hwnd", $hWnd, "dword", $iColor, "byte", 255, "dword", 0x2)
EndFunc

; ===============================
; Nota: Código de calibração foi movido para script independente: Calibragem.au3
; O botão de calibração agora executa: @ScriptDir & "\Calibragem\Calibragem.exe"
; ===============================
