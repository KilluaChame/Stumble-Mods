# 🤖 Instruções para Copilot — Stumble Mods (AutoIt3)

Este é um guia técnico para agentes de IA assistirem no desenvolvimento e manutenção de **Stumble Mods**, um conjunto de scripts AutoIt3 e EXEs compiladas que fornecem automação integrada para Stumble Guys.

---

## 1. 🎯 Visão Geral da Arquitetura

### Componentes Principais (6 módulos)

```
Launcher_GUI_1.1 (HUB CENTRAL)
    ├─ Aimbot (Mira visual overlay)
    ├─ PlataformaTimer (Timer de parkour)
    ├─ AFK_Test_Modos (Automação de farming)
    ├─ Overlay.exe (Status em tempo real)
    └─ Calibragem.au3 v2.0 (Ferramenta de calibração com visuais)
```

### Filosofia Arquitetural

- **Isolamento**: Cada módulo roda como **processo EXE independente** (não threads)
- **IPC**: Comunicação via **arquivo INI** (status.ini) — single source of truth
- **Control**: Launcher é apenas um gerenciador de processos, não coordena execução
- **Escalabilidade**: Novos módulos podem ser adicionados sem modificar existentes

---

## 2. 📍 Pontos de Integração Críticos

### A. Arquivo: `status.ini` (IPC Central)

**Proposito**: Arquivo de estado compartilhado entre TODOS os módulos

```ini
[AIM]
on=0                 ; 0=off, 1=on (Launcher write, Overlay read)

[PLATAFORMA]
on=0                 ; 0=off, 1=on (Launcher write, Overlay read)

[AFK]
on=0                 ; 0=off, 1=on (Launcher write, Overlay read)

[CONFIG]
Alpha=210            ; Transparência do overlay 30-255 (Launcher write/update)
```

**Modificações ao editar**:

- ⚠️ NUNCA adicione seções sem avisar (pode quebrar Overlay)
- ✅ Estenda seções existentes com novos valores (ex: `[CONFIG] NewValue=X`)
- ✅ Prefira adicionar na seção `[CONFIG]` para não-booleanos

### B. Arquivo: `pixels.ini` (Calibração)

**Proposito**: Pontos de detecção de pixel para AFK Farm (24 pontos em 14 categorias)

```ini
[DetectMainMenu1]
x=1848
y=193
color=FF2C2C         ; Hex RGB (sem 0x)
tolerance=10         ; Margem de tolerância

[ClickAdvert]
x=943
y=919
color=000000         ; Preto = não usar cor (apenas coordenada)
tolerance=0
```

**Importante**:

- Nome da seção = `[CategoryName + Número]` (ex: `DetectMainMenu1`, `ClickAdvert`)
- Coordenadas em **base 1920×1080** (transform automático em AFK_Test_Modos.au3)
- `color` é em formato **HEX sem 0x** (ex: `FF2C2C` não `0xFF2C2C`)
- Para cliques, use `color=000000, tolerance=0` (não filtra por cor)

### C. Arquivo: `Launcher_GUI_1.1.au3` (Hub Central)

**Proposito**: Interface gráfica + gerenciador de processos

**Seções críticas**:

```autoit
; Linhas 15-19: CAMINHOS PARA EXEs (edite aqui se renomear)
Global Const $SCRIPT_AIMBOT = @ScriptDir & "\Aimbot\Aimbot_Teclado1.1_F7Close.exe"
Global Const $SCRIPT_PLATAFORMA = @ScriptDir & "\Plataforma\PlataformaTimer.exe"
Global Const $SCRIPT_AFK = @ScriptDir & "\AFK_FARM\AFK_Test_Modos.exe"
Global Const $SCRIPT_CALIBRAGEM = @ScriptDir & "\Calibragem\Calibragem.exe"

; Linhas 32-37: HOTKEYS GLOBAIS (F7/F8/F10/F11/F12)
HotKeySet("{F7}", "_HK_AIM")
HotKeySet("{F8}", "_HK_PLAT")
HotKeySet("{F10}", "_HK_AFK")
HotKeySet("{F11}", "_HK_CLOSE_ALL")
HotKeySet("{F12}", "_HK_TOGGLE_LANGUAGE")

; Linhas 60-75: FUNÇÃO _Toggle() - LÓGICA CENTRAL
; Alternar módulos e gerar PIDs
```

**Alterações seguras**:

- ✅ Editar caminhos de EXEs (linhas 15-19)
- ✅ Adicionar novos hotkeys (antes de hotkey handler functions)
- ⚠️ NÃO editar lógica de `_Toggle()` sem entender PIDs

### D. Arquivo: `Overlay.au3` (Loop de Status)

**Proposito**: Monitorar `status.ini` continuamente e atualizar visual

**Loop Principal** (linha ~145):

```autoit
While 1
    ; Lê status.ini a cada iteração
    $currentAim = IniRead($STATUS_INI, "AIM", "on", "0")
    $currentPlat = IniRead($STATUS_INI, "PLATAFORMA", "on", "0")
    ; ... atualiza GUI labels baseado em mudanças
WEnd
```

**Se adicionar novo módulo**:

1. Adicionar seção em `status.ini`
2. Adicionar `IniRead()` em Overlay.au3
3. Criar novo card com `_CriarCard(posX, titulo, status)`
4. Atualizar lógica de colorir (verde/vermelho)

### E. Arquivo: `Calibragem.au3` v2.0 (Ferramenta de Calibração)

**Novo em v2.0**: Marcadores visuais na tela (Vermelho/Azul/Verde)

**Funções principais**:

```autoit
_CarregarCategorias()         ; Lê pixels.ini, extrai seções únicas
_ExtrairCategoria($nome)      ; "DetectMainMenu1" → "DetectMainMenu"
_CarregarPontosDaCategoria()  ; Filtra pontos por categoria
_CriarPontoVisual()           ; NOVO: Cria marcador na tela
_AtualizarTodasAsCores()      ; NOVO: Muda cores (vermelho→azul→verde)
_LimparVisuals()              ; NOVO: Remove marcadores
```

**Bug Corrigido**: `IsNumber("1783")` retornava FALSE

- ❌ ANTES: `If Not IsNumber($x) Then Return`
- ✅ DEPOIS: `Local $baseX = Number($x)` (conversão direta)

---

## 3. 🎮 Hotkeys Globais (Padrão)

| Tecla | Módulo     | Função        | Comportamento                  |
| ----- | ---------- | ------------- | ------------------------------ |
| F7    | Aimbot     | Toggle        | Ativa/desativa mira            |
| F8    | Plataforma | Toggle        | Ativa/desativa timer           |
| F10   | AFK Farm   | Toggle        | Ativa/desativa automação       |
| F11   | Launcher   | Fechar Todos  | Encerra TODOS os módulos       |
| F12   | Overlay    | Fechar/Idioma | Fecha overlay ou alterna PT↔EN |

**Se adicionar novo hotkey**:

1. Adicione `HotKeySet()` no Launcher
2. Crie função `_HK_NOVOMODULO()` + `IniWrite()` correspondente
3. Atualize `status.ini` com novo campo
4. Registre em README.md

**Hotkeys secundárias** (módulo-específicas):

- F1 = Calibração (Plataforma + AFK)
- F2 = Ranked Mode (AFK)
- F3 = Custom Mode (AFK)
- P = Capturar pixel (Calibragem)
- ESPAÇO = Marcar tempo (Plataforma)

---

## 4. 🖥️ Padrões & Convenções de Código

### Padrão de Função de Hotkey

```autoit
Func _HK_AIM()
    _Toggle($SCRIPT_AIMBOT, $PID_Aimbot)  ; Chama função central
EndFunc
```

### Padrão de Debug Logging

```autoit
Func Debug($msg)
    Local $debugLog = @ScriptDir & "\..\debug.log"
    Local $line = "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] " & $msg
    FileWrite($debugLog, $line & @CRLF)
EndFunc

; Uso:
Debug("[CALIBRAÇÃO] Ponto criado com sucesso!")
```

### Padrão de Transformação de Coordenadas (Multi-resolução)

```autoit
; AFK_Test_Modos.au3 usa:
Local $baseWidth = 1920, $baseHeight = 1080
Local $windowWidth = $someGameWindowWidth
Local $scaleX = $windowWidth / $baseWidth
Local $transformedX = $baseX * $scaleX
```

### Padrão Global Variables

```autoit
; Sempre declaradas no topo de cada script:
Global $title = "Stumble Guys"  ; Exato window title
Global $hWnd = 0                ; Window handle
Global $pixelsIni = @ScriptDir & "\..\pixels.ini"
Global $statusIni = @ScriptDir & "\..\status.ini"
```

### Convenção de Nomes

- **Funções públicas** (chamadas de outros scripts): `_NomeFuncao()`
- **Funções privadas** (uso apenas local): `_NomeFuncao()` (mesma convenção)
- **Variáveis globais importantes**: `$PID_Aimbot`, `$TempoPlataforma` (PascalCase com $)
- **Constantes**: `Global Const $GAME_TITLE = "Stumble Guys"` (UPPER_SNAKE_CASE)
- **Variáveis locais**: `$i`, `$msg`, `$isActive` (camelCase)

---

## 5. 🛠️ Build / Run / Debug

### Compilar Individual (Windows CLI)

```batch
# Terminal PowerShell
$Aut2Exe = "C:\Program Files (x86)\AutoIt3\Aut2Exe\Aut2Exe.exe"

# Compilar Launcher
& $Aut2Exe /in "Launcher_GUI_1.1.au3" /out "Launcher_GUI_1.1.exe"

# Compilar todos
& $Aut2Exe /in "Calibragem.au3" /out "Calibragem.exe"
& $Aut2Exe /in "Overlay.au3" /out "Overlay.exe"
& $Aut2Exe /in "Aimbot\Aimbot_Teclado1.1_F7Close.au3" /out "Aimbot\Aimbot_Teclado1.1_F7Close.exe"
& $Aut2Exe /in "Plataforma\PlataformaTimer.au3" /out "Plataforma\PlataformaTimer.exe"
& $Aut2Exe /in "AFK_FARM\AFK_Test_Modos.au3" /out "AFK_FARM\AFK_Test_Modos.exe"
```

### Debug Via Logging

1. **Adicione `Debug()` calls** no ponto suspeito
2. **Abra `debug.log`** na pasta raiz
3. **Procure por padrão** (ex: `[CALIBRAÇÃO]`) para filtrar

```autoit
; Exemplo: Debug dentro de _CriarPontoVisual()
Debug("_CriarPontoVisual chamada com X:" & $baseX & " Y:" & $baseY)
Debug("Coordenadas transformadas: X:" & $transformedX & " Y:" & $transformedY)
Debug("✓ Visual criado com sucesso!")
```

### Teste Local

1. **Compile todos os arquivos** (veja comando acima)
2. **Execute como Admin**: `Launcher_GUI_1.1.exe` (botão direito → Run as admin)
3. **Verifique `debug.log`** para erros
4. **Monitore `status.ini`** em tempo real: abra em editor de texto

---

## 6. ⚠️ Edições Seguras & Armadilhas Comuns

### ✅ SEGURO: O Que Pode Editar

- Caminhos de arquivos (linhas 15-19 em Launcher_GUI_1.1.au3)
- Cores (0xRRGGBB format no começo de cada script)
- Hotkeys (adicione novos, não remova sem cuidado)
- Pontos de calibração em pixels.ini
- Mensagens de debug e comments
- Nomes de variáveis locais (não globais usadas em outros scripts)

### ❌ PERIGOSO: Verificar Antes de Editar

- **Função `_Toggle()`** em Launcher: controla toda lógica de PIDs
- **PIDs Globais** (`$PID_Aimbot` etc): usados para ProcessClose()
- **Hotkeys**: mudar F7→F8 quebra UX (atualizar em múltiplos lugares)
- **`status.ini` schema**: adicionar campos sem documentar quebra Overlay
- **`#RequireAdmin`**: remover faz script não funcionar com game

### 🐛 Bugs Conhecidos & Soluções

**Bug 1**: `IsNumber("1783")` retorna FALSE (CORRIGIDO ✅)

- ❌ Problema: AutoIt3 não reconhece números em string
- ✅ Solução: Use `Number($valor)` diretamente, sem `IsNumber()` check
- 📍 Localização: Calibragem.au3 linha ~350 (já corrigido em v2.0)

**Bug 2**: Overlay pisca/flicker

- ❌ Problema: Many GUICtrlSetData calls
- ✅ Solução: Verificar mudanças antes de atualizar em Overlay.au3
- 📍 Implementado: `$lastAim`, `$lastPlat`, `$lastFarm` cache

**Bug 3**: Pontos de calibração não aparecem na tela (CORRIGIDO ✅)

- ❌ Problema (v1.0): IsNumber() bloqueava todas as capturas
- ✅ Solução: Removido IsNumber() check, Number() converter direto
- 📍 Localização: Calibragem.au3 v2.0 (completamente refatorado)

**Bug 4**: Visuais de marcadores não renderizam

- ❌ Problema: GUICreate sem flags corretas
- ✅ Solução: Usar `$WS_POPUP` com `$WS_EX_TOPMOST + $WS_EX_LAYERED`
- 📍 Implementado: Calibragem v2.0 agora exibe corretamente

---

## 7. 📁 Estrutura de Pastas (O Que Procurar)

```
Stumble/
├── Launcher_GUI_1.1.au3          ← HUB CENTRAL (277 linhas, START HERE)
├── Overlay.au3                   ← UPDATE VISUAL (~180 linhas)
├── status.ini                    ← IPC CENTRAL (edites aqui para testar)
├── pixels.ini                    ← CALIBRAÇÃO (24 pontos)
├── README.md                     ← DOCUMENTAÇÃO (leia para entender projeto)
├── ANALISE_ESTRUTURAS_CONTROLE.md ← VERIFICAÇÃO DE SINTAXE
├── Calibragem/
│   └── Calibragem.au3            ← CALIBRAÇÃO v2.0 (novo com visuais)
├── Aimbot/
│   └── Aimbot_Teclado1.1_F7Close.au3 ← MIRA (simples, 135 linhas)
├── Plataforma/
│   └── PlataformaTimer.au3        ← TIMER (180 linhas)
├── AFK_FARM/
│   └── AFK_Test_Modos.au3         ← AUTOMAÇÃO (complexo, 900 linhas)
└── .github/
    └── copilot-instructions.md    ← TU ESTÁS AQUI
```

---

## 8. 🚀 Workflow: Adicionar Novo Módulo

### Passo 1: Criar script .au3

```autoit
#include <GUIConstantsEx.au3>
#RequireAdmin

Global Const $LOG = @ScriptDir & "\..\debug.log"

Func Debug($msg)
    FileWrite($LOG, "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] " & $msg & @CRLF)
EndFunc

; Seu código aqui
Debug("NovoModulo iniciado!")
HotKeySet("{F9}", "_Sair")  ; Defina hotkey exclusivo

Func _Sair()
    Exit
EndFunc

; Main loop...
```

### Passo 2: Adicionar em status.ini

```ini
[NOVOMODULO]
on=0
```

### Passo 3: Atualizar Launcher_GUI_1.1.au3

```autoit
; Linha 15-19: Adicionar path
Global Const $SCRIPT_NOVOMODULO = @ScriptDir & "\NovoModulo\NovoModulo.exe"

; Linha 32-37: Adicionar hotkey
HotKeySet("{F9}", "_HK_NOVOMODULO")

; Adicionar PID global
Global $PID_NovoModulo = 0

; Adicionar hotkey function
Func _HK_NOVOMODULO()
    _Toggle($SCRIPT_NOVOMODULO, $PID_NovoModulo)
EndFunc
```

### Passo 4: Atualizar Overlay.au3

```autoit
; Adicionar IniRead
$currentNovoModulo = IniRead($STATUS_INI, "NOVOMODULO", "on", "0")

; Adicionar card
Global $dataNovoModulo = _CriarCard($xPos, "NOVO MODULO", "OFF")
```

### Passo 5: Compilar & Testar

```batch
& $Aut2Exe /in "NovoModulo.au3" /out "NovoModulo.exe"
# Run Launcher_GUI_1.1.exe
```

---

## 9. 📝 Checklist para Code Review

Antes de comittar alterações, verificar:

- ✅ `#RequireAdmin` presente (se script manipula game)
- ✅ Todas as `Debug()` calls tem prefixo descritivo (ex: `[CALIBRAÇÃO]`)
- ✅ Global vars declaradas no topo com comments
- ✅ Todas as funções têm `Func` e `EndFunc` balanceados
- ✅ Todos os `While` têm `WEnd` correspondente
- ✅ Todos os `For` têm `Next` correspondente
- ✅ Todos os `If` têm `EndIf` correspondente
- ✅ Nenhum `IniRead()` sem backup/fallback
- ✅ Nenhum `ProcessClose()` sem PID válido
- ✅ Caminhos usam `@ScriptDir` (portável)
- ✅ Coordenadas de pixel têm base 1920×1080 com escala

---

## 10. 🎓 Recursos & Referências

- **AutoIt3 Docs**: https://www.autoitscript.com/autoit3/docs/
- **GUI Reference**: GUICtrlCreate\*, GUISetState, WinMove
- **Process Management**: Run(), ProcessClose(), WinWait(), WinGetHandle()
- **File I/O**: IniRead(), IniWrite(), FileWrite()
- **Pixel Detection**: PixelGetColor(), IsHexColorInRange()
- **Hotkeys**: HotKeySet() + standard keys

---

## 📞 Suporte Técnico

**Se encontrar erro não documentado aqui:**

1. Procure em `debug.log` por padrão de erro
2. Procure em `ANALISE_ESTRUTURAS_CONTROLE.md` por análise de sintaxe
3. Verifique se `status.ini` e `pixels.ini` existem com formato correto
4. Verifique se todos os EXEs foram compilados com Aut2Exe

---

## 🎯 Quick Reference — Último Status

| Item       | Versão  | Status           | Linhas    |
| ---------- | ------- | ---------------- | --------- |
| Launcher   | 1.1     | ✅ Limpo         | 277       |
| Calibragem | 2.0     | ✅ Remasterizado | ~450      |
| Overlay    | 1.0     | ✅ Estável       | ~180      |
| Aimbot     | 1.1     | ✅ OK            | ~135      |
| Plataforma | 1.0     | ✅ OK            | ~180      |
| AFK Farm   | 1.0     | ✅ Complexo      | ~900      |
| **TOTAL**  | **1.1** | **✅ PRONTO**    | **~2122** |

**Última atualização**: Março 2026  
**Versão do Projeto**: 1.1  
**AutoIt3**: v3.3+  
**Certificação de Código**: ✅ PASSOU
