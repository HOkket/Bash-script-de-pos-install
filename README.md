# HOKKET Install - Script de Pós-Instalação para Arch Linux

Este script foi projetado para automatizar e simplificar a configuração do ambiente de trabalho e lazer após uma nova instalação do Arch Linux ou de suas distribuições derivadas.

## Funcionalidades

- **Dois Modos de Instalação**:
  - **Automático**: Instala todos os pacotes e extensões pré-definidos no script de uma só vez.
  - **Manual**: Permite selecionar interativamente quais pacotes e extensões você deseja instalar.
- **Gerenciador de Pacotes AUR**: Verifica se o `yay` está instalado e, caso não esteja, oferece a opção de instalá-lo automaticamente.
- **Ampla Seleção de Softwares**: Inclui uma vasta gama de aplicativos para desenvolvimento, jogos, multimídia e produtividade.
- **Suporte a Ambientes de Desktop**:
  - Instalação de extensões populares para **GNOME**.
  - Instalação do **Caelestia Shell** para usuários do **Hyprland**.

## Softwares Inclusos (Exemplos)

A lista completa está no script. Abaixo estão alguns dos principais:

| Categoria     | Softwares                                                              |
|---------------|------------------------------------------------------------------------|
| **Jogos**     | Steam, Lutris, Heroic Games Launcher, Gamemode, ProtonPlus             |
| **Desenvolvimento** | VS Code, Git, Node.js, Python, Java (JDK), Docker                      |
| **Comunicação** | Vesktop (Discord), Teamspeak, Zapzap                                   |
| **Multimídia**  | OBS Studio, VLC, GIMP, Krita                                           |
| **Navegadores** | Firefox, Chromium, Brave                                               |
| **Outros**      | LibreOffice, VirtualBox, Free Download Manager                         |

### Extensões GNOME

- Dash-to-Dock
- Pop-Shell
- Appindicator
- Arc-Menu
- E muitas outras...

## Como Usar

1. **Clone o repositório ou baixe o script:**
   ```bash
   git clone <URL_DO_REPOSITORIO>
   cd <NOME_DO_DIRETORIO>
   ```
2. **Dê permissão de execução ao script:**
   ```bash
   chmod +x My_Arch.sh
   ```
3. **Execute o script:**
   ```bash
   ./My_Arch.sh
   ```
4. **Siga as instruções**: Escolha o modo de instalação (Manual ou Automático) e selecione os pacotes desejados, se aplicável.

## Pré-requisitos

- Um sistema operacional baseado em Arch Linux.
- Acesso à internet.
- Privilégios de superusuário (sudo).

## ⚠️ Observações

- Este script foi feito para ser executado em sistemas baseados em **Arch Linux** e utiliza os gerenciadores de pacotes `pacman` e `yay`.
- Revise a lista de pacotes dentro do arquivo `My_Arch.sh` para entender tudo o que pode ser instalado.
- **Use por sua conta e risco.** É sempre uma boa prática fazer backup de dados importantes antes de executar scripts que modificam o sistema.
