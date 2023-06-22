#!/bin/bash
clear

###Scrip de pos-instalação do Arch Linux e seus derivados.

# Uso: options=("um" "dois" "três"); inputChoice "Escolha:" 1 "${options[@]}"; choice=$?; echo "${options[$choice]}"
function inputChoice() {
    echo "${1}"; shift
    echo "$(tput dim)""- Alternar opção: [cima/baixo], Selecionar: [ENTER]" "$(tput sgr0)"
    local selected="${1}"; shift

    ESC=$(echo -e "\033")
    cursor_blink_on()  { tput cnorm; }
    cursor_blink_off() { tput civis; }
    cursor_to()        { tput cup $(($1-1)); }
    print_option()     { echo "$(tput sgr0)" "$1" "$(tput sgr0)"; }
    print_selected()   { echo "$(tput rev)" "$1" "$(tput sgr0)"; }
    get_cursor_row()   { IFS=';' read -rsdR -p $'\E[6n' ROW COL; echo "${ROW#*[}"; }
    key_input()        { read -rs -n3 key 2>/dev/null >&2; [[ $key = ${ESC}[A ]] && echo up; [[ $key = ${ESC}[B ]] && echo down; [[ $key = "" ]] && echo enter; }

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
            enter) break;;
            up)    ((selected--)); [ "${selected}" -lt 0 ] && selected=$(($# - 1));;
            down)  ((selected++)); [ "${selected}" -ge $# ] && selected=0;;
        esac
    done

    cursor_to "${lastrow}"
    cursor_blink_on
    echo

    return "${selected}"
}

# Uso: options=("um" "dois" "três"); inputChoice "Escolha:" 1 "${options[@]}"; choice=$?; echo "${options[$choice]}"
echo 'Este e um scipt de pos instação para sistemas linux baseados em Ubuntu e Arch'
options=("ARCH LINUX" "UBUNTU" "SAIR")
inputChoice "Choose:" 0 "${options[@]}"; choice=$?
SISTEMA=${options[$choice]}

if [ "$SISTEMA" = "ARCH LINUX" ]; then
    echo "Observe que antes de iniciarmos esta instalação o repositório multilib deve ser habilitado no arquivo pacman.conf"
    read -p "Deseja modificar automaticamente o arquivo pacman.conf agora?[s/n]" multilib

    ###Estrutura de verificação para a abertura do pacman.conf
    if [ "$multilib" = "s" ] || [ "$multilib" = "S" ]; then
        sudo sed -i.bkp 's/#\[multilib\]$/[multilib]\nInclude = \/etc\/pacman.d\/mirrorlist/' /etc/pacman.conf
    else
        echo "Sem o repositório multilib não é possível obter pacotes importantes para essa instalação."
        exit
    fi

    ###Sincronização e atualização inicial dos pacotes.
    sudo pacman -Syu

    ###opçoes do usuario.
    read -p "Deseja instalar drivers de video da NVIDIA?[s/n]" NVIDIA
    read -p "Deseja instalar o YAYHelper para gerenciamento do repositorio AUR?[s/n]" YAY

    if [ "$NVIDIA" = "s" ] || [ "$NVIDIA" = "S" ]; then
        NVIDIAPACKS="nvidia vulkan-icd-loader nvidia-utils vulkan-tools vulkan-validation-layers"
        sudo pacman -S "$NVIDIAPACKS"
        clear
    fi

    if [ "$YAY" = "s" ] || [ "$YAY" = "S" ] ; then
        cd /home/"$USER"/Downloads || return
        sudo pacman -S git go
        git clone https://aur.archlinux.org/yay-git.git
        cd yay-git || return
        makepkg -si
        clear
        cd ..
        rm -rf yay-git

        read -p "Deseja instalar a extenção PoPOS shell?[s/n] (funciona somente para GNOME)" POPSHELL
        if [ "$POPSHELL" = "s" ]  || [ "$POPSHELL" = "S" ]; then
            yay -S gnome-shell-extension-pop-shell || echo "Falha!"
            clear
        fi

    ### Instalação de pacotes referentes a games no linux.
    PACMAN="steam wine gamemode discord neofetch"
    YAYAPPS="lutris gnome-shell-extension-gamemode-git"
        sudo pacman -S "$PACMAN" && yay -S "$YAYAPPS" 
        clear
    neofetch
    fi

elif [ "$SISTEMA" = "UBUNTU" ]; then
    sudo apt update && sudo apt upgrade -y
    clear

    ###opçoes do usuario.
    read -p "Deseja instalar drivers de video da NVIDIA?[s/n] " NVIDIA

    if [ "$NVIDIA" = "s" ] || [ "$NVIDIA" = "S" ]; then
    NVIDIAPPA="add-apt-repository ppa:graphics-drivers/ppa"
    MESAPPA="add-apt-repository ppa:kisak/kisak-mesa"
    PACOTES_NVIDIA_MESA="mesa-* vulkan-* nvidia-driver-530 nvidia-settings"
    echo "Dois PPAs serão adicionados ao sistema o da NVIDA e do MESA. "
        sudo "$NVIDIAPPA"
        sudo "$MESAPPA"
        sudo apt update && sudo apt upgrade
        sudo apt install "$PACOTES_NVIDIA_MESA" -y
        clear
    fi

        read -p "Deseja instalar a extenção PoPOS shell?[s/n] (funciona somente para GNOME). " POPSHELL
        if [ "$POPSHELL" = "s" ] || [ "$POPSHELL" = "S" ]; then
            sudo apt install git node-typescript make -y
            cd /home/"$USER"/Downloads || return
            git clone https://github.com/pop-os/shell.git
            cd shell || return
            make local-install
            clear
        fi

    ### Instalação de pacotes referentes a games no linux.
    GAMEPACK="steam gamemode discord lutris neofetch"
    sudo apt install "$GAMEPACK" -y
    clear
    neofetch
fi