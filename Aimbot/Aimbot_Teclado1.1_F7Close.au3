#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Misc.au3>

#RequireAdmin

; =========================================================
; DLL E CONFIGURA��ES
; =========================================================
Global $dll = DllOpen("user32.dll")
Global Const $GAME_TITLE = "Stumble Guys" ; T�tulo do jogo para rastreio

Global $TEMPO_SEGURAR = 100
Global $Habilidade_M1 = "1"
Global $Habilidade_M2 = "2"
Global $Habilidade_M4 = "3"
Global $Habilidade_M5 = "4"

; =========================================================
; MIRA CONFIG
; =========================================================
Global $CorMira = 0x00FF00
Global $CorBorda = 0x000000
Global $CorVermelho = 0xFF0000

Global $Comprimento = 20
Global $Espessura = 2
Global $Subida = 85 ; Dist�ncia vertical do centro

; GUI
Global $TamGUI = $Comprimento + 6
Global $hMira = GUICreate("Mira", $TamGUI, $TamGUI, 0, 0, _
    $WS_POPUP, BitOR($WS_EX_TOPMOST, $WS_EX_LAYERED, $WS_EX_TRANSPARENT))

GUISetBkColor(0x010101)
_SetTransparentColor($hMira, 0x010101)

; --- DESENHO DA MIRA (BORDA E LINHAS) ---
Global $vBorda = GUICtrlCreateLabel("", ($TamGUI / 2) - ($Espessura / 2) - 1, ($TamGUI / 2) - ($Comprimento / 2) - 1, $Espessura + 2, $Comprimento + 2)
GUICtrlSetBkColor($vBorda, $CorBorda)
Global $hBorda = GUICtrlCreateLabel("", ($TamGUI / 2) - ($Comprimento / 2) - 1, ($TamGUI / 2) - ($Espessura / 2) - 1, $Comprimento + 2, $Espessura + 2)
GUICtrlSetBkColor($hBorda, $CorBorda)

Global $vLinha = GUICtrlCreateLabel("", ($TamGUI / 2) - ($Espessura / 2), ($TamGUI / 2) - ($Comprimento / 2), $Espessura, $Comprimento)
GUICtrlSetBkColor($vLinha, $CorMira)
Global $hLinha = GUICtrlCreateLabel("", ($TamGUI / 2) - ($Comprimento / 2), ($TamGUI / 2) - ($Espessura / 2), $Comprimento, $Espessura)
GUICtrlSetBkColor($hLinha, $CorMira)

GUISetState(@SW_SHOWNOACTIVATE, $hMira)
Opt("SendKeyDownDelay", 45)

; =========================================================
; LOOP PRINCIPAL (AGORA COM RASTREIO)
; =========================================================
While 1
    ; 1. RASTREIO DA JANELA
    Local $hGame = WinGetHandle($GAME_TITLE)
    If $hGame <> "" And WinExists($hGame) Then
        If BitAND(WinGetState($hGame), 16) Then ; Se minimizado
            GUISetState(@SW_HIDE, $hMira)
        Else
            Local $pos = WinGetPos($hGame)
            If IsArray($pos) Then
                ; Calcula o centro da janela do jogo e aplica a "Subida"
                Local $CentroX = $pos[0] + ($pos[2] / 2)
                Local $CentroY = $pos[1] + ($pos[3] / 2) - $Subida
                
                WinMove($hMira, "", $CentroX - ($TamGUI / 2), $CentroY - ($TamGUI / 2))
                GUISetState(@SW_SHOWNOACTIVATE, $hMira)
            EndIf
        EndIf
    Else
        GUISetState(@SW_HIDE, $hMira)
    EndIf

    ; 2. INPUTS DO MOUSE
    If _IsPressed("01", $dll) Then PrepararGolpe($Habilidade_M1, "01")
    If _IsPressed("02", $dll) Then PrepararGolpe($Habilidade_M2, "02")
    If _IsPressed("05", $dll) Then PrepararGolpe($Habilidade_M4, "05")
    If _IsPressed("06", $dll) Then PrepararGolpe($Habilidade_M5, "06")

    ; 3. FECHAR (F7)
    If _IsPressed("76", $dll) Then ExitLoop

    Sleep(2) ; Pequeno delay para n�o consumir 100% da CPU
WEnd

DllClose($dll)
Exit

; =========================================================
; FUN��ES
; =========================================================
Func PrepararGolpe($tecla, $codigoBotao)
    Local $timer = TimerInit()
    Local $modoSegurar = False
    Local $wPressionadoScript = False

    While _IsPressed($codigoBotao, $dll)
        If Not $modoSegurar And TimerDiff($timer) >= $TEMPO_SEGURAR Then
            $modoSegurar = True
            GUICtrlSetBkColor($vLinha, $CorVermelho)
            GUICtrlSetBkColor($hLinha, $CorVermelho)
        EndIf

        If $modoSegurar And Not _IsPressed("57", $dll) Then
            Send("{w down}")
            $wPressionadoScript = True
        EndIf
        Sleep(2)
    WEnd

    Send($tecla)
    If $wPressionadoScript Then Send("{w up}")

    GUICtrlSetBkColor($vLinha, $CorMira)
    GUICtrlSetBkColor($hLinha, $CorMira)
EndFunc

Func _SetTransparentColor($hWnd, $iColor)
    DllCall("user32.dll", "int", "SetLayeredWindowAttributes", "hwnd", $hWnd, "dword", $iColor, "byte", 255, "dword", 0x1)
EndFunc