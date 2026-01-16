#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <SliderConstants.au3>

#RequireAdmin

; ===============================
; HOTKEYS
; ===============================
HotKeySet("{F7}", "_HK_AIM")
HotKeySet("{F8}", "_HK_PLAT")
HotKeySet("{F10}", "_HK_AFK")
HotKeySet("{F11}", "_HK_CLOSE_ALL")

; ===============================
; CAMINHOS (Verifique se os .exe existem nestes locais)
; ===============================
Global Const $SCRIPT_AIMBOT = "C:\Users\lizzi\OneDrive\Desktop\Jogos\Mods\Stumble\Aimbot\Aimbot_Teclado1.1_F7Close.exe"
Global Const $SCRIPT_PLATAFORMA = "C:\Users\lizzi\OneDrive\Desktop\Jogos\Mods\Stumble\Plataforma\PlataformaTimer.exe"
Global Const $SCRIPT_AFK = "C:\Users\lizzi\OneDrive\Desktop\Jogos\Mods\Stumble\AFK_FARM\AFK_Test_Modos - Copia.exe"
Global Const $OVERLAY_EXE = @ScriptDir & "\Overlay.exe"
Global Const $STATUS_INI = @ScriptDir & "\status.ini" ; Corrigido aqui

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
Global $hGUI = GUICreate("Stumble Mods Launcher", 340, 310)
GUISetBkColor($COR_FUNDO)

GUICtrlCreateLabel("Aim Assist", 20, 20, 120, 20)
GUICtrlSetColor(-1, $COR_BRANCO)
Global $btnAim = GUICtrlCreateButton("Iniciar", 150, 15, 90, 30)
_SetButtonGreen($btnAim)

GUICtrlCreateLabel("Plataforma Timer", 20, 80, 140, 20)
GUICtrlSetColor(-1, $COR_BRANCO)
Global $btnPlat = GUICtrlCreateButton("Iniciar", 150, 75, 90, 30)
_SetButtonGreen($btnPlat)

GUICtrlCreateLabel("AFK Farm", 20, 140, 120, 20)
GUICtrlSetColor(-1, $COR_BRANCO)
Global $btnAFK = GUICtrlCreateButton("Iniciar", 150, 135, 90, 30)
_SetButtonGreen($btnAFK)

GUICtrlCreateLabel("Transparência do Overlay (Fantasma)", 20, 185, 300, 20)
GUICtrlSetColor(-1, $COR_BRANCO)
Global $sldAlpha = GUICtrlCreateSlider(20, 205, 300, 30)
GUICtrlSetLimit($sldAlpha, 255, 30)
GUICtrlSetData($sldAlpha, IniRead($STATUS_INI, "CONFIG", "Alpha", "150"))

Global $btnExit = GUICtrlCreateButton("Fechar Todos [F11]", 70, 260, 200, 32)
_SetButtonRed($btnExit)

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

Func _Toggle($section, ByRef $btn, ByRef $pid, $path)
    If $pid = 0 Then
        $pid = Run($path)
        If @error Then 
            MsgBox(16, "Erro", "Não foi possível encontrar o arquivo:" & @CRLF & $path)
            Return
        EndIf
        SoundPlay($SOUND_START)
        IniWrite($STATUS_INI, $section, "on", "1")
        GUICtrlSetData($btn, "Parar")
        _SetButtonRed($btn)
    Else
        ProcessClose($pid)
        SoundPlay($SOUND_STOP)
        $pid = 0
        IniWrite($STATUS_INI, $section, "on", "0")
        GUICtrlSetData($btn, "Iniciar")
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