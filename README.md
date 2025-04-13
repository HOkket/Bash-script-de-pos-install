# Script de Pós-Instalação para Ubuntu, Arch Linux e Derivados

Este script foi desenvolvido para automatizar tarefas essenciais após a instalação de sistemas Linux baseados em Ubuntu e Arch Linux. Ele simplifica a configuração inicial do sistema, permitindo que você economize tempo ao realizar ajustes e instalações comuns.

## Funcionalidades

- **Configuração de Repositórios**: Ajusta automaticamente os repositórios do sistema, incluindo o repositório multilib no Arch Linux.
- **Instalação de Drivers de Vídeo**: Oferece suporte para instalação de drivers NVIDIA e outros drivers necessários.
- **Gerenciamento de Pacotes AUR**: Instala o YAY, um gerenciador de pacotes para o repositório AUR (somente para Arch Linux).
- **Extensão Pop Shell**: Configura a extensão Pop Shell para GNOME em sistemas baseados no Arch Linux.
- **Pacotes para Jogos**: Instala ferramentas e aplicativos voltados para jogos, como Steam, Wine, Lutris, Discord, entre outros.

## Como Usar

1. Certifique-se de ter privilégios de superusuário (sudo).
2. Execute o script com o comando: `bash ./Pos_install.sh`.
3. Siga as instruções interativas apresentadas no terminal.
4. Escolha as opções desejadas para personalizar a configuração do sistema.

## Observações Importantes

- **Repositório Multilib**: O script verifica e habilita automaticamente o repositório multilib no Arch Linux, caso necessário.
- **Drivers NVIDIA**: A instalação de drivers NVIDIA é realizada de forma automatizada, caso selecionada.
- **Personalização**: Revise o código do script antes de executá-lo para garantir que ele atenda às suas necessidades específicas.
- **Riscos**: Faça backup de seus dados importantes antes de executar o script. Use-o por sua conta e risco.

Este script é uma ferramenta prática para configurar rapidamente seu sistema Linux após a instalação, oferecendo flexibilidade e eficiência para usuários iniciantes e avançados.