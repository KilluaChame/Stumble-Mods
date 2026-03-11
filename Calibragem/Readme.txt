# 🎯 Calibragem - Módulo de Calibração de Pixels

## Descrição
Módulo independente para calibração de pontos de detecção de pixéis do AFK Farm.

## Hotkeys
- **ESC**: Fechar o módulo
- **P**: Capturar pixel quando em modo de captura

## Uso
1. Abra o módulo (clicando em "Calibrar Pixels" no launcher)
2. Selecione uma categoria (Verificações, Cliques ou Outros)
3. Selecione um ponto na lista
4. Clique em "Selecionar Ponto"
5. Posicione o mouse sobre o pixel e pressione **P**
6. Repita para todos os pontos desejados
7. Clique em "SALVAR TODOS" para gravar os pontos em `pixels.ini`

## Recursos
- ✅ Zoom dinâmico (0.5x a 3.0x)
- ✅ Visualização em tempo real dos pontos na tela
- ✅ Sistema de cores (Vermelho=padrão, Azul=selecionado, Verde=capturado)
- ✅ Debug logging completo
- ✅ Carregar pontos já salvos ao abrir

## Saída de Debug
Todos os eventos são registrados em `../debug.log` com prefixo `[CALIBRAÇÃO]`
