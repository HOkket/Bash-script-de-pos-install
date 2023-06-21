Script de Pós-Instalação para Arch Linux e Derivados 

Este é um script de pós-instalação para sistemas Linux baseados em Ubuntu e Arch. Ele automatiza algumas tarefas comuns após a instalação do sistema operacional, como a configuração de repositórios, instalação de drivers de vídeo e pacotes adicionais.
Uso

    Certifique-se de ter os privilégios de superusuário (sudo) para executar os comandos necessários. 
    Execute o script usando o comando  bash nome_do_arquivo.sh no terminal.
    Siga as instruções apresentadas pelo script. 
    Aguarde enquanto o script realiza as configurações e instalações necessárias. 

O script apresentará opções para você escolher, como instalar drivers de vídeo, configurar repositórios e instalar pacotes adicionais. Selecione as opções desejadas digitando "s" ou "n" quando solicitado. 
Observações 

    Arquivo pacman.conf : O script verificará se o repositório multilib está habilitado no arquivo  /etc/pacman.conf (apenas para o Arch Linux). Caso não esteja, você terá a opção de modificá-lo automaticamente durante a execução do script. 
    Drivers de vídeo NVIDIA : Se você selecionar a opção de instalar drivers de vídeo da NVIDIA, o script executará os comandos necessários para instalar os pacotes relevantes. 
    YAY e AUR : Se você escolher a opção de instalar o YAYHelper (apenas para o Arch Linux), o script executará os comandos necessários para instalar o YAY, que é um utilitário para gerenciar pacotes do repositório AUR.
    Extensão Pop Shell : Se você selecionar a opção de instalar a extensão Pop Shell (apenas para o Arch Linux e GNOME), o script executará os comandos necessários para instalar a extensão PoPOS Shell.
    Pacotes de jogos : O script instalará pacotes relacionados a jogos, como Steam, Wine, Gamemode, Discord, Lutris, entre outros. Esses pacotes podem variar dependendo do sistema operacional base. 

Lembre-se de revisar o código do script antes de executá-lo e ajustá-lo conforme necessário para atender às suas necessidades e especificações do sistema.

Importante : Execute este script por sua própria conta e risco. Sempre faça um backup dos seus dados importantes antes de executar qualquer script de pós-instalação ou de modificação do sistema operacional. 