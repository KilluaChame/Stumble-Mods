# 🎮 Stumble Mods - Suite de Automação para Stumble Guys

Uma coleção completa de scripts **AutoIt3** e EXEs compilados que trabalham em conjunto para oferecer um launcher, overlay visual e várias ferramentas de automação de jogo para **Stumble Guys**.

---

## 📋 Características Principais

### 🎯 **Aim Assist** (F7)

- Mira visual overlay que se posiciona automaticamente no centro da tela
- Rastreio dinâmico da janela do jogo
- Suporte para múltiplos botões do mouse (M1, M2, M4, M5)
- Detecção automática de pressão sustentada para ativação de movimento
- Fechar com **F7**

### ⏱️ **Plataforma Timer** (F8)

- Timer automático para plataformas no jogo
- Interface de overlay integrada
- Calibração com **F1** (quando ativado)
- Feedback visual em tempo real

### 👻 **AFK Farm** (F10)

- Automação para farming AFK
- Suporte para múltiplos modos:
  - **[F1]** Normal
  - **[F2]** Ranked
  - **[F3]** Custom
- Detecção automática de resolução (suporte multi-resolução)
- Algoritmo de transformação de coordenadas

### 🖼️ **Overlay Visual**

- Interface em tempo real mostrando status de todos os módulos
- Controle de transparência dinâmico (30-255)
- Posicionamento automático na janela do jogo
- Cores intuitivas: Verde (ativo) / Vermelho (desativo)
- Fechar com **F12**

### 🚀 **Launcher Central**

- Gerenciador unificado de todos os módulos
- Interface gráfica intuitiva com botões coloridos
- Controle de transparência via slider
- Atalhos via hotkeys (F7, F8, F10, F11)
- Sons de feedback (Windows Media)
- Fechar todos os módulos com **F11**

---

## 🎮 Hotkeys Globais

| Tecla   | Função                                  |
| ------- | --------------------------------------- |
| **F7**  | Toggle Aim Assist                       |
| **F8**  | Toggle Plataforma Timer                 |
| **F10** | Toggle AFK Farm                         |
| **F11** | Fechar Todos os Módulos                 |
| **F12** | Fechar Overlay                          |
| **F1**  | Calibração Plataforma / Normal Mode AFK |
| **F2**  | Ranked Mode AFK                         |
| **F3**  | Custom Mode AFK                         |

---

## 📁 Estrutura do Projeto

```
Stumble Mods/
├── Launcher_GUI_1.1.au3           # Gerenciador central
├── Launcher_GUI_1.1.exe           # Compilado do launcher
├── Overlay.au3                     # Interface de overlay visual
├── Overlay.exe                     # Compilado do overlay
├── status.ini                      # Arquivo de IPC (Single Source of Truth)
├── README.md                       # Este arquivo
├── .gitignore                      # Arquivos ignorados
├── Aimbot/
│   ├── Aimbot_Teclado1.1_F7Close.au3      # Script source
│   ├── Aimbot_Teclado1.1_F7Close.exe      # Compilado
│   └── README.txt
├── Plataforma/
│   ├── PlataformaTimer.au3                # Script source
│   ├── PlataformaTimer.exe                # Compilado
│   └── README.txt
└── AFK_FARM/
    ├── AFK_Test_Modos - Copia.au3         # Script source
    ├── AFK_Test_Modos - Copia.exe         # Compilado
    └── README.txt
```

---

## 🔧 Requisitos

- **Windows 7+** (testado em Windows 10/11)
- **AutoIt3 v3.3+** (para editar/compilar scripts)
- **Privilégios de Administrador** (necessários para injetar inputs)
- **Stumble Guys** instalado e executável

---

## 🚀 Como Usar

### 1. **Executar o Launcher**

```bash
# Compile primeiro ou execute direto:
Launcher_GUI_1.1.exe
```

> ⚠️ **Importante**: Execute como Administrador (botão direito → Executar como administrador)

### 2. **Interface do Launcher**

- Botões verdes = Módulo inativo (clique para iniciar)
- Botões vermelhos = Módulo ativo (clique para parar)
- Slider = Controla transparência do overlay (30-255)

### 3. **Usar os Módulos**

#### Aim Assist

- Pressione e segure qualquer botão do mouse (M1, M2, M4, M5)
- A mira aparecerá automaticamente
- Após 100ms de pressão, o mod ativa movimento automático (W)
- Solte o mouse para disparar a habilidade

#### Plataforma Timer

- Clique em iniciar
- Use **F1** para calibração quando necessário
- Overlay mostrará status em tempo real

#### AFK Farm

- Clique em iniciar
- Escolha o modo: **F1** (Normal), **F2** (Ranked) ou **F3** (Custom)
- O script automatizará ações no jogo

### 4. **Controle Via Hotkeys**

Você pode controlar tudo via teclado mesmo com o jogo em foco:

- F7 = Liga/desliga Aim
- F8 = Liga/desliga Plataforma
- F10 = Liga/desliga AFK Farm
- F11 = Fecha tudo
- F12 = Fecha overlay

---

## 📝 Arquivo de Configuração (status.ini)

O projeto usa um arquivo `status.ini` como mecanismo central de IPC (Inter-Process Communication):

```ini
[AIM]
on=0                    ; 0 = desativo, 1 = ativo

[PLATAFORMA]
on=0                    ; 0 = desativo, 1 = ativo

[AFK]
on=0                    ; 0 = desativo, 1 = ativo

[CONFIG]
Alpha=150               ; Transparência do overlay (30-255)
```

**Nota**: Este arquivo é o "single source of truth" - todos os módulos leem e escrevem nele para sincronização.

---

## 🔨 Compilar Scripts

Se você modificar algum `.au3`, precisa recompilá-lo para `.exe`:

### Via GUI (Aut2Exe)

1. Abra `Aut2Exe.exe` (instale AutoIt3 se não tiver)
2. Input File: selecione o `.au3`
3. Output File: coloque o caminho do `.exe` desejado
4. Clique "Convert"

### Via Command Line

```batch
"C:\Program Files (x86)\AutoIt3\Aut2Exe\Aut2Exe.exe" /in "Aimbot_Teclado1.1_F7Close.au3" /out "Aimbot_Teclado1.1_F7Close.exe"
```

---

## ⚙️ Configuração e Personalização

### Modificar Caminhos dos EXEs

Se você moveu os arquivos, edite `Launcher_GUI_1.1.au3`:

```autoIt3
; Linha ~20
Global Const $SCRIPT_AIMBOT = "C:\Users\lizzi\OneDrive\Desktop\Jogos\Mods\Stumble\Aimbot\Aimbot_Teclado1.1_F7Close.exe"
Global Const $SCRIPT_PLATAFORMA = "C:\Users\lizzi\OneDrive\Desktop\Jogos\Mods\Stumble\Plataforma\PlataformaTimer.exe"
Global Const $SCRIPT_AFK = "C:\Users\lizzi\OneDrive\Desktop\Jogos\Mods\Stumble\AFK_FARM\AFK_Test_Modos - Copia.exe"
```

### Personalizas Cores da Mira (Aimbot)

Em `Aimbot_Teclado1.1_F7Close.au3`:

```autoIt3
; Linha ~23
Global $CorMira = 0x00FF00    ; Verde (mira normal)
Global $CorBorda = 0x000000   ; Preto (borda)
Global $CorVermelho = 0xFF0000 ; Vermelho (modo segurar)
```

### Ajustar Distância da Mira

```autoIt3
Global $Subida = 85           ; Distância vertical do centro da tela
Global $Comprimento = 20      ; Tamanho da mira
Global $Espessura = 2         ; Espessura das linhas
```

---

## 🐛 Troubleshooting

### O overlay não aparece

- ✅ Verifique se o `Overlay.exe` está compilado
- ✅ Abra o Stumble Guys ANTES de iniciar o launcher
- ✅ Execute como Administrador

### Os módulos não se comunicam

- ✅ Verifique se `status.ini` existe no diretório raiz
- ✅ Confirme se todos os caminhos em `Launcher_GUI_1.1.au3` estão corretos

### Aim não funciona

- ✅ Confirme se o jogo está em foco (ativo)
- ✅ Verifique se está usando botões do mouse suportados (M1, M2, M4, M5)
- ✅ Teste com privilégios de Administrador

### Coordenadas de AFK incorretas

- ✅ O script suporta multi-resolução via `TransformCoordinates()`
- ✅ Se estiver com resolução diferente de 1920x1080, calibre novamente

---

## 📦 Arquivo .gitignore

Arquivo `Stumble Mods/.gitignore`:

```
# Compilados
*.exe
*.dll
*.obj

# Backups
*Backup*
*Copia*
*.bak
*.tmp

# Logs e temporários
*.log
*.ini~

# IDE
.vscode/
*.sublime-*

# Sistema
.DS_Store
Thumbs.db
```

---

## 📄 Licença

Este projeto é fornecido como-é para uso pessoal em **Stumble Guys**. Use por sua conta e risco.

---

## 📧 Contribuições & Feedback

Encontrou um bug? Tem sugestões? Abra uma **issue** ou um **pull request**!

---

## 🎓 Detalhes Técnicos

### Arquitetura de IPC

- **Mecanismo**: Arquivo INI (`status.ini`)
- **Sincronização**: Single Source of Truth
- **Latência**: ~150ms (refresh do overlay)

### Overlay Performance

- Loop de atualização: 150ms
- WinSetTrans para transparência dinâmica
- Flicker mitigation: verifica mudanças antes de atualizar

### Detecção Pixel-Based

- Suporta multi-resolução com `TransformCoordinates()`
- Base resolution: 1920x1080
- Scaling automático para 16:9

---

**Desenvolvido com ❤️ para a comunidade Stumble Guys**

Divirta-se! 🎮
