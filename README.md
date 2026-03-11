# 🎮 Stumble Mods - Suite de Automação para Stumble Guys

Uma coleção completa e profissional de scripts **AutoIt3** e EXEs compilados que trabalham em conjunto para oferecer um **launcher unificado**, **overlay visual em tempo real** e **múltiplas ferramentas de automação** para Stumble Guys.

**Status**: ✅ Totalmente Funcional | **Versão**: 1.1 | **Última Atualização**: Março 2026

---

## 🎯 Visão Geral

Este projeto oferece uma solução integrada para automação e assistência em Stumble Guys através de **6 módulos independentes** que se comunicam via arquivos de configuração compartilhados (INI). Cada módulo roda como um EXE separado, permitindo total isolamento, independência e controle granular.

**Arquitetura**: Launcher (hub) → 5 módulos autônomos + 1 overlay (monitoramento)

---

## 📦 Módulos do Sistema

### 1️⃣ 🎯 **Aim Assist** — Mira Visual Automática

**Arquivo**: `Aimbot/Aimbot_Teclado1.1_F7Close.exe`  
**Atalho**: `F7` (toggle) | **Status**: Active ✅

**Funcionalidades**:

- ✅ Mira visual overlay com linhas cruzadas (20px)
- ✅ Posicionamento automático no centro da tela
- ✅ Rastreio dinâmico da janela do jogo
- ✅ Suporte para múltiplos botões (M1, M2, M4, M5)
- ✅ Detecção automática de movimentação
- ✅ Ativação com **pressão do mouse** (100ms = ativo)

**Como usar**: Pressione e segure qualquer botão do mouse. A mira aparecerá no centro, e após 100ms, o script automaticamente pressiona `W` para movimento.

---

### 2️⃣ ⏱️ **Plataforma Timer** — Cronômetro de Parkour

**Arquivo**: `Plataforma/PlataformaTimer.exe`  
**Atalho**: `F8` (toggle) | `F1` (calibração) | **Status**: Active ✅

**Funcionalidades**:

- ✅ Timer automático com overlay visual
- ✅ Interface interativa de gravação de tempo
- ✅ Marcação com **ESPAÇO** (quando plataforma detectada)
- ✅ Feedback visual com cores progressivas
- ✅ Sons de sistema para confirmação
- ✅ Debug logging completo

**Como usar**:

1. Clique no botão PLATAFORMA nas Launcher
2. Use **F1** para calibração (quando ativado)
3. Pressione **ESPAÇO** para marcar tempo na plataforma
4. O overlay mostrará o tempo decorrido com status

---

### 3️⃣ 👻 **AFK Farm** — Automação Completa de Farming

**Arquivo**: `AFK_FARM/AFK_Test_Modos.exe`  
**Atalho**: `F10` (toggle) | **Status**: Active ✅

**Funcionalidades**:

- ✅ 3 modos de operação automática
- ✅ Detecção avançada de pixels com tolerância
- ✅ Suporte multi-resolução (base: 1920×1080)
- ✅ Transformação automática de coordenadas
- ✅ 14 categorias de pontos calibrados (24 pontos totais)
- ✅ Sistema dinâmico de eventos

**Modos de Operação**:

| Tecla | Modo       | Descrição                                  |
| ----- | ---------- | ------------------------------------------ |
| `F1`  | **Normal** | Farming automatizado padrão                |
| `F2`  | **Ranked** | Modo competitivo automático                |
| `F3`  | **Custom** | Personalizado (selecione evento com `1-4`) |

**Detecção Automática**:

- Menu principal do jogo
- Anúncios e pop-ups
- Telas de recompensa (quests, diária, ranked)
- Menus de evento
- Status do jogo (em andamento, perdido, ganho)

---

### 4️⃣ 🖼️ **Overlay Visual** — Status em Tempo Real

**Arquivo**: `Overlay.exe`  
**Atalho**: `F12` (fechar) | **Status**: Sempre Ativo ✅

**Funcionalidades**:

- ✅ Painel com 3 cards mostrando status em tempo real
- ✅ Cores intuitivas (Verde=ativo, Vermelho=desativo)
- ✅ Controle de transparência dinâmico (30-255)
- ✅ Posicionamento automático na janela do jogo
- ✅ Sem interferência com gameplay (mouse atravessa)
- ✅ Sincronização automática com status.ini

**Informações Exibidas**:

- 🟢 Status AIM ASSIST (Verde/Vermelho)
- 🟢 Status PLATAFORMA TIMER (Verde/Vermelho)
- 🟢 Status AFK FARM (Verde/Vermelho + modo ativo)
- 📍 Hints de hotkeys secundárias
- 🎚️ Valor de transparência atual (CONFIG > Alpha)

---

### 5️⃣ 🎨 **Calibragem 2.0** — Ferramenta Profissional de Calibração

**Arquivo**: `Calibragem/Calibragem.exe`  
**Versão**: 2.0 | **Status**: ✅ Completamente Remasterizado

**Funcionalidades Novas (v2.0)**:

- ✅ Interface clean com 3 painéis (Categorias | Pontos | Ações)
- ✅ Carregamento dinâmico de **14 categorias**
- ✅ Sistema de filtro por categoria com lista interativa
- ✅ **🆕 Visualização de pontos em tempo real na tela**
- ✅ **🆕 Marcadores visuais com cores dinâmicas**
- ✅ **🆕 Sistema de feedback com transições de cores**
- ✅ Captura de pixel com `P` (modo captura)
- ✅ Salvamento automático em `pixels.ini`
- ✅ Debug logging com prefixo `[CALIBRAÇÃO]`

**Sistema de Cores** (marcadores na tela):

- 🔴 **Vermelho** = Padrão (não capturado)
- 🔵 **Azul** = Ponto selecionado
- 🟢 **Verde** = Ponto capturado com sucesso
- ⬛ **Borda Preta** = Todos os marcadores (24×24px)

**Como usar a Calibragem**:

1. Clique em **[CALIBRAR PIXELS]** no Launcher
2. Selecione uma **categoria** na lista esquerda
3. Os pontos dessa categoria aparecerão na lista do meio
4. Clique em um ponto e depois em **Selecionar Ponto**
5. Posicione o mouse sobre o pixel no jogo e pressione **P**
6. O ponto ficará verde e um marcador aparecerá na tela
7. Repita para todos os pontos desejados
8. Clique em **SALVAR TODOS** para gravar em `pixels.ini`

**Categorias Disponíveis** (14 total):

**Detecção** (8 categorias):

- DetectMainMenu
- DetectAdvert
- DetectGameRunning
- DetectGameLost
- DetectGetReward
- DetectEventMenu
- DetectItemReceived
- DetectRankedMenu

**Cliques** (6 categorias):

- ClickMainMenu
- ClickAdvert
- ClickGetReward
- ClickEventMenu
- ClickEventExit
- ClickStartGame

---

### 6️⃣ 🚀 **Launcher Central** — Hub de Controle Unificado

**Arquivo**: `Launcher_GUI_1.1.exe`  
**Status**: Sempre Rodando ✅

**Funcionalidades**:

- ✅ Interface gráfica intuitiva com 6 botões principais
- ✅ Controle de transparência via slider (30-255)
- ✅ Status visual em tempo real (Verde=ativo, Vermelho=inativo)
- ✅ Suporte bilíngue (PT-BR / EN) com **F12** para alternar
- ✅ Sons de feedback para cada ação
- ✅ Gerenciamento robusto de processos
- ✅ Informações do projeto ("Sobre")

**Botões Principais**:

- `[AIM ASSIST]` — Alternar mira visual (F7)
- `[PLATAFORMA]` — Alternar timer de plataforma (F8)
- `[AFK FARM]` — Alternar automação (F10)
- `[CALIBRAR PIXELS]` — Abrir ferramenta de calibração (Calibragem v2.0)
- `[FECHAR TUDO]` — Encerrar todos os módulos (F11)
- **Slider** — Controlar transparência (30-255)

---

## 🎮 Hotkeys Globais Completas

### Controle Principal

| Tecla   | Função                           | Módulo Afetado     |
| ------- | -------------------------------- | ------------------ |
| **F7**  | Toggle Aim Assist                | Aimbot             |
| **F8**  | Toggle Plataforma Timer          | PlataformaTimer    |
| **F10** | Toggle AFK Farm                  | AFK_Farm           |
| **F11** | Fechar TODOS os módulos          | Launcher           |
| **F12** | Fechar Overlay / Alternar Idioma | Overlay / Launcher |

### Controle Secundário (quando módulo ativo)

| Tecla      | Função                   | Módulo           | Contexto                               |
| ---------- | ------------------------ | ---------------- | -------------------------------------- |
| **F1**     | Calibração / Normal Mode | Plataforma + AFK | Plataforma ativa ou AFK em modo custom |
| **F2**     | Ranked Mode AFK          | AFK_Farm         | AFK Farm ativo                         |
| **F3**     | Custom Mode AFK          | AFK_Farm         | AFK Farm ativo                         |
| **1-4**    | Selecionar evento        | AFK_Farm         | Custom Mode ativo                      |
| **P**      | Capturar pixel           | Calibragem       | Modo calibração ativo (ESC para sair)  |
| **ESPAÇO** | Marcar tempo             | Plataforma       | Plataforma ativa                       |

---

## 📁 Estrutura do Projeto

```
Stumble Mods/
├── Launcher_GUI_1.1.au3           # Source: Gerenciador central (277 linhas)
├── Launcher_GUI_1.1.exe           # Executável compilado (914 KB)
├── Overlay.au3                    # Source: Interface overlay visual
├── Overlay.exe                    # Executável compilado (910 KB)
├── status.ini                     # IPC: Single Source of Truth
├── pixels.ini                     # Calibração: 14 categorias, 24 pontos
├── README.md                      # Este arquivo (documentação)
├── ANALISE_ESTRUTURAS_CONTROLE.md # Análise de estruturas de código
├── Depois fazer.txt               # TODO: melhorias futuras
├── .gitignore                     # Arquivos a ignorar no git
│
├── Aimbot/
│   ├── Aimbot_Teclado1.1_F7Close.au3    # Source: Mira visual
│   ├── Aimbot_Teclado1.1_F7Close.exe    # Executável (935 KB)
│   ├── Aimbot_Teclado1.1_F7Close - Backup.au3
│   └── README.txt
│
├── Plataforma/
│   ├── PlataformaTimer.au3               # Source: Timer de parkour
│   ├── PlataformaTimer.exe               # Executável (935 KB)
│   ├── PlataformaTimer - Backup.au3
│   └── README.txt
│
├── AFK_FARM/
│   ├── AFK_Test_Modos.au3                # Source: Automação AFK
│   ├── AFK_Test_Modos.exe                # Executável (905.5 KB)
│   ├── AFK_Test_Modos - Backup.au3
│   └── README.txt
│
├── Calibragem/
│   ├── Calibragem.au3                    # Source: Calibração v2.0
│   ├── Calibragem.exe                    # Executável (915 KB)
│   └── README.txt
│
├── .github/
│   └── copilot-instructions.md           # Instruções para AI
│
└── Backup/                               # Backups automáticos
```

---

## 🔧 Requisitos do Sistema

| Requisito        | Versão/Detalhe                            |
| ---------------- | ----------------------------------------- |
| **Windows**      | 7+ (testado em 10 e 11) ✅                |
| **AutoIt3**      | v3.3+ (para compilar scripts)             |
| **Privilégios**  | Administrador (necessário para inputs)    |
| **Stumble Guys** | Versão atual (qualquer versão)            |
| **Resolução**    | 1920×1080 (base; suporta multi-resolução) |

---

## 🚀 Como Começar

### 1. Instalação Rápida

```bash
# 1. Extrair todos os arquivos para uma pasta
# 2. Executar Launcher_GUI_1.1.exe como administrador
# 3. Pronto! Interface aparecerá
```

### 2. Primeira Execução

```
[LAUNCHER ABERTO]
├─ Clique em [AIM ASSIST] para ativar mira
├─ Clique em [PLATAFORMA] para ativar timer
├─ Clique em [AFK FARM] para ativar automação
├─ Use o Slider para ajustar transparência
└─ Veja status em tempo real no Overlay
```

### 3. Controle via hotkeys (recomendado)

```
Foque o jogo e use:
- F7 = Ativa/desativa Aim (mesmo com jogo focus)
- F8 = Ativa/desativa Plataforma
- F10 = Ativa/desativa AFK Farm
- F11 = Fecha tudo de uma vez
- F12 = Fecha o overlay
```

### 4. Calibração de Pontos

```
Se os pontos estão errados ou você quer adicionar novos:
1. Clique em [CALIBRAR PIXELS] no Launcher
2. Interface profissional abre com 14 categorias
3. Selecione categoria → ponto → Marque na tela com P
4. Salve tudo em SALVAR TODOS
5. Reinicie os módulos de automação
```

---

## 📊 Status do Projeto

| Componente     | Status               | Versão  | Tamanho    |
| -------------- | -------------------- | ------- | ---------- |
| Launcher       | ✅ Funcional         | 1.1     | 914 KB     |
| Overlay        | ✅ Funcional         | 1.0     | 910 KB     |
| Aimbot         | ✅ Funcional         | 1.1     | 935 KB     |
| Plataforma     | ✅ Funcional         | 1.0     | 935 KB     |
| AFK Farm       | ✅ Funcional         | 1.0     | 905.5 KB   |
| **Calibragem** | ✅ **Remasterizado** | **2.0** | **915 KB** |

---

## 🎨 Explicação do Sistema de Cores

### Overlay

- 🟢 **Verde** = Módulo ativo e funcionando
- 🔴 **Vermelho** = Módulo desativo ou parado

### Calibragem (Marcadores na Tela)

- 🔴 **Vermelho** = Ponto não capturado
- 🔵 **Azul** = Ponto selecionado
- 🟢 **Verde** = Ponto capturado com sucesso

### Interface

- 🟢 **Verde** = Pronto / Ativo
- 🔴 **Vermelho** = Inativo / Parado

---

## 🐛 Troubleshooting

### Problema: Scripts não compilam

**Solução**: Instale AutoIt3 em `C:\Program Files (x86)\AutoIt3\`

### Problema: "Acesso negado" ao executar

**Solução**: Execute como Administrador (clique direito → Executar como administrador)

### Problema: Pontos de detecção não funcionam

**Solução**: Use [CALIBRAR PIXELS] para recalibrar (v2.0 agora exibe visual dos pontos)

### Problema: Overlay não aparece

**Solução**: Feche e reabra com F12, ou reinicie o Launcher

### Problema: AFK Farm não detecta eventos

**Solução**:

1. Abra Calibragem
2. Selecione categoria DetectMainMenu
3. Comprueba que os pontos aparecem em vermelho na tela
4. Se não aparecem, recalibre com ferramenta

### Problema: Aplicação congela ao iniciar

**Solução**: Verifique que `pixels.ini` existe e tem formato correto

---

## 💡 Dicas & Boas Práticas

### Otimização

- Deixe Overlay sempre ativo para monitorar status
- Use F7/F8/F10 em vez de clicar (mais rápido)
- Calibre pontos uma vez com Calibragem v2.0 e guarde em arquivo seguro

### Performance

- Resolução base é 1920×1080 (escala automática para outras resoluções)
- Scripts independentes não travam uns aos outros
- Cada módulo usa <50MB de RAM

### Customização

- Edite `pixels.ini` para adicionar/remover pontos
- Edite `status.ini` para valores padrão
- Recompile com Aut2Exe.exe se preferir versão personalizada

---

## 📝 Notas de Versão

### v1.1 (Atual - Março 2026)

- ✅ **Calibragem remasterizado para v2.0**
- ✅ Marcadores visuais na tela (Vermelho/Azul/Verde)
- ✅ Limpeza de código do Launcher (875 → 277 linhas)
- ✅ Suporte para 14 categorias de calibração
- ✅ Debug logging completo com `[CALIBRAÇÃO]` prefix
- ✅ Todos os módulos compilados e testados

### v1.0 (Anterior)

- Funcionalidade básica de automação
- 6 módulos independentes
- Interface de Launcher com slider
- Suporte bilíngue

---

## 📝 License

This project is licensed under a **Dual License**:

- **Personal Use**: Free of charge.
- **Commercial Use**: Requires a paid license.

For commercial inquiries or to purchase a license, please contact me via [LinkedIn](https://www.linkedin.com/in/mateus-chame).

## 👨‍💻 Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para:

- Reportar bugs
- Sugerir novas funcionalidades
- Enviar pull requests com melhorias

## 📧 Contato

- Issues: Abra uma issue no GitHub
- Instagram: [@mateus_chame](https://www.instagram.com/mateus_chame/)
- Me contrate: 💼[LinkedIn](https://www.linkedin.com/in/mateus-chame)

---

**Feito com ❤️ para quem gosta de Stumble Guys!** 🎮

**💸 Me compre um café: 🥤[Ko-fi](https://ko-fi.com/mateuschame)**

---

## ⚖️ Disclaimer

Este projeto é fornecido "como está" para fins educacionais e de produtividade pessoal. Usar automação em jogos online pode violar termos de serviço. Use por sua conta e risco.

**Última manutenção**: Março 2026  
**Dev**: Mateus Chame  
**Versão do Projeto**: 1.1 | **AutoIt3 v3.3+**
