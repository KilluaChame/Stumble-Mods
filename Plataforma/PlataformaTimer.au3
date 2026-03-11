#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Misc.au3>

#RequireAdmin ; Necessário para interagir com o jogo e usar funções de sistema

; =========================================================
; DLL E CONFIGURAÇÕES GERAIS
; =========================================================
Global $dll = DllOpen("user32.dll")     ; DLL para monitorar teclas (tecla Espaço)
Global $DLL_WINMM = DllOpen("winmm.dll") ; DLL para controle de sons de sistema
Global Const $GAME_TITLE = "Stumble Guys"

; Debug log
Func Debug($msg)
    Local $timestamp = @HOUR & ":" & @MIN & ":" & @SEC
    Local $line = $timestamp & " - [PLATAFORMA] " & $msg
    If Not @Compiled Then
        ConsoleWrite($line & @CRLF)
    EndIf
    Local $debugLog = @ScriptDir & "\..\..\debug.log"
    FileWrite($debugLog, $line & @CRLF)
EndFunc

; Definição das teclas de atalho (Hotkeys)
HotKeySet("{F8}", "_Sair")            ; F8 fecha o script completamente
HotKeySet("{F1}", "_ModoCalibracao")  ; F1 ativa o modo de gravação de tempo

; Variáveis de controle lógico
Global $ModoGravacao = False    ; Define se o script está salvando um novo tempo
Global $TempoPlataforma = 0     ; Armazena o tempo total da plataforma (em milissegundos)
Global $TimerInicio = 0         ; Marca o momento em que o cronômetro começou
Global $EspacoTravado = False   ; Previne que um único clique no Espaço conte várias vezes
Global $OverlayAtivo = False    ; Indica se o quadradinho está aparecendo na tela agora

; Definição de cores (Formato Hexadecimal)
Global $COR_VERDE = 0x00FF00
Global $COR_AMARELO = 0xFFFF00
Global $COR_VERMELHO = 0xFF0000

; =========================================================
; CRIAÇÃO DA INTERFACE (OVERLAY)
; =========================================================
Global $Size = 30             ; Tamanho do quadrado (30x30 pixels)
Global $DistanciaCentro = 60  ; Distância vertical abaixo do centro do boneco

; Cria uma janela sem bordas, sempre no topo e que o mouse ignora (atravessa)
Global $hOverlay = GUICreate("", $Size, $Size, 0, 0, $WS_POPUP, BitOR($WS_EX_TOPMOST, $WS_EX_LAYERED, $WS_EX_TRANSPARENT))
GUISetBkColor($COR_VERDE)     ; Cor inicial verde
WinSetTrans($hOverlay, "", 255) ; Garante que a janela seja 100% opaca (visível)
GUISetState(@SW_HIDE, $hOverlay) ; Começa escondida

; =========================================================
; LOOP PRINCIPAL (EXECUÇÃO CONTÍNUA)
; =========================================================
While 1
    Local $hGame = WinGetHandle($GAME_TITLE) ; Tenta encontrar a janela do jogo
    
    If $hGame <> "" And WinExists($hGame) Then
        ; Se o jogo estiver aberto e não estiver minimizado
        If Not BitAND(WinGetState($hGame), 16) Then
            Local $pos = WinGetPos($hGame) ; Pega a posição (X, Y) e tamanho da janela do jogo
            If IsArray($pos) Then
                ; Calcula o centro horizontal e vertical da área do jogo
                Local $CentroX = $pos[0] + ($pos[2] / 2)
                Local $CentroY = $pos[1] + ($pos[3] / 2) + $DistanciaCentro
                
                ; Move o quadradinho para seguir o centro do jogo (seu boneco)
                WinMove($hOverlay, "", $CentroX - ($Size / 2), $CentroY - ($Size / 2))
            EndIf
        EndIf
    Else
        ; Se o jogo não estiver aberto, o script descansa mais para economizar CPU
        Sleep(500)
    EndIf

    ; --- MONITORAMENTO DA TECLA ESPAÇO ---
    If _IsPressed("20", $dll) Then ; "20" é o código da tecla Espaço
        If Not $EspacoTravado Then
            $EspacoTravado = True
            _EspacoPressionado() ; Chama a função principal de lógica
        EndIf
    Else
        $EspacoTravado = False ; Libera a trava quando você solta a tecla
    EndIf

    Sleep(10) ; Pequena pausa para evitar sobrecarga do processador
WEnd

; =========================================================
; FUNÇÕES DO SISTEMA
; =========================================================

; --- FUNÇÃO: TRATA O CLIQUE NO ESPAÇO ---
; Responsável por gravar o tempo (calibração) ou iniciar o timer visual no jogo.
Func _EspacoPressionado()
    ; CASO A: Você está calibrando o tempo (Modo Gravação Ativo)
    If $ModoGravacao Then
        If $TimerInicio = 0 Then
            ; Primeiro clique: Inicia a contagem
            $TimerInicio = TimerInit()
            Beep(1000, 50) ; Som curto de "início"
            ToolTip("⏱ Gravando... Pule de novo ao cair!", 0, 0)
            Return
        EndIf

        ; Segundo clique: Finaliza a contagem e salva o tempo
        $TempoPlataforma = Int(TimerDiff($TimerInicio))
        $TimerInicio = 0
        $ModoGravacao = False
        Beep(1500, 200) ; Som agudo de "sucesso"
        ToolTip("✅ Tempo Gravado: " & $TempoPlataforma & " ms", 0, 0)
        AdlibRegister("_ClearToolTip", 1500) ; Remove a mensagem após 1.5 segundos
        Return
    EndIf

    ; CASO B: Uso normal durante o jogo
    ; Se o tempo já foi gravado e o quadradinho não está aparecendo ainda
    If $TempoPlataforma > 0 And Not $OverlayAtivo Then
        $OverlayAtivo = True
        ; AdlibRegister executa a função de atualizar a cor repetidamente sem travar o script
        AdlibRegister("_AtualizarTemporizador", 10)
    EndIf
EndFunc

; --- FUNÇÃO: CONTROLE VISUAL DO QUADRADINHO ---
; Faz o quadradinho aparecer e mudar de cor conforme o tempo acaba.
Func _AtualizarTemporizador()
    Static $t = 0
    If $t = 0 Then 
        $t = TimerInit() ; Inicia o cronômetro interno do pulo
        GUISetState(@SW_SHOWNOACTIVATE, $hOverlay) ; Mostra o quadrado sem tirar o foco do jogo
    EndIf

    Local $restante = $TempoPlataforma - TimerDiff($t)

    ; Lógica de troca de cores baseada no tempo restante
    If $restante <= 150 Then
        GUISetBkColor($COR_VERMELHO) ; Fica vermelho nos últimos 150ms (Pule agora!)
    ElseIf $restante <= 450 Then
        GUISetBkColor($COR_AMARELO)  ; Fica amarelo quando está perto de acabar
    Else
        GUISetBkColor($COR_VERDE)    ; Verde enquanto o tempo está seguro
    EndIf

    ; Quando o tempo gravado acaba, esconde o quadrado e reseta
    If $restante <= 0 Then
        GUISetState(@SW_HIDE, $hOverlay)
        AdlibUnRegister("_AtualizarTemporizador") ; Para de executar esta função
        $OverlayAtivo = False
        $t = 0
    EndIf
EndFunc

; --- FUNÇÃO: ATIVA O MODO DE CALIBRAÇÃO ---
; Acionada pelo F1. Prepara o script para receber um novo tempo de pulo.
Func _ModoCalibracao()
    $ModoGravacao = True
    $TempoPlataforma = 0
    $TimerInicio = 0
    ; Feedback sonoro para saber que o modo mudou
    Beep(800, 100) 
    Beep(1200, 100)
    ToolTip("🎯 Calibração: Aperte ESPAÇO no início e no fim do pulo", 0, 0)
EndFunc

; --- FUNÇÃO: LIMPA MENSAGENS DA TELA ---
Func _ClearToolTip()
    ToolTip("")
    AdlibUnRegister("_ClearToolTip")
EndFunc

; --- FUNÇÃO: ENCERRA O SCRIPT ---
; Acionada pelo F8 ou ao fechar o Launcher.
Func _Sair()
    DllClose($dll)
    DllClose($DLL_WINMM)
    Exit
EndFunc