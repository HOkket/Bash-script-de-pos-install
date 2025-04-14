#!/bin/bash
clear

###Scrip de para auxiliar no pos-instalação do Arch Linux/Ubuntu e seus derivados.
###Autor: Mateus Ferreira ( github.com/HOkket )
###ver: 0.6

# Uso: options=("um" "dois" "três"); inputChoice "Escolha:" 1 "${options[@]}"; choice=$?; echo "${options[$choice]}"
function inputChoice() {
    echo "${1}"
    shift
    echo "$(tput dim)""- Alternar opção: [cima/baixo], Selecionar: [ENTER]" "$(tput sgr0)"
    local selected="${1}"
    shift

    ESC=$(echo -e "\033")
    cursor_blink_on() { tput cnorm; }
    cursor_blink_off() { tput civis; }
    cursor_to() { tput cup $(($1 - 1)); }
    print_option() { echo "$(tput sgr0)" "$1" "$(tput sgr0)"; }
    print_selected() { echo "$(tput rev)" "$1" "$(tput sgr0)"; }
    get_cursor_row() {
        IFS=';' read -rsdR -p $'\E[6n' ROW COL
        echo "${ROW#*[}"
    }
    key_input() {
        read -rs -n3 key 2>/dev/null >&2
        [[ $key = ${ESC}[A ]] && echo up
        [[ $key = ${ESC}[B ]] && echo down
        [[ $key = "" ]] && echo enter
    }

    for opt; do echo; done

    local lastrow
    lastrow=$(get_cursor_row)
    local startrow=$((lastrow - $#))
    trap "cursor_blink_on; echo; echo; exit" 2
    cursor_blink_off

    : selected:=0

    while true; do
        local idx=0
        for opt; do
            cursor_to $((startrow + idx))
            if [ ${idx} -eq "${selected}" ]; then
                print_selected "${opt}"
            else
                print_option "${opt}"
            fi
            ((idx++))
        done

        case $(key_input) in
        enter) break ;;
        up)
            ((selected--))
            [ "${selected}" -lt 0 ] && selected=$(($# - 1))
            ;;
        down)
            ((selected++))
            [ "${selected}" -ge $# ] && selected=0
            ;;
        esac
    done

    cursor_to "${lastrow}"
    cursor_blink_on
    echo

    return "${selected}"
}
# Função para escolha múltipla no terminal
function multiChoice {
    # Exibe a mensagem inicial
    echo "${1}"; shift
    echo "$(tput dim)""- Alterar Opção: [cima/baixo], Alterar Seleção: [espaço], Concluir: [ENTER]" "$(tput sgr0)"
     # Funções auxiliares para controle de impressão no terminal e entrada de teclado
    ESC=$( printf "\033")
    cursor_blink_on()   { printf "%s" "${ESC}[?25h"; } # Ativar piscar do cursor
    cursor_blink_off()  { printf "%s" "${ESC}[?25l"; } # Desativar piscar do cursor
    cursor_to()         { printf "%s" "${ESC}[$1;${2:-1}H"; } # Mover o cursor para posição específica
    print_inactive()    { printf "%s   %s " "$2" "$1"; } # Imprimir opção inativa
    print_active()      { printf "%s  ${ESC}[7m $1 ${ESC}[27m" "$2"; } # Imprimir opção ativa
    get_cursor_row()    { IFS=';' read -rsdR -p $'\E[6n' ROW COL; echo "${ROW#*[}"; } # Pegar a linha atual do cursor
    key_input()         { # Processar a entrada do teclado
        local key
        IFS= read -rsn1 key 2>/dev/null >&2
        if [[ $key = ""      ]]; then echo enter; fi;
        if [[ $key = $'\x20' ]]; then echo space; fi;
        if [[ $key = $'\x1b' ]]; then
            read -rsn2 key
            if [[ $key = [A ]]; then echo up;    fi;
            if [[ $key = [B ]]; then echo down;  fi;
        fi
    }
    toggle_option()    { # Alternar a opção selecionada
        local arr_name=$1
        eval "local arr=(\"\${${arr_name}[@]}\")"
        local option=$2
        if [[ ${arr[option]} == 1 ]]; then
            arr[option]=0
        else
            arr[option]=1
        fi
        eval "$arr_name"='("${arr[@]}")'
    }
     # Inicialização de variáveis
    local retval=$1
    local options
    local defaults
     IFS=';' read -r -a options <<< "$2"
    if [[ -z $3 ]]; then
        defaults=()
    else
        IFS=';' read -r -a defaults <<< "$3"
    fi
     local selected=()
     for ((i=0; i<${#options[@]}; i++)); do
        selected+=("${defaults[i]}")
        printf "\n"
    done
     # Determinar a posição atual da tela para sobrescrever as opções
    local lastrow
    lastrow=$(get_cursor_row)
    local startrow=$((lastrow - ${#options[@]}))
     # Garantir que o cursor e a entrada sejam exibidos novamente após um ctrl+c durante a leitura -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off
     local active=0
    while true; do
        # Imprimir opções sobrescrevendo as últimas linhas
        local idx=0
        for option in "${options[@]}"; do
            local prefix="[ ]"
            if [[ ${selected[idx]} == 1 ]]; then
                prefix="[x]"
            fi
             cursor_to $((startrow + idx))
            if [ $idx -eq $active ]; then
                print_active "$option" "$prefix"
            else
                print_inactive "$option" "$prefix"
            fi
            ((idx++))
        done
         # Controle de teclado do usuário
        case $(key_input) in
            space)  toggle_option selected $active;;
            enter)  break;;
            up)     ((active--));
                if [ $active -lt 0 ]; then active=$((${#options[@]} - 1)); fi;;
            down)   ((active++));
                if [ "$active" -ge ${#options[@]} ]; then active=0; fi;;
        esac
    done
     # Posição do cursor de volta ao normal
    cursor_to "$lastrow"
    printf "\n"
    cursor_blink_on
     indices=()
    for((i=0;i<${#selected[@]};i++)); do
        if ((selected[i] == 1)); then
            indices+=("${i}")
        fi
    done
     # Retornar os índices das opções selecionadas
    eval "$retval"='("${indices[@]}")'
}

# Uso: options=("um" "dois" "três"); inputChoice "Escolha:" 1 "${options[@]}"; choice=$?; echo "${options[$choice]}"
echo 'Este e um scipt de pos instação para sistemas linux baseados em Ubuntu e Arch'
options=("ARCH LINUX" "UBUNTU" "SAIR")
inputChoice "Selecione o sistema:" 0 "${options[@]}"
choice=$?
SISTEMA=${options[$choice]}

if [ "$SISTEMA" = "ARCH LINUX" ]; then
    echo "Observe que antes de iniciarmos esta instalação o repositório multilib deve ser habilitado no arquivo pacman.conf"
    echo "Deseja modificar automaticamente o arquivo pacman.conf agora?"
    options=("SIM" "NAO")
    inputChoice "Selecione:" 0 "${options[@]}"
    choice=$?
    multilib=${options[$choice]}

    ###Estrutura de verificação para a abertura do pacman.conf
    if [ "$multilib" = "SIM" ]; then
        sudo sed -i.bkp 's/#\[multilib\]$/[multilib]\nInclude = \/etc\/pacman.d\/mirrorlist/' /etc/pacman.conf
    else
        echo "Sem o repositório multilib não é possível obter pacotes importantes para essa instalação."
        exit
    fi

    ###Sincronização e atualização inicial dos pacotes.
    sudo pacman -Syu

    ###opçoes do usuario.
    echo "Deseja instalar drivers de video da NVIDIA?"
    options=("SIM" "NAO")
    inputChoice "Selecione:" 0 "${options[@]}"
    choice=$?
    NVIDIA=${options[$choice]}
    if [ "$NVIDIA" = "sim" ]; then
        NVIDIAPACKS="nvidia vulkan-icd-loader nvidia-utils vulkan-tools vulkan-validation-layers"
        sudo pacman -S "$NVIDIAPACKS"
        clear
    fi

    echo "Deseja instalar o YAYHelper para gerenciamento do repositorio AUR?"
    options=("SIM" "NAO")
    inputChoice "Selecione:" 0 "${options[@]}"
    choice=$?
    YAY=${options[$choice]}
    if [ "$YAY" = "SIM" ]; then
        cd /home/"$USER"/Downloads || return
        sudo pacman -S git go
        git clone https://aur.archlinux.org/yay-git.git
        cd yay-git || return
        makepkg -si
        clear
        cd ..
        rm -rf yay-git
    fi
    echo "Deseja instalar a extenção PoPOS shell? - (funciona somente para GNOME)"
    options=("SIM" "NAO")
    inputChoice "Selecione:" 0 "${options[@]}"
    choice=$?
    POPSHELL=${options[$choice]}
        if [ "$POPSHELL" = "SIM" ]; then
            yay -S gnome-shell-extension-pop-shell || echo "Falha!"
            clear
        fi

    # Instalação de pacotes referentes a games e uso geral no linux.
    # Exibe as opções para seleção
    multiChoice "Selecione as opções:" result " Discord; Steam; Wine; Neofetch; Lustris; Gamemode; OBS Studio; VLC; GIMP; Blender; LibreOffice; Firefox; Chromium; VSCode; Git; Node.js; Python; Java; Docker; VirtualBox" "0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0"   
    # Supondo que "result" seja o array com os índices selecionados
    selected_words=()
    for index in "${result[@]}"; do
        case $index in
            0) selected_words+=("discord");;
            1) selected_words+=("steam");;
            2) selected_words+=("wine");;
            3) selected_words+=("neofetch");;
            4) selected_words+=("lutris");;
            5) selected_words+=("gamemode");;
            6) selected_words+=("obs-studio");;
            7) selected_words+=("vlc");;
            8) selected_words+=("gimp");;
            9) selected_words+=("blender");;
            10) selected_words+=("libreoffice-fresh");;
            11) selected_words+=("firefox");;
            12) selected_words+=("chromium");;
            13) selected_words+=("code");;
            14) selected_words+=("git");;
            15) selected_words+=("nodejs");;
            16) selected_words+=("python");;
            17) selected_words+=("jdk-openjdk");;
            18) selected_words+=("docker");;
            19) selected_words+=("virtualbox");;
            # Adicione mais casos conforme necessário para cada opção
        esac
    done
    sudo pacman -S "${selected_words[@]}"

elif [ "$SISTEMA" = "UBUNTU" ]; then
    sudo apt update && sudo apt upgrade -y
    clear

    ###opçoes do usuario.
    echo 'Deseja instalar drivers de video da NVIDIA?'
    options=("SIM" "NAO")
    inputChoice "Selecione:" 0 "${options[@]}"
    choice=$?
    NVIDIA=${options[$choice]}
    if [ "$NVIDIA" = "SIM" ]; then
        # Dois PPAs serão adicionados ao sistema o da NVIDA e do MESA.
        NVIDIAPPA="add-apt-repository ppa:graphics-drivers/ppa"
        MESAPPA="add-apt-repository ppa:kisak/kisak-mesa"
        sudo "$NVIDIAPPA"
        sudo "$MESAPPA"
        sudo apt update && sudo apt upgrade
        NVIDIADRIVER=$(ubuntu-drivers devices | grep recommended | awk '{print $3}')
        sudo apt install "mesa-* vulkan-* ""$NVIDIADRIVER"" nvidia-settings" -y
        clear
    elif condition 
    then
        # Um PPA sera adicionado ao sistema (MESA-PPA).
        MESAPPA="add-apt-repository ppa:kisak/kisak-mesa"
        sudo "$MESAPPA"
        sudo apt update && sudo apt upgrade
    fi

    echo "Deseja instalar a extenção PoPOS shell? (funciona somente para GNOME)."
    options=("SIM" "NAO")
    inputChoice "Selecione:" 0 "${options[@]}"
    choice=$?
    POPSHELL=${options[$choice]}
    if [ "$POPSHELL" = "SIM" ]; then
        sudo apt install git node-typescript make -y
        cd /home/"$USER"/Downloads || return
        git clone https://github.com/pop-os/shell.git
        cd shell || return
        make local-install
        cd ..
        rm -rf shell/
        clear
    fi

    ### Instalação de pacotes referentes a games e uso geral no linux.
    # Exibe as opções para seleção
    multiChoice "Selecione as opções:" result "Discord;Steam;Wine;Neofetch;Lutris;Gamemode;OBS Studio;VLC;GIMP;Blender;LibreOffice;Firefox;Chromium;VSCode;Git;Node.js;Python;Java;Docker;VirtualBox" "0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0"   
    # Supondo que "result" seja o array com os índices selecionados
    selected_words=()
    for index in "${result[@]}"; do
        case $index in
            0) selected_words+=("discord");;
            1) selected_words+=("steam");;
            2) selected_words+=("wine");;
            3) selected_words+=("neofetch");;
            4) selected_words+=("lutris");;
            5) selected_words+=("gamemode");;
            6) selected_words+=("obs-studio");;
            7) selected_words+=("vlc");;
            8) selected_words+=("gimp");;
            9) selected_words+=("blender");;
            10) selected_words+=("libreoffice");;
            11) selected_words+=("firefox");;
            12) selected_words+=("chromium");;
            13) selected_words+=("code");;
            14) selected_words+=("git");;
            15) selected_words+=("nodejs");;
            16) selected_words+=("python3");;
            17) selected_words+=("default-jdk");;
            18) selected_words+=("docker.io");;
            19) selected_words+=("virtualbox");;
            # Adicione mais casos conforme necessário para cada opção
        esac
    done
    sudo apt install "${selected_words[@]}" -y
elif [ "$SISTEMA" = "SAIR" ]; then
    exit
fi
