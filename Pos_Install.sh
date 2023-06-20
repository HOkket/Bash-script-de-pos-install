#!/bin/bash

###Scrip de pos-instalação do Arch Linux e seus derivados.
###Autor: Mateus A.M Ferreira

echo "Este e um scipt de pos instação para sistemas linux baseados em Ubuntu e Arch, selecione a base do seus sistema"
echo "{1} - ARCH LINUX"
echo "{2} - UBUNTU"
read -r SISTEMA

if [ "$SISTEMA" = "1" ]; then
    echo "Bem vindo" "$USER" "ao scrip de pos instalação do arch!"
    echo "Observe que antes de iniciarmos esta instalação o repositório multilib deve ser habilitado no arquivo pacman.conf"
    echo "Deseja abrir o arquivo pacman.conf agora?[s/n]"
    read -r multilib

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
    echo "Deseja instalar drivers de video da NVIDIA?[s/n]"
    read -r NVIDIA
    echo "Deseja instalar o YAYHelper para gerenciamento do repositorio AUR?[s/n]"
    read -r YAY

    if [ "$NVIDIA" = "s" ] || [ "$NVIDIA" = "S" ]; then
        sudo pacman -S nvidia vulkan-icd-loader nvidia-utils vulkan-tools vulkan-validation-layers
        clear
    fi

    if [ "$YAY" = "s" ] || [ "$YAY" = "S" ] ; then
        cd /home/"$USER"/Downloads cd ... || return
        sudo pacman -S git go
        git clone https://aur.archlinux.org/yay-git.git
        cd yay-git cd ... || return
        makepkg -si
        clear
        cd ..
        rm -rf yay-git

        echo "Deseja instalar a extenção PoPOS shell?[s/n] (funciona somente para GNOME)"
        read -r "POPSHELL"
        if [ "$POPSHELL" = "s" ]  || [ "$POPSHELL" = "S" ]; then
            yay -S gnome-shell-extension-pop-shell
            clear
        fi

        
    ### Instalação de pacotes referentes a games no linux.
    sudo pacman -S steam wine gamemode discord && yay -S lutris gnome-shell-extension-gamemode-git
    clear
    fi

elif [ "$SISTEMA" = "2" ]; then
    sudo apt update && sudo apt upgrade
    clear

    ###opçoes do usuario.
    echo "Deseja instalar drivers de video da NVIDIA?[s/n]"
    read -r NVIDIA

    if [ "$NVIDIA" = "s" ] || [ "$NVIDIA" = "S" ]; then
    echo "Dois PPAs serão adicionados ao sistema o da NVIDA e do MESA."
        sudo add-apt-repository ppa:graphics-drivers/ppa
        sudo add-apt-repository ppa:kisak/kisak-mesa
        sudo apt update && sudo apt upgrade
        sudo apt install mesa-* vulkan-* nvidia-driver-530 nvidia-settings
        clear
    fi

        echo "Deseja instalar a extenção PoPOS shell?[s/n] (funciona somente para GNOME)"
        read -r "POPSHELL"
        if [ "$POPSHELL" = "s" ] || [ "$POPSHELL" = "S" ]; then
            sudo apt install git node-typescript make -y
            cd /home/"$USER"/Downloads cd ... || return
            git clone https://github.com/pop-os/shell.git
            cd shell cd ... || return
            make local-install
            clear
        fi
        
    ### Instalação de pacotes referentes a games no linux.
    sudo apt install steam gamemode discord lutris -y
    clear
fi