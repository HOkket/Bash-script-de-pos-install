#!/bin/bash

# Este é um script fresco projetado para fazer boa parte da minha configuração pós-instalação do arch linux ou suas derivaçoes

## Variáveis ---------------------------------
PKG_PACMAN=$(command -v pacman)
PKG_YAY=$(command -v yay)
USR_SHELL=$(command -v gnome-shell)
<<<<<<< HEAD
USR_HYPERLAND=$(command -v hyprland)
=======
>>>>>>> 0b97c3c (Remoção do suporte a ubuntu.)



# Definição dos pacotes (Nome Amigável="Nome do Pacote")
# Isso centraliza a manutenção do script em um só lugar.
declare -A MAPA_PACOTES=(
    ["Vesktop"]="vesktop"
    ["Steam"]="steam"
    ["Wine"]="wine"
    ["Charles"]="charles-bundled-java"
    ["Lutris"]="lutris-wine-meta"
    ["Gamemode"]="gamemode"
    ["OBS Studio"]="obs-studio"
    ["VLC"]="vlc"
    ["GIMP"]="gimp"
    ["Free Download Manager"]="freedownloadmanager"
    ["LibreOffice"]="libreoffice-fresh"
    ["Firefox"]="firefox"
    ["Chromium"]="chromium"
    ["Teamspeak"]="teamspeak3"
    ["Git"]="git"
    ["Node.js"]="nodejs"
    ["Python"]="python"
    ["Java"]="jdk-openjdk"
    ["Docker"]="docker"
    ["VirtualBox"]="virtualbox"
    ["Heroic Games"]="heroic-games-launcher-bin"
    ["Krita"]="krita krita-plugin-gmic"
    ["VsCode"]="visual-studio-code-bin"
    ["Zapzap"]="zapzap"
    ["Brave"]="brave-bin"
    ["ProtonPlus"]="protonplus"
    ["JLess"]="jless"
)

# Extensões do GNOME
declare -A MAPA_EXTENSOES=(
    ["Dash-to-dock"]="gnome-shell-extension-dash-to-dock"
    ["Gnome-4x"]="gnome-shell-extension-gnome-ui-tune-git"
    ["Pop-Shell"]="gnome-shell-extension-pop-shell-git"
    ["Appindicator"]="gnome-shell-extension-appindicator"
    ["Arc-Menu"]="gnome-shell-extension-arc-menu"
    ["Caffeine"]="gnome-shell-extension-caffeine"
    ["Dash-to-Panel"]="gnome-shell-extension-dash-to-panel"
    ["Desktop-icons"]="gnome-shell-extension-desktop-icons-ng"
    ["User-themes"]="gnome-shell-extension-user-theme-x-git"
)

# declaraçoes de funçoes! -------------------------------------
# Usage: bannerColor "my title" "red" "*"
function bannerColor() {
    case ${2} in
        black) color=0
        ;;
        red) color=1
        ;;
        green) color=2
        ;;
        yellow) color=3
        ;;
        blue) color=4
        ;;
        magenta) color=5
        ;;
        cyan) color=6
        ;;
        white) color=7
        ;;
        *) echo "color is not set"; exit 1
        ;;
    esac

    local msg="${3} ${1} ${3}"
    local edge
    edge=${msg//?/$3}
    tput setaf ${color}
    tput bold
    echo "${edge}"
    echo "${msg}"
    echo "${edge}"
    tput sgr 0
    echo
}

## Funçoes de menus de escolha unica
# Uso: options=("um" "dois" "três"); inputChoice "Escolha:" 1 "${options[@]}"; choice=$?; echo "${options[$choice]}"
function inputChoice() {
    echo "${1}"; shift
    echo "$(tput dim)""- Mude de opção : [↑/↓], Selecione com: [ENTER]" "$(tput sgr0)"
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

#função de menu de escilha multipla
# Usage: multiChoice "header message" resultArray "comma separated options" "comma separated default values"
# Credit: https://serverfault.com/a/949806
function multiChoice {
    echo "${1}"; shift
    echo "$(tput dim)""- Change Option: [↑/↓], Change Selection: [space], Done: [ENTER]" "$(tput sgr0)"
    # little helpers for terminal print control and key input
    ESC=$( printf "\033")
    cursor_blink_on()   { printf "%s" "${ESC}[?25h"; }
    cursor_blink_off()  { printf "%s" "${ESC}[?25l"; }
    cursor_to()         { printf "%s" "${ESC}[$1;${2:-1}H"; }
    print_inactive()    { printf "%s   %s " "$2" "$1"; }
    print_active()      { printf "%s  ${ESC}[7m $1 ${ESC}[27m" "$2"; }
    get_cursor_row()    { IFS=';' read -rsdR -p $'\E[6n' ROW COL; echo "${ROW#*[}"; }
    key_input()         {
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
    toggle_option()    {
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

    # determine current screen position for overwriting the options
    local lastrow
    lastrow=$(get_cursor_row)
    local startrow=$((lastrow - ${#options[@]}))

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local active=0
    while true; do
        # print options by overwriting the last lines
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

        # user key control
        case $(key_input) in
            space)  toggle_option selected $active;;
            enter)  break;;
            up)     ((active--));
                if [ $active -lt 0 ]; then active=$((${#options[@]} - 1)); fi;;
            down)   ((active++));
                if [ "$active" -ge ${#options[@]} ]; then active=0; fi;;
        esac
    done

    # cursor position back to normal
    cursor_to "$lastrow"
    printf "\n"
    cursor_blink_on

    indices=()
    for((i=0;i<${#selected[@]};i++)); do
        if ((selected[i] == 1)); then
            indices+=("${i}")
        fi
    done

    # eval $retval='("${selected[@]}")'
    eval "$retval"='("${indices[@]}")'
}

#Verificando a existencia de gerenciador YAY no sistema
#Caso o YAY não estaj instalado se pedido para instalar 
verificador_yay() {
    if [[ -z "$PKG_YAY" ]]; then
        echo "Gerenciador de pacotes AUR não encontrado!"
        echo "Sem um gerenciador não sera possivel instalar os aplivativos desse script."

        # Uso: options=("um" "dois" "três"); inputChoice "Escolha:" 1 "${options[@]}"; choice=$?; echo "${options[$choice]}"
        options=("Sim" "Não")
        inputChoice "Deseja instalar o gerenciador yay para pacotes AUR? :" 0 "${options[@]}"; choice=$?

        #Verifica a opção selecionado e itera sobre ela.
        if [ "${options[$choice]}" = "Sim" ] ; then
            sudo pacman -Syu
            sudo pacman -S git base-devel
            git clone https://aur.archlinux.org/yay.git
            cd yay || return
            makepkg -si
            cd .. || return
            rm -rf yay-git
        else
            echo "YAY não sera instalado..."
        fi
    fi
}

##-----------------------------------------------------------------------------------------------------------------------------

# Verificando se o gerenciador de pacotes é o pacman
if [[ -z "$PKG_PACMAN" ]]; then
    echo "Gerenciador de pacotes PACMAN não encontrado"
    echo "Encerranco script..."
    exit 1
fi

#--------------------------------------------------------- Começa o script ----------------------------------------------------

# Usage: bannerColor "my title" "red" "*"
bannerColor "HOKKET Istall" "blue" "#"


options=("Manual" "Automatico" "Sair")
inputChoice "Escolha o modo de instalação!" 0 "${options[@]}"; choice=$?

# Verifica o modo de intalação escolhido opção escoliha 
if [ "${options[$choice]}" = "Manual" ]; then
    
    # Extrai chaves e gera strings para o menu dinamicamente
    # shellcheck disable=SC2207
    NOMES_ORDENADOS=($(echo "${!MAPA_PACOTES[@]}" | tr ' ' '\n' | sort | tr '\n' ' '))
    OPCOES_STR=$(IFS=';'; echo "${NOMES_ORDENADOS[*]}")
    DEFAULTS_STR=$(printf "0;%.0s" $(seq 1 ${#NOMES_ORDENADOS[@]}) | sed 's/;$//')



    #chama a função de verificação e instalaçã do yay helper
    verificador_yay

    # Inicia o menu de escolhas de pacotes
    # Se a opção for manual 
    multiChoice "Selecione os pacotes:" result "$OPCOES_STR" "$DEFAULTS_STR"
    # Supondo que "result" seja o array com os índices selecionados
    pacotes_para_instalar=()
    # shellcheck disable=SC2154
    for idx in "${result[@]}"; do
        nome_amigavel="${NOMES_ORDENADOS[$idx]}"
        # shellcheck disable=SC2206
        pacotes_para_instalar+=(${MAPA_PACOTES[$nome_amigavel]})
    done

    [[ ${#pacotes_para_instalar[@]} -gt 0 ]] && yay -S "${pacotes_para_instalar[@]}" --noconfirm --cleanafter


    # Seção GNOME
    if [[ $USR_SHELL ]]; then
        inputChoice "Instalar extensões do GNOME?" 1 "Sim" "Não"; choice=$?
        if [ $choice -eq 0 ]; then
            # shellcheck disable=SC2207
            EXT_NOMES=($(echo "${!MAPA_EXTENSOES[@]}" | tr ' ' '\n' | sort | tr '\n' ' '))
            multiChoice "Extensões:" ext_result "$(IFS=';'; echo "${EXT_NOMES[*]}")" "0;0;0;0;0;0;0;0;0"
            
            ext_para_instalar=()
            # shellcheck disable=SC2154
            for idx in "${ext_result[@]}"; do
                ext_para_instalar+=("${MAPA_EXTENSOES[${EXT_NOMES[$idx]}]}")
            done
            [[ ${#ext_para_instalar[@]} -gt 0 ]] && yay -S gnome-shell-extension-tool "${ext_para_instalar[@]}" --noconfirm
        fi
    fi

<<<<<<< HEAD
    # Seção do Hyperland + Caelestia Shell
    if [[ $USR_HYPERLAND ]]; then
        # Usage: options=("one" "two" "three"); inputChoice "Choose:" 1 "${options[@]}"; choice=$?; echo "${options[$choice]}"
        options=("Sim" "Não")
        inputChoice "Instalar Caelestia Shell:" 1 "${options[@]}"; choice=$?
        if [ $choice -eq 0 ]; then
            yay -S caelestia-shell-git 
        fi
    fi

=======
>>>>>>> 0b97c3c (Remoção do suporte a ubuntu.)
#Se a opção automatica for selecionada entra aqui
elif [ "${options[$mode]}" = "Automático" ]; then
    verificador_yay
    # Instala todos os valores do mapa de pacotes
    yay -S "${MAPA_PACOTES[@]}" --noconfirm --cleanafter

    if [[ $USR_SHELL ]]; then
        yay -S "${MAPA_EXTENSOES[@]}" --noconfirm --cleanafter
<<<<<<< HEAD
    
    elif [[ $USR_HYPERLAND ]]; then
        yay -S caelestia-shell-git 
=======
>>>>>>> 0b97c3c (Remoção do suporte a ubuntu.)
    fi

#Se sair for selecionado entra aqui
else
    echo "Encerranco script..."
    exit 1
fi

#Fim do script
echo "Processo concluído!"
