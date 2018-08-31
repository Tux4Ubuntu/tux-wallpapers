# Set global values
STEPCOUNTER=false # Changes to true if user choose to install Tux Everywhere
YELLOW='\033[1;33m'
LIGHT_GREEN='\033[1;32m'
LIGHT_RED='\033[1;31m'
NC='\033[0m' # No Color

function install {
    # Add Pictures to locale folder
    prefix="\$HOME/"                
    pictures_var=$(cat $HOME/.config/user-dirs.dirs | grep "XDG_PICTURES_DIR")
    pictures_folder_uncut=$(echo ${pictures_var/XDG_PICTURES_DIR=/""} | tr -d '"')
    pictures_folder=${pictures_folder_uncut#$prefix}
    mkdir -p ~/$pictures_folder/"tux-wallpapers"
    printf "\n${YELLOW}Moving the images to your Pictures folder...${NC}\n"
    
    if [ ${PWD##*/} == "tux-install-master" ]; then
        sudo rsync -a ../tux-wallpapers ~/$pictures_folder
    else
        sudo rsync -a tux-wallpapers ~/$pictures_folder
    fi
    
    sudo chown -R $USER: $HOME
    printf "\033c"
    header "TUX WALLPAPERS" "$1"
    echo "Finished downloading and adding wallpapers. You can find them in your Pictures folder."
    echo ""
    printf "${LIGHT_GREEN}Do you want TUX to select an image for you?${NC}\n"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) echo "TUX is stamping and clapping! Been planning this for 20 minutes now..."
                gsettings set org.gnome.desktop.background picture-uri "file:///$HOME/$pictures_folder/tux-wallpapers/winter/tux4ubuntu_winter_wooff3yav6u-nick-karvounis.jpg"
                gsettings set org.gnome.desktop.screensaver picture-uri "file:///$HOME/$pictures_folder/tux-wallpapers/winter/tux4ubuntu_winter_wooff3yav6u-nick-karvounis.jpg"
                sleep 5
                printf "${LIGHT_GREEN}Done.${NC}\n"
                break;;
            No ) echo "TUX stamping and clapping slowly turns to silence..."
                sleep 3
                break;;
        esac
    done
    echo ""
    read -n1 -r -p "Press any key to continue..." key
    exit
}

function uninstall { 
    printf "\033c"
    header "TUX WALLPAPERS" "$1"
    gh_repo="tux4ubuntu-wallpapers"
    echo "This will remove all Tux 4K wallpapers."
    printf "${LIGHT_RED}Ready to do this?${NC}\n"
    echo ""
    echo "(Type 1 or 2, then press ENTER)"
    select yn in "Yes" "No"; do
        case $yn in
            Yes )
                printf "\033c"
                header "TUX WALLPAPERS" "$1"
                printf "${YELLOW}Deleting TUX's favorite wallpapers...${NC}\n"
                sleep 3
                # Added locale dependent Pictures folder
                prefix="\$HOME/"                
                pictures_var=$(cat $HOME/.config/user-dirs.dirs | grep "XDG_PICTURES_DIR")
                pictures_folder_uncut=$(echo ${pictures_var/XDG_PICTURES_DIR=/""} | tr -d '"')
                pictures_folder=${pictures_folder_uncut#$prefix}
                sudo rm -rf ~/$pictures_folder/tux-wallpapers

                printf "\033c"
                header "TUX WALLPAPERS" "$1"
                echo "Successfully removed the Tux's wallpapers."
                break;;
            No ) printf "\033c"
                header "TUX WALLPAPERS" "$1"
                echo "TUX brightens up and gives you a long hug..."
                break;;
        esac
    done
    echo ""
    read -n1 -r -p "Press any key to continue..." key
    exit
}

function header {
    var_size=${#1}
    # 80 is a full width set by us (to work in the smallest standard terminal window)
    if [ $STEPCOUNTER = false ]; then
        # 80 - 2 - 1 = 77 to allow space for side lines and the first space after border.
        len=$(expr 77 - $var_size)
    else   
        # "Step X/X " is 9
        # 80 - 2 - 1 - 9 = 68 to allow space for side lines and the first space after border.
        len=$(expr 68 - $var_size)
    fi
    ch=' '
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    printf "║"
    printf " ${YELLOW}$1${NC}"
    printf '%*s' "$len" | tr ' ' "$ch"
    if [ $STEPCOUNTER = true ]; then
        printf "Step "${LIGHT_GREEN}$2${NC}
        printf "/5 "
    fi
    printf "║\n"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo ""
}

function check_sudo {
    if sudo -n true 2>/dev/null; then 
        :
    else
        printf "Oh, TUX will ask below about sudo rights to copy and install everything...\n\n"
    fi
}

function install_if_not_found { 
    # As found here: http://askubuntu.com/questions/319307/reliably-check-if-a-package-is-installed-or-not
    for pkg in $1; do
        if dpkg --get-selections | grep -q "^$pkg[[:space:]]*install$" >/dev/null; then
            echo -e "$pkg is already installed"
        else
            printf "${YELLOW}Installing $pkg.${NC}\n"
            if sudo apt-get -qq --allow-unauthenticated install $pkg; then
                printf "${YELLOW}Successfully installed $pkg${NC}\n"
            else
                printf "${LIGHT_RED}Error installing $pkg${NC}\n"
            fi        
        fi
    done
}

function uninstall_if_found { 
    # As found here: http://askubuntu.com/questions/319307/reliably-check-if-a-package-is-installed-or-not
    for pkg in $1; do
        if dpkg --get-selections | grep -q "^$pkg[[:space:]]*install$" >/dev/null; then
            echo "Uninstalling $pkg."
            if sudo apt-get remove $pkg; then
                printf "${YELLOW}Successfully uninstalled $pkg${NC}\n"
            else
                printf "${LIGHT_RED}Error uninstalling $pkg${NC}\n"
            fi        
        else
            printf "${LIGHT_RED}$pkg is not installed${NC}\n"
        fi
    done
}

function goto_tux4ubuntu_org {
    echo ""
    printf "${YELLOW}Launching website in your favourite browser...${NC}\n"
    x-www-browser https://tux4ubuntu.org/portfolio/wallpapers &
    echo ""
    sleep 2
    read -n1 -r -p "Press any key to continue..." key
    exit
}

while :
do
    clear
    if [ -z "$1" ]; then
        :
    else
        STEPCOUNTER=true
    fi
    header "TUX WALLPAPERS" "$1"
    # Menu system as found here: http://stackoverflow.com/questions/20224862/bash-script-always-show-menu-after-loop-execution
    cat<<EOF                                                                              
Type one of the following numbers/letters:          

1) Install                                - Install Desktop themes          
2) Uninstall                              - Uninstall Desktop themes       
--------------------------------------------------------------------------------   
3) Read Instructions                      - Open up tux4ubuntu.org
--------------------------------------------------------------------------------
Q) Skip                                   - Quit Desktop theme installer

(Press Control + C to quit the installer all together)
EOF
    read -n1 -s
    case "$REPLY" in
    "1")    install $1;;
    "2")    uninstall $1;;
    "3")    goto_tux4ubuntu_org;;
    "S")    exit                      ;;
    "s")    exit                      ;;
    "Q")    exit                      ;;
    "q")    exit                      ;;
     * )    echo "invalid option"     ;;
    esac
    sleep 1
done