#!/bin/bash



## Funçoes de menus ------------------------------------------------------------------------------------------------------------
# Uso: options=("um" "dois" "três"); inputChoice "Escolha:" 1 "${options[@]}"; choice=$?; echo "${options[$choice]}"
function inputChoice() {
    echo "${1}"; shift
    echo "$(tput dim)""- Mude de opção : [up/down], Selecione com: [ENTER]" "$(tput sgr0)"
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

# Usage: multiChoice "header message" resultArray "comma separated options" "comma separated default values"
# Credit: https://serverfault.com/a/949806
function multiChoice {
    echo "${1}"; shift
    echo "$(tput dim)""- Change Option: [up/down], Change Selection: [space], Done: [ENTER]" "$(tput sgr0)"
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
##-----------------------------------------------------------------------------------------------------------------------------

##Variaveis---------------------------------
## Capturando informaçoes sobre os gerenciados de pacotes 
## PACMAN
PKG_PACMAN=$(command -v pacman)
## YAY
PKG_YAY=$(command -v yay)
##Capturando informação do GNOME-SHELL
USR_SHELL=$(command -v gnome-shell)
##-------------------------------------------



# Verificando se o gerenciador de pacotes é o pacman
if [[ -z "$PKG_PACMAN" ]]; then
    echo "Gerenciador de pacotes PACMAN não encontrado"
    echo "Encerranco script..."
    exit 1
fi

#Verificando a existencia de gerenciador YAY nop istema 
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

multiChoice "Selecione as opções:" result " Vesktop; Steam; Wine; Charles; Lustris; Gamemode; OBS Studio; VLC; GIMP; freedownloadmanager; \ 
    LibreOffice; Firefox; Chromium; Teamspeak; Git; Node.js; Python; Java; \
    Docker; VirtualBox; Heroic-Games; Krita; VsCode; Zapzap; Brave; ProtonPlus" \
    "0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0"
# Supondo que "result" seja o array com os índices selecionados
selected_words=()
for index in "${result[@]}"; do
    case $index in
        0) selected_words+=("vesktop");;
        1) selected_words+=("steam");;
        2) selected_words+=("wine");;
        3) selected_words+=("charles-bundled-java");;
        4) selected_words+=("lutris-wine-meta");;
        5) selected_words+=("gamemode");;
        6) selected_words+=("obs-studio");;
        7) selected_words+=("vlc");;
        8) selected_words+=("gimp");;
        9) selected_words+=("freedownloadmanager");;
        10) selected_words+=("libreoffice-fresh");;
        11) selected_words+=("firefox");;
        12) selected_words+=("chromium");;
        13) selected_words+=("teamspeak3");;
        14) selected_words+=("git");;
        15) selected_words+=("nodejs");;
        16) selected_words+=("python");;
        17) selected_words+=("jdk-openjdk");;
        18) selected_words+=("docker");;
        19) selected_words+=("virtualbox");;
        20) selected_words+=("heroic-games-launcher-bin");;
        21) selected_words+=("krita krita-plugin-gmic");;
        22) selected_words+=("visual-studio-code-bin");;
        23) selected_words+=("zapzap");;
        24) selected_words+=("brave");;
        25) selected_words+=("protonplus");;
        # Adicione mais casos conforme necessário para cada opção
    esac
done
yay -S "${selected_words[@]}" --asdeps --noconfirm --cleanafter



if [[ $USR_SHELL ]]; then
    # Usage: options=("one" "two" "three"); inputChoice "Choose:" 1 "${options[@]}"; choice=$?; echo "${options[$choice]}"
    options=("Sim" "Não")
    inputChoice "Instalar extensões do gnome?:" 0 "${options[@]}"; choice=$?
    if [ "${options[$choice]}" = "Sim" ]; then
        multiChoice "Selecione as opções:" result " Dash-to-dock; Gnome-4x; Pop-Shell; Appindicator; Arc-Menu; Caffeine; Dash-toPanel; \
            Desktop-icons; User-themes" \
            "0; 0; 0; 0; 0; 0; 0; 0; 0"   
        # Supondo que "result" seja o array com os índices selecionados
        selected_words=()
            for index in "${result[@]}"; do
                case $index in
                0) selected_words+=("gnome-shell-extension-dash-to-dock");;
                1) selected_words+=("gnome-shell-extension-gnome-ui-tune-git");;
                2) selected_words+=("gnome-shell-extension-pop-shell-git");;
                3) selected_words+=("gnome-shell-extension-appindicator ");;
                4) selected_words+=("gnome-shell-extension-arc-menu");;
                5) selected_words+=("gnome-shell-extension-caffeine");;
                6) selected_words+=("gnome-shell-extension-dash-to-panel");;
                7) selected_words+=("gnome-shell-extension-desktop-icons-ng");;
                8) selected_words+=("gnome-shell-extension-user-theme-x-git");;
                
                # Adicione mais casos conforme necessário para cada opção
                esac
            done
        yay -S gnome-shell-extension-tool "${selected_words[@]}" --asdeps --noconfirm --cleanafter
    fi
fi