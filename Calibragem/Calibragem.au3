#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ListBoxConstants.au3>

#RequireAdmin

; ===============================
; CONSTANTES
; ===============================
Global Const $APP_VERSION = "2.0"
Global Const $APP_TITLE = "Calibração de Pixels - AFK Farm"
Global Const $PIXELS_INI = @ScriptDir & "\..\pixels.ini"
Global Const $DEBUG_LOG = @ScriptDir & "\..\debug.log"

; CORES
Global Const $COR_FUNDO = 0x1E1E1E
Global Const $COR_BRANCO = 0xFFFFFF
Global Const $COR_VERDE = 0x2ECC71
Global Const $COR_VERMELHO = 0xE74C3C
Global Const $COR_AZUL = 0x3498DB
Global Const $COR_AMARELO = 0xF1C40F

; ===============================
; VARIÁVEIS GLOBAIS
; ===============================
Global $title = "Stumble Guys"
Global $hWnd = 0
Global $baseWidth = 1920
Global $baseHeight = 1080
Global $windowWidth = 1920
Global $windowHeight = 1080
Global $g_bCapturando = False
Global $g_sPontoAtual = ""
Global $g_sCategoriaAtual = ""
Global $g_iPontoSelecionadoIndex = -1

Global $g_aTodasCategorias[0]
Global $g_aPontosCat[0]
Global $g_aHanSquares[0]
Global $g_aHanBorders[0]

; ===============================
; DEBUG
; ===============================
Func Debug($msg)
    Local $timestamp = @HOUR & ":" & @MIN & ":" & @SEC
    Local $line = $timestamp & " - [CALIBRAÇÃO] " & $msg
    If Not @Compiled Then
        ConsoleWrite($line & @CRLF)
    EndIf
    FileWrite($DEBUG_LOG, $line & @CRLF)
EndFunc

; ===============================
; INICIALIZAÇÃO
; ===============================
Debug("Módulo de calibração v" & $APP_VERSION & " iniciado!")
If FileExists($DEBUG_LOG) Then FileDelete($DEBUG_LOG)

HotKeySet("{ESC}", "_Sair")
HotKeySet("p", "_CapturaPixelComP")

_CarregarCategorias()
_AbrirCalibracao()

Exit

; ===============================
; FUNÇÕES PRINCIPAIS
; ===============================

Func _Sair()
    Debug("Calibração fechada pelo usuário")
    _LimparVisuals()
    Exit
EndFunc

Func _CarregarCategorias()
    Local $aKeys = IniReadSectionNames($PIXELS_INI)
    If Not IsArray($aKeys) Then 
        Debug("Nenhum ponto encontrado em pixels.ini")
        Return
    EndIf
    
    Local $i, $sCategoria, $iCatCount = 0
    Local $aCategoriasSeen[$aKeys[0] + 1]
    
    For $i = 1 To $aKeys[0]
        $sCategoria = _ExtrairCategoria($aKeys[$i])
        
        Local $bJaExiste = False
        Local $j
        For $j = 1 To $iCatCount
            If $aCategoriasSeen[$j] = $sCategoria Then
                $bJaExiste = True
                ExitLoop
            EndIf
        Next
        
        If Not $bJaExiste Then
            $iCatCount += 1
            $aCategoriasSeen[$iCatCount] = $sCategoria
        EndIf
    Next
    
    ReDim $g_aTodasCategorias[$iCatCount]
    For $i = 1 To $iCatCount
        $g_aTodasCategorias[$i - 1] = $aCategoriasSeen[$i]
    Next
    
    Debug("Carregadas " & $iCatCount & " categorias")
EndFunc

Func _ExtrairCategoria($sPontoNome)
    Local $iLen = StringLen($sPontoNome)
    Local $i
    For $i = $iLen To 1 Step -1
        If Not (StringMid($sPontoNome, $i, 1) >= "0" And StringMid($sPontoNome, $i, 1) <= "9") Then
            Return StringMid($sPontoNome, 1, $i)
        EndIf
    Next
    Return $sPontoNome
EndFunc

Func _CarregarPontosDaCategoria($sCategoria)
    Local $aKeys = IniReadSectionNames($PIXELS_INI)
    If Not IsArray($aKeys) Then Return
    
    ReDim $g_aPontosCat[0]
    
    Local $i, $iCount = 0
    Local $aTemp[$aKeys[0] + 1]
    
    For $i = 1 To $aKeys[0]
        If StringLeft($aKeys[$i], StringLen($sCategoria)) = $sCategoria Then
            $aTemp[$iCount] = $aKeys[$i]
            $iCount += 1
        EndIf
    Next
    
    ReDim $g_aPontosCat[$iCount]
    Local $j
    For $j = 0 To $iCount - 1
        $g_aPontosCat[$j] = $aTemp[$j]
    Next
    
    Debug("Carregados " & $iCount & " pontos da categoria: " & $sCategoria)
EndFunc

Func _AbrirCalibracao()
    Debug("Abrindo interface de calibração")
    
    Local $hGUI = GUICreate($APP_TITLE, 1000, 650)
    GUISetBkColor($COR_FUNDO)
    
    ; HEADER
    GUICtrlCreateLabel("Calibração de Pixels - AFK Farm v" & $APP_VERSION, 20, 10, 960, 30)
    GUICtrlSetColor(-1, $COR_VERDE)
    GUICtrlSetFont(-1, 14, 800)
    
    GUICtrlCreateLabel("Instruções: 1) Categoria 2) Ponto 3) P sobre pixel 4) Salva", 20, 45, 960, 20)
    GUICtrlSetColor(-1, $COR_BRANCO)
    
    ; CATEGORIAS
    GUICtrlCreateLabel("📁 Categorias:", 20, 72, 200, 20)
    GUICtrlSetColor(-1, $COR_BRANCO)
    Local $lstCategorias = GUICtrlCreateList("", 20, 95, 200, 450)
    
    Local $i
    For $i = 0 To UBound($g_aTodasCategorias) - 1
        GUICtrlSetData($lstCategorias, $g_aTodasCategorias[$i])
    Next
    
    ; PONTOS
    GUICtrlCreateLabel("📍 Pontos da Categoria:", 230, 72, 280, 20)
    GUICtrlSetColor(-1, $COR_BRANCO)
    Local $lstPontos = GUICtrlCreateList("", 230, 95, 280, 450)
    
    ; AÇÕES
    Local $btnCapturar = GUICtrlCreateButton("📍 Capturar [P]", 520, 95, 160, 40)
    GUICtrlSetBkColor($btnCapturar, $COR_VERDE)
    GUICtrlSetColor($btnCapturar, $COR_BRANCO)
    GUICtrlSetFont($btnCapturar, 10, 800)
    
    Local $btnSalvar = GUICtrlCreateButton("💾 Salvar", 690, 95, 160, 40)
    GUICtrlSetBkColor($btnSalvar, $COR_AMARELO)
    GUICtrlSetColor($btnSalvar, 0x000000)
    GUICtrlSetFont($btnSalvar, 10, 800)
    
    Local $btnLimpar = GUICtrlCreateButton("🗑️ Limpar", 860, 95, 120, 40)
    GUICtrlSetBkColor($btnLimpar, $COR_VERMELHO)
    GUICtrlSetColor($btnLimpar, $COR_BRANCO)
    GUICtrlSetFont($btnLimpar, 10, 800)
    
    Local $lblStatus = GUICtrlCreateLabel("Selecione uma categoria...", 520, 145, 460, 120)
    GUICtrlSetColor($lblStatus, $COR_BRANCO)
    GUICtrlSetBkColor($lblStatus, 0x2C2C2C)
    GUICtrlSetFont($lblStatus, 9)
    
    GUICtrlCreateLabel("Legenda: 🔴 Vermelho=Padrão | 🔵 Azul=Selecionado | 🟢 Verde=Capturado", 520, 270, 460, 20)
    GUICtrlSetColor(-1, $COR_BRANCO)
    GUICtrlSetFont(-1, 8)
    
    ; CAPTURADOS
    GUICtrlCreateLabel("✓ Pixels Capturados:", 20, 560, 960, 20)
    GUICtrlSetColor(-1, $COR_VERDE)
    Local $lstCapturados = GUICtrlCreateList("", 20, 585, 960, 55)
    
    GUISetState(@SW_SHOW, $hGUI)
    
    Debug("Interface de calibração aberta")
    
    Local $msg = 0
    While 1
        $msg = GUIGetMsg()
        
        If $msg = $GUI_EVENT_CLOSE Then
            Debug("Calibração cancelada")
            _LimparVisuals()
            GUIDelete($hGUI)
            Return
        EndIf
        
        If $msg = $lstCategorias Then
            $g_sCategoriaAtual = GUICtrlRead($lstCategorias)
            Debug("Categoria selecionada: " & $g_sCategoriaAtual)
            If $g_sCategoriaAtual <> "" Then
                _CarregarPontosDaCategoria($g_sCategoriaAtual)
                GUICtrlSetData($lstPontos, "")
                _LimparVisuals()
                $g_iPontoSelecionadoIndex = -1
                
                Debug("Iniciando criação de visuais para " & UBound($g_aPontosCat) & " pontos")
                Local $j
                For $j = 0 To UBound($g_aPontosCat) - 1
                    Local $sX = IniRead($PIXELS_INI, $g_aPontosCat[$j], "x", "")
                    Local $sY = IniRead($PIXELS_INI, $g_aPontosCat[$j], "y", "")
                    
                    Debug("Ponto " & $j & ": " & $g_aPontosCat[$j] & " X=" & $sX & " Y=" & $sY)
                    GUICtrlSetData($lstPontos, $g_aPontosCat[$j])
                    
                    If $sX <> "" And $sY <> "" Then
                        Debug("Criando visual para " & $g_aPontosCat[$j])
                        _CriarPontoVisual($sX, $sY, $COR_VERMELHO)
                        Sleep(100)
                    Else
                        Debug("PULANDO - Coordenadas vazias para " & $g_aPontosCat[$j])
                    EndIf
                Next
                
                Debug("Criação de visuais concluída!")
                GUICtrlSetData($lblStatus, "✓ Categoria: " & $g_sCategoriaAtual & @CRLF & "Pontos: " & UBound($g_aPontosCat) & @CRLF & "Selecione um ponto")
            EndIf
        EndIf
        
        If $msg = $lstPontos Then
            $g_iPontoSelecionadoIndex = GUICtrlSendMsg($lstPontos, $LB_GETCURSEL, 0, 0)
            If $g_iPontoSelecionadoIndex >= 0 And $g_iPontoSelecionadoIndex < UBound($g_aPontosCat) Then
                _AtualizarTodasAsCores($g_iPontoSelecionadoIndex)
                GUICtrlSetData($lblStatus, "⭐ SELECIONADO: " & $g_aPontosCat[$g_iPontoSelecionadoIndex] & @CRLF & "[Azul na tela]" & @CRLF & "Pressione [P]")
            EndIf
        EndIf
        
        If $msg = $btnCapturar Then
            If $g_iPontoSelecionadoIndex < 0 Then
                GUICtrlSetData($lblStatus, "❌ Selecione um ponto primeiro!")
            Else
                $g_sPontoAtual = $g_aPontosCat[$g_iPontoSelecionadoIndex]
                $g_bCapturando = True
                GUICtrlSetData($lblStatus, "⏳ CAPTURANDO..." & @CRLF & "Posicione mouse e pressione [P]")
            EndIf
        EndIf
        
        If $msg = $btnLimpar Then
            _LimparVisuals()
            GUICtrlSetData($lblStatus, "✓ Visuais limpos da tela")
        EndIf
        
        If $msg = $btnSalvar Then
            Debug("Salvando pontos...")
            _SalvarTodosPontos($lstCapturados)
            GUICtrlSetData($lblStatus, "✅ SALVO! Todos os pontos foram salvos")
        EndIf
        
        Sleep(50)
    WEnd
EndFunc

Func _AtualizarTodasAsCores($indexSelecionado)
    _LimparVisuals()
    
    Local $i
    For $i = 0 To UBound($g_aPontosCat) - 1
        Local $sX = IniRead($PIXELS_INI, $g_aPontosCat[$i], "x", "")
        Local $sY = IniRead($PIXELS_INI, $g_aPontosCat[$i], "y", "")
        
        If $sX <> "" And $sY <> "" Then
            If $i = $indexSelecionado Then
                _CriarPontoVisual($sX, $sY, $COR_AZUL)
            Else
                _CriarPontoVisual($sX, $sY, $COR_VERMELHO)
            EndIf
        EndIf
    Next
EndFunc

Func _CriarPontoVisual($x, $y, $cor)
    Debug("_CriarPontoVisual chamada com X:" & $x & " Y:" & $y & " Cor:" & Hex($cor, 6))
    
    ; Converter DIRETO para Number (não usar IsNumber com strings!)
    Local $baseX = Number($x)
    Local $baseY = Number($y)
    
    Debug("Coordenadas convertidas: X:" & $baseX & " Y:" & $baseY)
    
    ; Obter e validar handle da janela do jogo
    Local $hGameWnd = WinGetHandle($title)
    If $hGameWnd = 0 Then
        Debug("ERRO: Janela do jogo não encontrada. Tentando com padrão...")
        $hGameWnd = WinGetHandle("[CLASS:Thingy Game Client]")
        If $hGameWnd = 0 Then
            Debug("ERRO: Ainda não encontrou janela. Usando coordenadas absolutas.")
            ; Usa coordenadas da base direto (sem transformação)
            Local $screenX = $baseX
            Local $screenY = $baseY
        Else
            Debug("Janela encontrada com padrão alternativo")
        EndIf
    Else
        Debug("Janela do jogo encontrada: " & $hGameWnd)
        $hWnd = $hGameWnd
        
        Local $aWinPos = WinGetPos($hGameWnd)
        If @error Then
            Debug("ERRO: Não conseguiu obter posição da janela")
            Return
        EndIf
        
        Debug("Posição janela: X:" & $aWinPos[0] & " Y:" & $aWinPos[1])
        
        Local $aClientSize = _GetClientSize($hGameWnd)
        Local $clientWidth = $aClientSize[0]
        Local $clientHeight = $aClientSize[1]
        
        Debug("Tamanho cliente: W:" & $clientWidth & " H:" & $clientHeight)
        
        ; Transformar coordenadas base (1920x1080) para resolução atual
        Local $screenX = $aWinPos[0] + ($baseX * $clientWidth / $baseWidth)
        Local $screenY = $aWinPos[1] + ($baseY * $clientHeight / $baseHeight)
        
        Debug("Coordenadas transformadas: X:" & Int($screenX) & " Y:" & Int($screenY))
    EndIf
    
    ; Criar borda preta primeiro (para ficar atrás)
    Local $hBorder = GUICreate("Border_" & Random(1000, 9999), 28, 28, Int($screenX) - 14, Int($screenY) - 14, $WS_POPUP, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
    GUISetBkColor(0x000000)
    GUISetState(@SW_SHOW, $hBorder)
    Debug("Borda criada em X:" & (Int($screenX) - 14) & " Y:" & (Int($screenY) - 14))
    
    ; Criar quadrado colorido (fica na frente)
    Local $hSquare = GUICreate("Square_" & Random(1000, 9999), 20, 20, Int($screenX) - 10, Int($screenY) - 10, $WS_POPUP, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
    GUISetBkColor($cor)
    Local $label = GUICtrlCreateLabel("", 0, 0, 20, 20)
    GUICtrlSetBkColor($label, $cor)
    GUISetState(@SW_SHOW, $hSquare)
    Debug("Quadrado criado em X:" & (Int($screenX) - 10) & " Y:" & (Int($screenY) - 10))
    
    ReDim $g_aHanSquares[UBound($g_aHanSquares) + 1]
    $g_aHanSquares[UBound($g_aHanSquares) - 1] = $hSquare
    
    ReDim $g_aHanBorders[UBound($g_aHanBorders) + 1]
    $g_aHanBorders[UBound($g_aHanBorders) - 1] = $hBorder
    
    Debug("✓ Visual criado com sucesso!")
EndFunc

Func _LimparVisuals()
    Local $i
    For $i = 0 To UBound($g_aHanSquares) - 1
        If IsHWnd($g_aHanSquares[$i]) Then GUIDelete($g_aHanSquares[$i])
    Next
    For $i = 0 To UBound($g_aHanBorders) - 1
        If IsHWnd($g_aHanBorders[$i]) Then GUIDelete($g_aHanBorders[$i])
    Next
    ReDim $g_aHanSquares[0]
    ReDim $g_aHanBorders[0]
EndFunc

Func _CapturaPixelComP()
    If Not $g_bCapturando Or $g_sPontoAtual = "" Then Return
    
    Debug("Capturando pixel para: " & $g_sPontoAtual)
    
    If $hWnd = 0 Then $hWnd = WinGetHandle($title)
    If $hWnd = 0 Then
        MsgBox(16, "Erro", "Janela do jogo não encontrada!")
        Debug("ERRO: Janela não encontrada")
        Return
    EndIf
    
    ; Obter posição da janela do jogo
    Local $aWinPos = WinGetPos($hWnd)
    If @error Then
        MsgBox(16, "Erro", "Não conseguiu obter posição da janela!")
        Return
    EndIf
    
    Local $aClientSize = _GetClientSize($hWnd)
    $windowWidth = $aClientSize[0]
    $windowHeight = $aClientSize[1]
    
    ; Obter posição do mouse na TELA
    Local $aPos = MouseGetPos()
    Local $screenX = $aPos[0]
    Local $screenY = $aPos[1]
    
    ; Converter para coordenadas RELATIVAS à janela
    Local $clientX = $screenX - $aWinPos[0]
    Local $clientY = $screenY - $aWinPos[1]
    
    ; Verificar se está dentro da janela
    If $clientX < 0 Or $clientY < 0 Or $clientX >= $windowWidth Or $clientY >= $windowHeight Then
        MsgBox(16, "Erro", "Mouse fora da janela do jogo!")
        Debug("ERRO: Mouse fora da janela (X:" & $clientX & " Y:" & $clientY & ")")
        $g_bCapturando = False
        Return
    EndIf
    
    ; Converter para coordenadas BASE (1920x1080)
    Local $baseX = Round($clientX * $baseWidth / $windowWidth)
    Local $baseY = Round($clientY * $baseHeight / $windowHeight)
    
    ; Capturar cor usando coordenadas da tela
    Local $color = PixelGetColor($screenX, $screenY)
    Local $hexColor = Hex($color, 6)
    
    ; Salvar em pixels.ini
    IniWrite($PIXELS_INI, $g_sPontoAtual, "x", $baseX)
    IniWrite($PIXELS_INI, $g_sPontoAtual, "y", $baseY)
    IniWrite($PIXELS_INI, $g_sPontoAtual, "color", $hexColor)
    IniWrite($PIXELS_INI, $g_sPontoAtual, "tolerance", "10")
    
    Debug("✓ Capturado: " & $g_sPontoAtual & " (X:" & $baseX & " Y:" & $baseY & " #" & $hexColor & ")")
    
    ; Atualizar visuais para VERDE
    If $g_iPontoSelecionadoIndex >= 0 Then
        _LimparVisuals()
        Local $i
        For $i = 0 To UBound($g_aPontosCat) - 1
            Local $sX = IniRead($PIXELS_INI, $g_aPontosCat[$i], "x", "")
            Local $sY = IniRead($PIXELS_INI, $g_aPontosCat[$i], "y", "")
            
            If $sX <> "" And $sY <> "" Then
                If $i = $g_iPontoSelecionadoIndex Then
                    _CriarPontoVisual($sX, $sY, $COR_VERDE)
                Else
                    _CriarPontoVisual($sX, $sY, $COR_VERMELHO)
                EndIf
            EndIf
        Next
    EndIf
    
    $g_bCapturando = False
    $g_sPontoAtual = ""
EndFunc

Func _SalvarTodosPontos($lstControl)
    Local $aKeys = IniReadSectionNames($PIXELS_INI)
    If Not IsArray($aKeys) Then Return
    
    GUICtrlSetData($lstControl, "")
    
    Local $i, $iCount = 0
    For $i = 1 To $aKeys[0]
        Local $sX = IniRead($PIXELS_INI, $aKeys[$i], "x", "")
        If $sX <> "" Then
            Local $sY = IniRead($PIXELS_INI, $aKeys[$i], "y", "")
            Local $sCor = IniRead($PIXELS_INI, $aKeys[$i], "color", "")
            GUICtrlSetData($lstControl, "✓ " & $aKeys[$i] & " [X:" & $sX & " Y:" & $sY & "]")
            $iCount += 1
        EndIf
    Next
    
    Debug("✅ Salvos " & $iCount & " pontos")
EndFunc

Func _GetClientSize($hWnd)
    If $hWnd = 0 Then
        Debug("ERRO em _GetClientSize: Handle inválido")
        Return [1920, 1080] ; Retorna tamanho padrão como fallback
    EndIf
    
    Local $r = DllStructCreate("int Left; int Top; int Right; int Bottom")
    Local $result = DllCall("user32.dll", "bool", "GetClientRect", "hwnd", $hWnd, "ptr", DllStructGetPtr($r))
    
    If @error Or Not $result[0] Then
        Debug("ERRO em GetClientRect: @error=" & @error)
        Return [1920, 1080] ; Fallback
    EndIf
    
    Local $size[2]
    $size[0] = DllStructGetData($r, "Right") - DllStructGetData($r, "Left")
    $size[1] = DllStructGetData($r, "Bottom") - DllStructGetData($r, "Top")
    
    Debug("_GetClientSize retornou: W=" & $size[0] & " H=" & $size[1])
    Return $size
EndFunc
