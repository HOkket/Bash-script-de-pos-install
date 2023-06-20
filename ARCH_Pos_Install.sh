#!/bin/bash

###Scrip de pos-instalação do Arch Linux e seus derivados. 
###Autor: Mateus A.M Ferreira

echo "Bem vindo" "$USER" "ao scrip de pos instalação do arch!"
echo "Observe que antes de iniciarmos esta instalação o repositório multilib deve ser habilitado no arquivo pacman.conf"
echo "Deseja abrir o arquivo pacman.conf agora?[s/n]"
read -r multilib

###Estrutura de verificação para a abertura do pacman.conf
if [ "$multilib" = "s" ]; then
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

if [ "$NVIDIA" = "s" ]; then
    sudo pacman -S nvidia nvidia-utils
fi

if [ "$YAY" = "s" ]; then
    cd /home/"$USER"/Downloads cd ... || exit
    sudo pacman -S git go
    git clone https://aur.archlinux.org/yay-git.git
    cd yay-git cd ... || exit
    makepkg -si
    cd ..
    rm -rf yay-git
fi

 ### Instalação de pacotes referentes a games no linux.
 sudo pacman -S steam wine gamemode discord && yay -S lutris

 