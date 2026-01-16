; Quit Bot with F10 key
HotKeySet("{F10}", "_Terminate")

; Mode selector hotkeys
HotKeySet("{F1}", "_SetModeNormal")
HotKeySet("{F2}", "_SetModeRanked")
HotKeySet("{F3}", "_SetModeCustom")

; Custom event selector
HotKeySet("{1}", "_SelectEvent1")
HotKeySet("{2}", "_SelectEvent2")
HotKeySet("{3}", "_SelectEvent3")
HotKeySet("{4}", "_SelectEvent4")

; Game Title
Global $title = "Stumble Guys"

; Window Handle
Global $hWnd = 0

; Window Properties
Global $baseWidth = 1920
Global $baseHeight = 1080
Global $windowWidth = 1920
Global $windowHeight = 1080

; Modo de jogo
Global $modoGame = 0 ; 1 normal | 2 ranked | 3 custom

; Variavel para saber qual evento
Global $event = 0 ; 0 = nenhum | 1 = evento 1 | 2 = evento 2 | 3 = evento 3 | 4 = evento 4

; Nenhum modo selecionado, Bot desligado
Global $botEnabled = False

; Mouse Centering
Global $centerX = Round($baseWidth/2)
Global $centerY = Round($baseHeight/2)

; Contador de tempo inativo
Global $lastAction = TimerInit()

; Sons (mesmo padrão do Launcher)
Global Const $SOUND_START = "C:\Windows\Media\Speech On.wav"
Global Const $SOUND_STOP = "C:\Windows\Media\Speech Off.wav"
Global Const $SOUND_EXIT = "C:\Windows\Media\Notify.wav"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main loop

_Main()
Func _Main()
    ; Change AutoIt defaults
    Opt("MouseCoordMode", 2)
    Opt("PixelCoordMode", 2)
    Opt("SendKeyDownDelay", 25)

    ; Detect if game window is present and has focus
    Debug("Waiting until game gets active focus")
    WinWaitActive($title)

    ; Get window handle
    $hWnd = WinGetHandle($title)
    
    ; Get actual window size
    Local $size = GetClientSize($hWnd)
    $windowWidth = $size[0]
    $windowHeight = $size[1]

    ; (Main Menu loop)
    While 1
    
        ; Bot disabled → do nothing
        If Not $botEnabled Then
            _Sleep(300)
            ContinueLoop
        EndIf

        ; Bot enabled but no mode selected yet
        If $modoGame = 0 Then
            _Sleep(300)
            ContinueLoop
        EndIf

        HandleAdvert()
        HandleLevelUp()
        HandleItemReceived()
		HandleBoxReceived()
		HandleSkipButton()
		HandleGetItemBox()
        
        ; --- Lógica para iniciar RANKED ---
        If DetectRankedMenu() = 1 and $modoGame = 2 Then
			Debug("Detect: Ranked Menu - Starting Game")
            _Sleep(200)
            ClickPlayRankedGame()
            _Sleep(1000)
        EndIf
    
        ; --- Lógica para iniciar CUSTOM (Se já estiver na sala/lobby) ---
        If $modoGame = 3 And DetectEventRoom() = 1 Then
            Debug("Detect: Event Room (Lobby) - Starting Game")
            _Sleep(500)
            ClickPlayEventGame()
            _Sleep(1000)
        EndIf

        ; --- Lógica se estiver na lista de eventos (MENU DE EVENTOS) ---
        If $modoGame = 3 and DetectEventMenu() = 1 Then
            _Sleep(500)

				Debug("Event menu detected. Selected event: " & $event)
				If $event = 1 Then
					Debug("Calling ClickEvent1()")
					ClickEvent1()
				ElseIf $event = 2 Then
					Debug("Calling ClickEvent2()")
					ClickEvent2()
				ElseIF $event = 3 Then
					Debug("Calling ClickEvent3()")
					ClickEvent3()
				ElseIF $event = 4 Then
					Debug("Calling ClickEvent4()")
					ClickEvent4()
				Else
					Debug("No event selected (event=" & $event & "). Skipping click.")
				EndIf
            
            ; Espera inteligente para a sala carregar
            Local $waitRoom = 0
            While DetectEventRoom() = 0 And $waitRoom < 10
                _Sleep(200)
                $waitRoom += 1
            WEnd
        EndIf
    

        ; --- Lógica se estiver no MENU PRINCIPAL ---
        If DetectMainMenu() = 1 Then
            Debug("Detect: Main Menu")

            HandleMissionRewards()

            If $modoGame = 3 Then
                Debug("CUSTOM MODE: navigating to event")
                _Sleep(500)
                ClickEventMenuButton()
                _Sleep(1500) ; Aumentado para garantir carregamento
                If DetectEventMenu() = 1 Then
					Debug("Event Menu detected. Selected event: " & $event)
                    _Sleep(500)

                    If $event = 1 Then
                        ClickEvent1()
                    ElseIf $event = 2 Then
                        ClickEvent2()
                    ElseIf $event = 3 Then
						ClickEvent3()
					ElseIf $event = 4 Then
						ClickEvent4()
					EndIf
                    
                    ; Espera a sala carregar
                    Debug("Waiting for Event Room load...")
									For $i = 1 To 20 
									    Debug("Waiting for Event Room load... try " & $i)
									    If DetectEventRoom() = 1 Then
										    Debug("Room Loaded. Playing.")
										    _Sleep(500)
										    Debug("Calling ClickPlayEventGame()")
										    ClickPlayEventGame()
										    $lastAction = TimerInit()
										    _Sleep(1000)
										    ExitLoop
									    EndIf
									    _Sleep(200)
									Next
                EndIf
    
            ElseIf $modoGame = 2 Then
                ClickRankedMenuButton()
				$lastAction = TimerInit()
                _Sleep(1500) ; Tempo aumentado

                ; --- CORREÇÃO DE SEGURANÇA (RANKED) ---
                If DetectRankedMenu() = 0 Then
                     Debug("Falha ao abrir Ranked. Voltando...")
                     GoBack()
                     _Sleep(1000)
                     ContinueLoop
                EndIf
                ; --------------------------------------

                If DetectRankedMenu() = 1 Then
					Debug("Detect: Ranked Menu - Starting Game")
                    _Sleep(200)
                    ClickPlayRankedGame()
                    _Sleep(1000)
					$lastAction = TimerInit()
                EndIf

            Else
				If $modoGame = 1 and DetectMainMenu() = 1 Then
                ClickPlayGame()
				_Sleep(1000)
				$lastAction = TimerInit()
				EndIf
            EndIf

            _Sleep(1000)
            HandleGameLoad()
            $lastAction = TimerInit()
        EndIf

        GameLoop()

        ; Game window must be active to continue
        While WinActive($title) = 0
            Debug("Window Lost Focus")

            If WinExists($title) = 0 Then
                Debug("Window Closed")
                Exit
            EndIf

            _Sleep(3000)
        WEnd

        _Sleep(500)
    WEnd
EndFunc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Game Loop

Func GameLoop()
	Debug("Game Loop")

	While WinActive($title)
		HandleAdvert()
		HandleLevelUp()
		HandleItemReceived()
		HandleBoxReceived()
		HandleSkipButton()
		HandleGetItemBox()

		; Fault tolerant approach
		If DetectGameLost() = 1 Then
			; Leave game on loss
			Debug("Detect: Game Lost")
			LeaveGame()
			$lastAction = TimerInit()
		ElseIf DetectGetReward() = 1 Then
			; Claim participation reward
			Debug("Detect: Get Reward")
			ClickGetReward()
			$lastAction = TimerInit()
			ElseIf DetectGetRankedReward() = 1 Then
			; Claim participation reward
			Debug("Detect: Get Ranked_Reward")
			ClickGetRankedReward()
			$lastAction = TimerInit()
		ElseIf DetectGetStumbleJourneyReward() = 1 Then
			; Claim stumble journey reward (click anywhere on the screen)
			Debug("Detect: Journey Reward")
			ClickGetReward()
			$lastAction = TimerInit()
		ElseIf DetectGameResults() = 1 Then
			; Round has finished, results are shown
			; Must wait till screen goes away
			Debug("Detect: Game Results")
			$lastAction = TimerInit()
		ElseIf DetectDayReward() = 1 Then
			; Must wait till screen goes away
			Debug("Detect: Day Rewards")
			ClickGetDayReward()
			$lastAction = TimerInit()
		ElseIf DetectGameRunning() = 1 Then
			Debug("Detect: Game Running")
			; Game is still on-going
			; Warning: This condition will also be true for spectator mode on game loss (check loss first)
			; AFK gameplay happens here
			SimulateGamePlay()
			$lastAction = TimerInit()
			ContinueLoop
		Else
	; WATCHDOG - ANTI TRAVAMENTO
	If TimerDiff($lastAction) > 10000 Then
		Debug("Watchdog: forcing popup close")
		ClosePromoPopup()
		GoBack()
		_Sleep(1000)
		$lastAction = TimerInit()
		if DetectExitStumble() = 1 Then
			Debug("Watchdog: Detected Exit Stumble popup, clicking Cancel")
			ClickExitStumbleCancel()
			$lastAction = TimerInit()
		EndIf
	EndIf
	ExitLoop
EndIf
		_Sleep(1000)
	WEnd
EndFunc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sub Routines

Func HandleAdvert()
	; Skip the advert
	If DetectAdvert() = 1 Then
		Debug("Detect: Advert")
		ClickAdvertClose()
		$lastAction = TimerInit()
		_Sleep(1000)
	EndIf
EndFunc

Func HandleLevelUp()
	; Skip the stumble pass/journey level up screens
	If DetectStumblePassLevelUp() = 1 Or DetectStumbleJourneyLevelUp() = 1 Then
		Debug("Detect: Level Up")
		_Sleep(1000) ; espera a tela abrir
		ClickContinue()
		$lastAction = TimerInit()
		_Sleep(1000)
	EndIf
EndFunc

Func HandleSkipButton()
	; If the skip button is present, click it
	If DetectSkipButton() = 1 Then
		Debug("Detect: Skip Button")
		ClickSkip()
		$lastAction = TimerInit()
		_Sleep(1000)
	EndIf
EndFunc

Func HandleDetectItemDuplicate()
	; Skip the item duplicate screen
	If DetectItemDuplicate() = 1 Then
		Debug("Detect: Item Duplicate")
		ClickBlueOk()
		$lastAction = TimerInit()
		_Sleep(1000)
	EndIf
EndFunc

Func HandleBoxReceived()
	; Skip the Box received screen
	If DetectBoxReceived() = 1 Then
		Debug("Detect: Box Received")
		ClickOK()
		$lastAction = TimerInit()
		_Sleep(1000)
	EndIf
EndFunc

Func HandleGetItemBox()
	; Skip the Get Item Box screen
	If DetectGetItemBox() = 1 Then
		Debug("Detect: Get Item Box")
		ClickBlueOkCenter()
		$lastAction = TimerInit()
		_Sleep(1000)
	EndIf
EndFunc

Func HandleItemReceived()
	; Skip the item received screen
	If DetectItemReceived() = 1 Then
		Debug("Detect: Item Received")
		ClickOK()
		$lastAction = TimerInit()
		_Sleep(1000)
	EndIf
EndFunc

Func HandleMissionRewards()
	; Collect pending mission rewards
	If DetectMainMenuMissionComplete() = 1 Then
		Debug("Detect: Mission Complete")
		ClickMissions()
		_Sleep(1000)

		While DetectMissionReward() = 1
			Debug("Detect: Mission Reward")
			CollectMissionReward()
			$lastAction = TimerInit()
			_Sleep(1000)
		WEnd
	EndIf
EndFunc

Func HandleGameLoad()
	; not necessary but helps to determine current state
	While DetectGameSearch() = 1
		Debug("Detect: Game Search")
		If Random(0, 2) = 1 Then MouseRandom()
		_Sleep(1000, 2000)
	WEnd

	HandleScreenTransition()

	; not necessary but helps to determine current state
	While DetectMapSelection() = 1
		Debug("Detect: Map Selection")
		If Random(0, 2) = 1 Then MouseRandom()
		_Sleep(1000, 2000)
	WEnd

	; center mouse
	Mouse(Random($centerX-5, $centerX+5), Random($centerY, $centerY+10));

	; not necessary but helps to determine current state
	If DetectGameStart() = 1 Then
		While DetectGameStart() = 1
			Debug("Detect: Game Start")
			_Sleep(500)
		WEnd

		; There is a 3 second in game counter at the start of each round
		Debug("Waiting for Countdown")
		_Sleep(3000)
		Debug("Game Ready")
	EndIf
EndFunc

Func HandleScreenTransition()
	While DetectScreenTransition() = 1
		Debug("Detect: Screen Transition")
		_Sleep(1000)
	WEnd
EndFunc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Detection functions

Func DetectMainMenu()
    ; Detecta tela de menu principal
    Local $match1 = IsHexColorInRange(Pixel(1789, 205), "FF2C2C", 10)
    Local $match2 = IsHexColorInRange(Pixel(1640, 988), "191919", 10)
	Local $match3 = IsHexColorInRange(Pixel(1622, 982), "FFFFFF", 10)

    If $match1 And $match2 And $match3 Then Return 1
    Return 0
EndFunc

Func DetectMainMenuMissionComplete()
	; (Red Number Badge)
	If IsHexColorInRange(Pixel(1867, 152), "FF4B4B", 10) Or IsHexColorInRange(Pixel(1893, 181), "FF4B4B", 10) Then Return 1

	Return 0
EndFunc

Func DetectMissionReward()
	; (Full Progress Bar)
	If IsHexColorInRange(Pixel(787, 861), "FFFF94", 10) Or IsHexColorInRange(Pixel(1542, 860), "FFFF94", 10) Then Return 1

	Return 0
EndFunc

Func DetectStumbleJourneyLevelUp()
	;Level Up! branco
	Local $match1 = IsHexColorInRange(Pixel(962, 138), "FFFFFF", 10)
	;Engrenagem cinza
	Local $match2 = IsHexColorInRange(Pixel(1829, 60), "435260", 10)
	;Barra completa
	Local $match3 = IsHexColorInRange(Pixel(556, 81), "134C60", 15)

	If $match1 And $match2 And $match3 Then Return 1
	Return 0
EndFunc

Func DetectStumblePassLevelUp()
	; (Blue Continue Button)
	Local $matchButton = IsHexColorInRange(Pixel(203, 948), "0D89EC", 10) Or IsHexColorInRange(Pixel(513, 995), "086EE7", 10)

	; (White in Banner)
	Local $matchBanner = IsHexColorInRange(Pixel(611, 117), "FFFFFF", 10) Or IsHexColorInRange(Pixel(1308, 118), "FFFFFF", 10)

	; Both of them should match
	If $matchButton And $matchBanner Then Return 1

	Return 0
EndFunc

Func DetectGetItemBox()
	; yellow banner
	Local $match1 = IsHexColorInRange(Pixel(854, 163), "FFC800", 15)

	; white Box name
	Local $match2 = IsHexColorInRange(Pixel(952, 125), "FFFFFF", 15)

	; Blue button
	Local $match3 = IsHexColorInRange(Pixel(901, 1001), "0B7AE9", 15)

	; All of them should match
	If $match1 And $match2 And $match3 Then Return 1

	Return 0
EndFunc

Func DetectItemReceived()
	; (White Received Text)
	Local $match1 = IsHexColorInRange(Pixel(929, 422), "FFFFFF", 20)

	; (Purple Background)
	Local $match2 = IsHexColorInRange(Pixel(1040, 385), "7E1CB8", 20)

	; (Green Equip Now Button)
	Local $match3 = IsHexColorInRange(Pixel(610, 922), "55DB1E", 20)

	; (Blue OK Button)
	Local $match4 = IsHexColorInRange(Pixel(1601, 915), "0D88EC", 20)

	; All of them should match
	If $match1 And $match2 And $match3 And $match4 Then Return 1

	Return 0
EndFunc

Func DetectBoxReceived()
	; (White Received Text)
	Local $match1 = IsHexColorInRange(Pixel(929, 422), "FFFFFF", 20)

	; (Purple Background)
	Local $match2 = IsHexColorInRange(Pixel(1040, 385), "7E1CB8", 20)

	; (Blue OK Button)
	Local $match3 = IsHexColorInRange(Pixel(1601, 915), "0D88EC", 20)

	; All of them should match
	If $match1 And $match2 And $match3 Then Return 1

	Return 0
EndFunc

Func DetectItemDuplicate()
	; (White Duplicate Text)
	Local $match1 = IsHexColorInRange(Pixel(922, 407), "FFFFFF", 20)

	; (Purple Background)
	Local $match2 = IsHexColorInRange(Pixel(1437, 114), "251852", 20)

	; (Blue OK Button)
	Local $match3 = IsHexColorInRange(Pixel(1631, 954), "097CEC", 35)

	; All of them should match
	If $match1 And $match2 And $match3 Then Return 1

	Return 0
EndFunc

Func DetectAdvert()
	; (Green bottom left purchase button)
	Local $match1 = IsHexColorInRange(Pixel(719, 919), "B1FB76", 10)

	; (Green bottom right purchase button)
	Local $match2 = IsHexColorInRange(Pixel(1167, 919), "7AB068", 10)

	; (Purple top left)
	Local $match3 = IsHexColorInRange(Pixel(335, 156), "152ED2", 10)

	; (Pink bottom right)
	Local $match4 = IsHexColorInRange(Pixel(1581, 932), "CE4F8E", 10)

	; (Red x button)
	Local $match5 = IsHexColorInRange(Pixel(1557, 103), "F45731", 10)

	; All of them should match
	If $match1 And $match2 And $match3 And $match4 And $match5 Then Return 1

	Return 0
EndFunc

Func DetectSkipButton()
	; gray skip text
	Local $match1 = IsHexColorInRange(Pixel(133, 73), "858486", 30)

	; gray skip text
	Local $match2 = IsHexColorInRange(Pixel(156, 76), "858486", 30)

	; gray skip text
	Local $match3 = IsHexColorInRange(Pixel(196, 77), "858486", 30)

	; All
	If $match1 And $match2 And $match3 Then Return 1
	Return 0
EndFunc

Func DetectScreenTransition()
	; (Black screen)
	If IsHexColorInRange(Pixel(50, 50), "000000", 15) And _
		IsHexColorInRange(Pixel(50, 950), "000000", 15) And _
		IsHexColorInRange(Pixel(1850, 50), "000000", 15) And _
		IsHexColorInRange(Pixel(1850, 950), "000000", 15) Then
			Return 1
	EndIf

	Return 0
EndFunc

Func DetectGameSearch()
	; (Blue Abort Button)
	If IsHexColorInRange(Pixel(65, 960), "128EEB", 15) And _
		IsHexColorInRange(Pixel(331, 1020), "1586EA", 15) And _
		IsHexColorInRange(Pixel(1892, 1062), "69D8FA", 15) And _
		IsHexColorInRange(Pixel(1879, 26), "527EF1", 15) Then
			Return 1
	EndIf

	Return 0
EndFunc

Func DetectMapSelection()
	; (Purple Background)
	If IsHexColorInRange(Pixel(21, 75), "5B57CA", 20) And _
		IsHexColorInRange(Pixel(46, 1047), "8279F3", 20) And _
		IsHexColorInRange(Pixel(1847, 79), "5262D0", 20) And _
		IsHexColorInRange(Pixel(1841, 1027), "6876FF", 20) Then
			Return 1
	EndIf

	Return 0
EndFunc

Func DetectGameStart()
	; (White Screen Banner)
	If IsHexColorInRange(Pixel(672, 72), "FFFFFF", 10) And IsHexColorInRange(Pixel(1250, 52), "FFFFFF", 10) Then Return 1

	Return 0
EndFunc

Func DetectGameRunning()
	; (White Player Arrow)
	If IsHexColorInRange(Pixel(955, 446), "FFFFFF", 10) And IsHexColorInRange(Pixel(962, 446), "FFFFFF", 10) Then Return 1

	Return 0
EndFunc

Func DetectGameResults()
	; (Purple border of flying screen)
	If IsHexColorInRange(Pixel(677, 111), "531EA6", 20) And IsHexColorInRange(Pixel(1237, 109), "491993", 20) Then Return 1

	Return 0
EndFunc

Func DetectGameLost()
	; (Red Leave Button) 
	If IsHexColorInRange(Pixel(228, 969), "F7513F", 20) And IsHexColorInRange(Pixel(35, 969), "F44C39", 20) Then Return 1

	Return 0
EndFunc

Func DetectGetStumbleJourneyReward()
	; (White Congratulations Banner)
	Local $match1 = IsHexColorInRange(Pixel(611, 43), "FFFFFF", 10)

	; (White Congratulations Banner)
	Local $match2 = IsHexColorInRange(Pixel(1276, 50), "FFFFFF", 10)

	; (Black Text in Congratulations Banner)
	Local $match3 = IsHexColorInRange(Pixel(667, 71), "333333", 10)

	; (Yellow Rewards Banner)
	Local $match4 = IsHexColorInRange(Pixel(947, 130), "FFC800", 10)

	; (White Tap To Continue Text)
	Local $match5 = IsHexColorInRange(Pixel(809, 958), "FFFFFF", 10)

	; (Purple Background)
	Local $match6 = IsHexColorInRange(Pixel(946, 1004), "251852", 10)

	If $match1 And $match2 And $match3 And $match4 And $match5 And $match6 Then Return 1

	Return 0
EndFunc

Func DetectGetReward()
	; SEGURANÇA: Se estiver na tela de escolha de eventos, retorna FALSO imediatamente
    ; Isso impede o clique acidental em "Tournaments"
    If DetectEventMenu() = 1 Then Return 0

    ; Detect green "Resgatar" button (new UI)
    Local $match1 = IsHexColorInRange(Pixel(1511, 956), "4DD61B", 10)
    Local $match2 = IsHexColorInRange(Pixel(1594, 958), "FFFFFF", 10)
    Local $match3 = IsHexColorInRange(Pixel(1732, 961), "4AD61B", 10)

    If $match1 And $match2 And $match3 Then Return 1
    Return 0
EndFunc

Func DetectGetRankedReward()
    ; Detect Blue "Resgatar" button (new UI)
    Local $match1 = IsHexColorInRange(Pixel(1516, 935), "0582DC", 15)
    Local $match2 = IsHexColorInRange(Pixel(1734, 985), "0250A7", 15)

    If $match1 and $match2 Then Return 1
    Return 0
EndFunc

Func DetectRankedMenu()
    Local $match1 = IsHexColorInRange(Pixel(1149, 758), "3C4D84", 15)
    Local $match2 = IsHexColorInRange(Pixel(1524, 759), "8CA7A6", 15)

    If $match1 and $match2 Then Return 1
    Return 0
EndFunc

Func DetectEventRoom()
    Local $match1 = IsHexColorInRange(Pixel(1080, 921), "3B4D84", 15)
    Local $match2 = IsHexColorInRange(Pixel(1447, 919), "8CA7A7", 15)
	Local $match3 = IsHexColorInRange(Pixel(1763, 66), "F45831", 15)

    If $match1 and $match2 and $match3 Then Return 1
    Return 0
EndFunc

Func DetectEventMenu()
    Local $match1 = IsHexColorInRange(Pixel(463, 61), "384A80", 20) ; Azul escuro Let's play
    Local $match2 = IsHexColorInRange(Pixel(386, 982), "FFF589", 20) ; amarelo claro events gif
	Local $match3 = IsHexColorInRange(Pixel(503, 63), "FFFFFF", 20) ; Branco Let's play

    If $match1 and $match2 and $match3 Then Return 1
    Return 0
EndFunc

Func DetectDayReward()
	Local $match1 = IsHexColorInRange(Pixel(423, 806), "FFFFFF", 15)
    Local $match2 = IsHexColorInRange(Pixel(482, 805), "191919", 15)
	Local $match3 = IsHexColorInRange(Pixel(732, 804), "E7B212", 15)

    If $match1 and $match2 and $match3 Then Return 1
    Return 0
EndFunc

Func DetectExitStumble()
	Local $match1 = IsHexColorInRange(Pixel(701, 335), "0D1C32", 15) ;dark blue background
    Local $match2 = IsHexColorInRange(Pixel(737, 717), "F44939", 15) ;red leave button
	Local $match3 = IsHexColorInRange(Pixel(1028, 717), "087CEC", 15) ;blue button

    If $match1 and $match2 and $match3 Then Return 1
    Return 0
EndFunc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Control functions 

Func GoBack()
	Debug("Go Back")
	_Send("{ESC}")
EndFunc

Func LeaveGame()
	Debug("Leave Game")
	_Send("{ESC}")
EndFunc

Func ClickMissions()
	Debug("Click Missions")
	Local $x = Random(1760, 1875)
	Local $y = Random(180, 260)
	_LeftClick($x, $y)
	$lastAction = TimerInit()
EndFunc

Func CollectMissionReward()
	Debug("Collect Mission Reward")
	Local $x = Random(345, 1710)
	Local $y = Random(780, 880)
	_LeftClick($x, $y)
	$lastAction = TimerInit()
EndFunc

Func ClickPlayGame()
	Debug("Click Play Game")
	Local $x = Random(1540, 1840)
	Local $y = Random(930, 1030)
	_LeftClick($x, $y)
	$lastAction = TimerInit()
EndFunc

Func ClickGetReward()
	Debug("Click Get Reward")
	Local $x = Random(1499, 1809)
	Local $y = Random(915, 1001)
	_LeftClick($x, $y)
	$lastAction = TimerInit()
	Sleep(1000)
	if DetectGetReward() = 1 then
		Debug("Click Get Reward: Detected reward still present, clicking again")
		_LeftClick($x, $y)
		$lastAction = TimerInit()
	EndIf
	if $ModoGame = 3 Then
		_Sleep(300)
		HandleSkipButton()
		_Sleep(200)
	EndIf
EndFunc

Func ClickGetRankedReward()
	Debug("Click Get RankedReward")
	Local $x = Random(1509, 1738)
	Local $y = Random(932, 987)
	_LeftClick($x, $y)
	$lastAction = TimerInit()
EndFunc

Func ClickGetDayReward()
	; Clica no botão de pegar recompensa diária
	Debug("Click Get Day Reward")
	Mouse(555, 806)
	Sleep(80)
	MouseClick("left")
	Sleep(80)
	$lastAction = TimerInit()
EndFunc

Func ClickContinue()
	Debug("Click Continue")
	Local $x = Random(480, 520)
	Local $y = Random(930, 970)
	_LeftClick($x, $y)
	$lastAction = TimerInit()
EndFunc

Func ClickOK()
	Debug("Click OK")
	Local $x = Random(1605, 1645)
	Local $y = Random(900, 940)
	_LeftClick($x, $y)
	$lastAction = TimerInit()
EndFunc

Func ClickBlueOk()
	Debug("Click Blue OK")
	Mouse(1690, 954)
	Sleep(80)
	MouseClick("left")
	Sleep(80)
	$lastAction = TimerInit()
EndFunc

Func ClickBlueOkCenter()
	Debug("Click Blue OK")
	Mouse(953, 1000)
	Sleep(80)
	MouseClick("left")
	Sleep(80)
	$lastAction = TimerInit()
EndFunc


Func ClickSkip()
	; Use Mouse() to click skip button
	Debug("Click Skip")
	Mouse(164, 78)
	Sleep(80)
	MouseClick("left")
	Sleep(80)
	$lastAction = TimerInit()
EndFunc

Func ClickAdvertClose()
	Debug("Click Advert Close")
	Local $x = Random(1553, 1563)
	Local $y = Random(124, 134)
	_LeftClick($x, $y)
EndFunc

Func ClosePromoPopup()
	; Use Mouse() so coordinates are transformed for current resolution
	Mouse(1726, 128)
	Sleep(80)
	MouseClick("left")
	Sleep(80)
	$lastAction = TimerInit()
EndFunc

Func ClickExitStumbleCancel()
	; Clica em cancelar no popup de sair do Stumble Guys
	Mouse(2750, 723)
	Sleep(80)
	MouseClick("left")
	Sleep(80)
	$lastAction = TimerInit()
EndFunc

Func ClickPlayRankedGame()
	Debug("ClickPlayRankedGame: attempt to click PlayRanked at 1194,989")
	; Use Mouse() so coordinates are transformed for current resolution
	Mouse(1287, 797)
	Sleep(80)
	MouseClick("left")
	Sleep(80)
	$lastAction = TimerInit()
EndFunc

Func ClickRankedMenuButton()
	Debug("ClickRankedMenuButton")
	; Use Mouse() so coordinates are transformed for current resolution
	Mouse(1194, 989)
	Sleep(80)
	MouseClick("left")
	Sleep(80)
	$lastAction = TimerInit()
EndFunc

Func ClickPlayEventGame()
	Debug("ClickPlayEventGame: attempt to click PlayEvent at 1218,957")
	; Use Mouse() so coordinates are transformed for current resolution
	Mouse(1218, 957)
	Sleep(80)
	MouseClick("left")
	Sleep(80)
	$lastAction = TimerInit()
	Debug("ClickPlayEventGame: clicked PlayEvent")
EndFunc

Func ClickEventMenuButton()
	; Use Mouse() so coordinates are transformed for current resolution
	Mouse(1001, 981)
	Sleep(80)
	MouseClick("left")
	Sleep(80)
	$lastAction = TimerInit()
EndFunc

Func ClickEvent1()
	Debug("ClickEvent1: attempt to click Event1 at 403,490")
	; Use Mouse() so coordinates are transformed for current resolution
	Mouse(403, 490)
	Sleep(80)
	MouseClick("left")
	Sleep(80)
	$lastAction = TimerInit()
	Debug("ClickEvent1: clicked Event1")
EndFunc

Func ClickEvent2()
	Debug("ClickEvent2: attempt to click Event2 at 891,525")
	; Use Mouse() so coordinates are transformed for current resolution
	Mouse(891, 525)
	Sleep(80)
	MouseClick("left")
	Sleep(80)
	$lastAction = TimerInit()
	Debug("ClickEvent2: clicked Event2")
EndFunc

Func ClickEvent3()
	Debug("ClickEvent3: attempt to click Event3 at 891,525")
	; Use Mouse() so coordinates are transformed for current resolution
	Mouse(1415, 536)
	Sleep(80)
	MouseClick("left")
	Sleep(80)
	$lastAction = TimerInit()
	Debug("ClickEvent3: clicked Event3")
EndFunc

Func ClickEvent4()
	Debug("ClickEvent4: attempt to click Event4 at 891,525")
	; Use Mouse() so coordinates are transformed for current resolution
	Mouse(1863, 553)
	Sleep(80)
	MouseClick("left")
	Sleep(80)
	$lastAction = TimerInit()
	Debug("ClickEvent4: clicked Event4")
EndFunc


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Gameplay functions

Func SimulateGamePlay()
	Debug("Simulate Game Play")

	Local $n = 4
	Local $keys[$n] = ["Left", "Right", "Jump", "Run"]

	For $counter = 1 to $n
		If WinActive($title) = 0 Or DetectGameRunning() = 0 Or DetectGameLost() = 1 Then
			; Abort input on game loss to avoid waste of time
			Return
		EndIf

		; Start running
		_Send("{w down}")
		_Sleep(500, 1500)

		; Select random movement
		$key = Random(0, $n-1)
		Switch $keys[$key]
			Case "Left"
				$ms = Random(500, 1500)
				Left($ms)
			Case "Right"
				$ms = Random(500, 1500)
				Right($ms)
			Case "Jump"
				$ms = Random(100, 500)
				Jump($ms)
				_Sleep(500, 1000)
			Case "Run"
				_Sleep(500, 1500)
		EndSwitch

		; Stop running
		_Sleep(0, 1000)
		_Send("{w up}")

		; Short pause
		_Sleep(100, 1000)
	Next
EndFunc

Func Left($ms = 500)
	_Send("{a down}")
	_Sleep($ms)
	_Send("{a up}")
EndFunc

Func Right($ms = 500)
	_Send("{d down}")
	_Sleep($ms)
	_Send("{d up}")
EndFunc

Func Jump($ms = 500)
	_Send("{SPACE down}")
	_Sleep($ms)
	_Send("{SPACE up}")
EndFunc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mouse functions

Func Mouse($x, $y, $speed = 20)
	If WinActive($title) = 0 Then Return

	TransformCoordinates($x, $y)
	MouseMove($x, $y, $speed)

	_Sleep(50)
EndFunc

Func MouseRandom($minSpeed = 20, $maxSpeed = 30)
	If WinActive($title) = 0 Then Return

	; Try to avoid outer borders
	Local $x = Random(220, 1700)
	Local $y = Random(180, 900)
	Local $speed = Random($minSpeed, $maxSpeed)

	Mouse($x, $y, $speed)
EndFunc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Color detection functions

Func Pixel($x, $y)
	TransformCoordinates($x, $y)
	Return PixelGetColor($x, $y, $hWnd)
EndFunc

Func IsHexColorInRange($color, $targetHex, $tolerance, $log = 0)
	Local $sourceHex = Hex($color, 6)

	Local $sourceRGB = HexToRGB($sourceHex)
	Local $r1 = $sourceRGB[0]
	Local $g1 = $sourceRGB[1]
	Local $b1 = $sourceRGB[2]

	Local $targetRGB = HexToRGB($targetHex)
	Local $r2 = $targetRGB[0]
	Local $g2 = $targetRGB[1]
	Local $b2 = $targetRGB[2]
	
	Local $isColorInRange = _
		Abs($r1 - $r2) <= $tolerance And _
		Abs($g1 - $g2) <= $tolerance And _
		Abs($b1 - $b2) <= $tolerance

	If $log = 1 And $isColorInRange = 0 Then
		Debug("Detected: " & $sourceHex & " / Wanted: " & $targetHex)
		Debug("Diff R: " & Abs($r1 - $r2) & ", G: " & Abs($g1 - $g2) & ", B: " & Abs($b1 - $b2))
		_Sleep(500)
	EndIf

	Return $isColorInRange
EndFunc

Func HexToRGB($hex)
	Local $r = Dec(StringLeft($hex, 2))
	Local $g = Dec(StringMid($hex, 3, 2))
	Local $b = Dec(StringRight($hex, 2))
	Local $rgb[3] = [$r, $g, $b]
	Return $rgb
EndFunc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Transform functions to support different screen resolutions

Func TransformCoordinates(ByRef $x, ByRef $y)
	If $windowWidth <> $baseWidth Or $windowHeight <> $baseHeight Then
		$x = Round($x * $windowWidth / $baseWidth)
		$y = Round($y * $windowHeight / $baseHeight)
	EndIf
EndFunc

Func GetClientSize($hWnd)
	Local $r = DllStructCreate("int Left; int Top; int Right; int Bottom")
	DllCall("user32.dll", "bool", "GetClientRect", "hwnd", $hWnd, "ptr", DllStructGetPtr($r))
	Local $size[2]
	$size[0] = DllStructGetData($r, "Right") - DllStructGetData($r, "Left")
	$size[1] = DllStructGetData($r, "Bottom") - DllStructGetData($r, "Top")
	Return $size
EndFunc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Simple wrapper functions

Func _Send($keys, $flag = 0)
	; Send key input to game only
	If WinActive($title) = 0 Then Return

	Send($keys, $flag)
EndFunc

Func _LeftClick($x, $y)
	; Send clicks to game only
	If WinActive($title) = 0 Then Return

	TransformCoordinates($x, $y)
	MouseClick("left", $x, $y, 1, 10)

	Sleep(100)
EndFunc

Func _Sleep($min, $max = -1)
	If $max > 0 Then
		Sleep(Random($min, $max))
	Else
		Sleep($min)
	EndIf
EndFunc

Func _SetModeNormal()
	; Toggle Normal mode: if already in Normal, turn off; otherwise enable Normal
	If $modoGame = 1 Then
		$modoGame = 0
		$botEnabled = False
		Debug("MODE TOGGLE: NORMAL -> OFF")
		; play stop sound
		SoundPlay($SOUND_STOP)
	Else
		$modoGame = 1
		$botEnabled = True
		Debug("MODE TOGGLE: NORMAL -> ON")
		; play start sound
		SoundPlay($SOUND_START)
	EndIf
EndFunc

Func _SetModeRanked()
	; Toggle Ranked mode
	If $modoGame = 2 Then
		$modoGame = 0
		$botEnabled = False
		Debug("MODE TOGGLE: RANKED -> OFF")
		SoundPlay($SOUND_STOP)
	Else
		$modoGame = 2
		$botEnabled = True
		Debug("MODE TOGGLE: RANKED -> ON")
		SoundPlay($SOUND_START)
	EndIf
EndFunc

Func _SetModeCustom()
	; Toggle Custom mode
	If $modoGame = 3 Then
		$modoGame = 0
		$botEnabled = False
		Debug("MODE TOGGLE: CUSTOM -> OFF")
		SoundPlay($SOUND_STOP)
	Else
		$modoGame = 3
		$botEnabled = True
		Debug("MODE TOGGLE: CUSTOM -> ON")
		SoundPlay($SOUND_START)
	EndIf
EndFunc

Func _SelectEvent1()
    If $modoGame <> 3 Then Return
    $event = 1
    Debug("CUSTOM EVENT SET: 1")
	Beep(1000, 50) ; Som curto de "início"
EndFunc

Func _SelectEvent2()
    If $modoGame <> 3 Then Return
    $event = 2
    Debug("CUSTOM EVENT SET: 2")
	Beep(1000, 50) ; Som curto de "início"
EndFunc

Func _SelectEvent3()
    If $modoGame <> 3 Then Return
    $event = 3
    Debug("CUSTOM EVENT SET: 3")
	Beep(1000, 50) ; Som curto de "início"
EndFunc

Func _SelectEvent4()
    If $modoGame <> 3 Then Return
    $event = 4
    Debug("CUSTOM EVENT SET: 4")
	Beep(1000, 50) ; Som curto de "início"
EndFunc

Func _Terminate()
	Exit
EndFunc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; Função de debug com timestamp
Func Debug($msg)
    Local $timestamp = @HOUR & ":" & @MIN & ":" & @SEC
    Local $line = $timestamp & " - " & $msg
    If Not @Compiled Then
        ConsoleWrite($line & @CRLF)
    EndIf
EndFunc
