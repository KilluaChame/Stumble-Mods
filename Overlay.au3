#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>

#NoTrayIcon

; =========================================================
; CONFIGURAÇÕES DE LAYOUT - EDITE AQUI PARA MUDAR TAMANHOS
; =========================================================
Global Const $GAME_TITLE = "Stumble Guys"           ; Título da janela do jogo
Global Const $CARD_W = 250                         ; LARGURA de cada card (AIM, PLATAFORMA, AFK)
Global Const $CARD_H = 55                          ; ALTURA de cada card (aumente para mostrar mais linhas)
Global Const $CARD_GAP = 10                        ; ESPAÇAMENTO entre cards (em pixels)
Global Const $OVERLAY_TOTAL_W = 780                ; LARGURA TOTAL do overlay (3 cards de 250 + 2 gaps de 10 = 780)
Global Const $BG_COLOR = 0x000000                  ; COR DE FUNDO (preto)

; Variáveis de controle para evitar o "piscar" (Flicker)
Global $currentAlpha = -1
Global $lastAim = "", $lastPlat = "", $lastFarm = ""
Global $lastX = 0, $lastY = 0 ; Declaradas globalmente para evitar erro de variável
; =========================================================

HotKeySet("{F12}", "_Terminate")

; Aguarda o jogo
WinWait($GAME_TITLE)
Global $hGame = WinGetHandle($GAME_TITLE)

; --- CRIAÇÃO DA INTERFACE ---
; Cria a janela do overlay com largura TOTAL ($OVERLAY_TOTAL_W) e altura ($CARD_H)
; Posição inicial: X=0, Y=0 (será movida depois para centralizar no jogo)
Global $hGUI = GUICreate("Overlay", $OVERLAY_TOTAL_W, $CARD_H, 0, 0, $WS_POPUP, BitOR($WS_EX_TOPMOST, $WS_EX_LAYERED, $WS_EX_TOOLWINDOW, $WS_EX_TRANSPARENT))
GUISetBkColor(0x010101)
_SetTransparentColor($hGUI, 0x010101)

; --- CRIAÇÃO DOS CARDS ---
; Cada card é posicionado em X diferente com espaçamento entre eles
; Posição X = número de pixels da esquerda para direita (com GAP entre cards)
Global $dataAim = _CriarCard(0,                              "AIM ASSIST", "OFF [F7]")           ; Primeiro card: X=0
Global $dataPlat = _CriarCard($CARD_W + $CARD_GAP,           "PLATAFORMA", "OFF [F8]", "")       ; Segundo card: X=260
Global $dataFarm = _CriarCard(($CARD_W + $CARD_GAP) * 2,     "AFK FARM",   "OFF [F10]", "[F1] Normal  [F2] Ranked  [F3] Custom  [F4]")  ; Terceiro card: X=520

GUISetState(@SW_SHOWNOACTIVATE, $hGUI)

; =========================================================
; LOOP PRINCIPAL
; =========================================================
While 1
    If Not WinExists($hGame) Then Exit

    If WinActive($hGame) Then
        GUISetState(@SW_SHOWNOACTIVATE, $hGUI)
        Local $pos = WinGetPos($hGame)
        If IsArray($pos) Then
            ; Cálculo de centralização
            Local $centerX = $pos[0] + ($pos[2] / 2) - ($OVERLAY_TOTAL_W / 2)
            Local $targetY = $pos[1]
            
            ; SÓ MOVE SE A POSIÇÃO MUDAR (Evita piscadinhas)
            If $centerX <> $lastX Or $targetY <> $lastY Then
                WinMove($hGUI, "", $centerX, $targetY)
                $lastX = $centerX
                $lastY = $targetY
            EndIf
        EndIf
        _UpdateFromIni() 
    Else
        GUISetState(@SW_HIDE, $hGUI)
    EndIf
    Sleep(150)
WEnd

; =========================================================
; FUNÇÕES
; =========================================================

; Função que lê o arquivo status.ini e atualiza os cards apenas se houver mudança
Func _UpdateFromIni()
    Local $ini = @ScriptDir & "\status.ini"
    
    ; 1. Transparência
    Local $alpha = IniRead($ini, "CONFIG", "Alpha", "180")
    If $alpha <> $currentAlpha Then
        WinSetTrans($hGUI, "", $alpha)
        $currentAlpha = $alpha
    EndIf
    
    ; 2. Aim Assist
    Local $sAim = IniRead($ini, "AIM", "on", "0")
    If $sAim <> $lastAim Then
        _SetCardColorAndText($dataAim[0], $sAim, "ON [F7]", "OFF [F7]")
        $lastAim = $sAim
    EndIf
    
    ; 3. Plataforma + F1
    Local $sPlat = IniRead($ini, "PLATAFORMA", "on", "0")
    If $sPlat <> $lastPlat Then
        _SetCardColorAndText($dataPlat[0], $sPlat, "ON [F8]", "OFF [F8]")
        ; Atualiza o texto pequeno do F1
        If $sPlat = "1" Then 
            GUICtrlSetData($dataPlat[1], "[F1] CALIBRAR")
        Else
            GUICtrlSetData($dataPlat[1], "")
        EndIf
        $lastPlat = $sPlat
    EndIf

    ; 4. AFK Farm
    Local $sFarm = IniRead($ini, "AFK", "on", "0")
    If $sFarm <> $lastFarm Then
        _SetCardColorAndText($dataFarm[0], $sFarm, "ON [F10]", "OFF [F10]")
        ; show quick key hints when AFK script is available
        If $sFarm = "1" Then
            GUICtrlSetData($dataFarm[1], "[F1] Normal  [F2] Ranked  [F3] Custom (use 1/2/3/4)")
        Else
            GUICtrlSetData($dataFarm[1], "")
        EndIf
        $lastFarm = $sFarm
    EndIf
EndFunc

; Função auxiliar para mudar cor e texto (ajudando a evitar erros)
Func _SetCardColorAndText($id, $val, $txtOn, $txtOff)
    If $val = "1" Then
        GUICtrlSetData($id, $txtOn)
        GUICtrlSetColor($id, 0x40FF40) ; Verde
    Else
        GUICtrlSetData($id, $txtOff)
        GUICtrlSetColor($id, 0xFF4040) ; Vermelho
    EndIf
EndFunc

; Cria a estrutura visual do Card
; $x = posição horizontal (em pixels, começa do 0)
; $titulo = nome do card (AIM ASSIST, PLATAFORMA, AFK FARM)
; $atalho = texto principal (OFF [F7], ON [F8], etc)
; $atalhoExtra = texto adicional (eventos, calibração, etc) - opcional
Func _CriarCard($x, $titulo, $atalho, $atalhoExtra = "")
    ; ====== FUNDO DO CARD ======
    ; Cria um retângulo de fundo preto
    Local $bg = GUICtrlCreateLabel("", $x, 0, $CARD_W, $CARD_H)
    GUICtrlSetBkColor($bg, $BG_COLOR)

    ; ====== TÍTULO ======
    ; Posição Y = 3 pixels do topo
    ; Altura = 14 pixels
    ; Fonte: Segoe UI, tamanho 9, BOLD (800)
    Local $lblTitle = GUICtrlCreateLabel($titulo, $x, 3, $CARD_W, 14, $SS_CENTER)
    GUICtrlSetFont($lblTitle, 9, 800, 0, "Segoe UI")
    GUICtrlSetColor($lblTitle, 0xFFFFFF)                    ; Branco
    GUICtrlSetBkColor($lblTitle, $BG_COLOR)

    ; ====== STATUS (ON/OFF) ======
    ; Posição Y = 20 pixels do topo
    ; Altura = 16 pixels
    ; Muda de cor: VERDE (0x40FF40) se ON, VERMELHO (0xFF4040) se OFF
    Local $lblStat = GUICtrlCreateLabel($atalho, $x, 18, $CARD_W, 16, $SS_CENTER)
    GUICtrlSetFont($lblStat, 9, 400, 0, "Segoe UI")
    GUICtrlSetBkColor($lblStat, $BG_COLOR)

    ; ====== INFORMAÇÕES EXTRAS (F1, F2, F3, etc) ======
    ; Posição Y = 40 pixels do topo
    ; Altura = 30 pixels (para caber tudo)
    ; Fonte: Segoe UI, tamanho 8, normal (400)
    ; Cor: CINZA (0xAAAAAA)
    Local $lblEx = GUICtrlCreateLabel($atalhoExtra, $x, 38, $CARD_W, 30, $SS_CENTER)
    GUICtrlSetFont($lblEx, 8, 400, 0, "Segoe UI")
    GUICtrlSetColor($lblEx, 0xAAAAAA)                       ; Cinza
    GUICtrlSetBkColor($lblEx, $BG_COLOR)

    Local $ret[2] = [$lblStat, $lblEx]
    Return $ret
EndFunc

Func _SetTransparentColor($hWnd, $iColor)
    DllCall("user32.dll", "int", "SetLayeredWindowAttributes", "hwnd", $hWnd, "dword", $iColor, "byte", 255, "dword", 0x1)
EndFunc

Func _Terminate()
    Exit
EndFunc