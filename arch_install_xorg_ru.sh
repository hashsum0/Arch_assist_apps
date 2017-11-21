#!/bin/bash
#DEVELOPER:hashsum0
#MAIL:phantom000hobo@protonmail.com
#DATA:12-11-2017
#VERSION:1.0
#*******************GNU*****************************
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
loadkeys ru
setfont cyr-sun16
step=0
#********************************************************************************************create_user
function create_user {
        echo -e "\x1B[36m""Создать пользователя\v""\x1B[0m"
        echo "Продолжить?  y/N"
                read var
                    if [ "$var" == "y" ];then
                         echo "Введите имя пользователя"
                         read namevar
                         useradd -m -g users -G wheel -s /bin/bash $namevar
                         echo "Введите пароль пользователя"
                         passwd $namevar
                    else echo "Пропустили."
                    fi
            }
#********************************************************************************************sudo_for_user
function sudo_for_user {
        echo -e "\x1B[36m""Дать пользователю привилегии root\v""\x1B[0m"
        echo -e "\x1B[36m""Нужно отредактировать файл /etc/sudores""\x1B[0m"
        echo -e "\x1B[36m""Либо раскоментировать строчку #%wheel ALL=(ALL) ALL""\x1B[0m"
        echo -e "\x1B[36m""Либо под строчкой root ALL=(ALL) ALL""\x1B[0m"
        echo -e "\x1B[36m""вписать: user_name ALL=(ALL) ALL""\x1B[0m"
        echo "Продолжить?  y/N"
                read var
                    if [ "$var" == "y" ]
                    then
                         nano /etc/sudores
                    else echo "Пропустили."
                    fi
            }
#********************************************************************************************xorg_component_install
function xorg_component_install {
        echo -e "\x1B[36m""Установка Xorg и его компонентов\v""\x1B[0m"
        echo -e "\x1B[36m""Будут установлены:xorg-server xorg-xinit mesa xorg-drivers""\x1B[0m"
        echo "Продолжить?  y/N"
                read var
                    if [ "$var" == "y" ]
                    then
                         pacman -S xorg-server xorg-xinit mesa xorg-drivers
			 read -s -n1 "Нажмите любую клавишу."
                    else echo "Пропустили."
                    fi
		    
            }
#********************************************************************************************alsa_component_install
function alsa_component_install {
        echo -e "\x1B[36m""Установка компанентов alsa\v""\x1B[0m"
        echo "Продолжить?  y/N"
                read var
                    if [ "$var" == "y" ]
                    then
                         pacman -S alsa-lib alsa-utils alsa-oss alsa-plugins
			 read -s -n1 "Нажмите любую клавишу."
                    else echo "Пропустили."
                    fi
            }
#********************************************************************************************font_install
function font_install {
        echo -e "\x1B[36m""Установка шрифтов\v""\x1B[0m"
        echo "Продолжить?  y/N"
                read var
                    if [ "$var" == "y" ]
                    then
                          pacman -S adobe-source-code-pro-fonts cantarell-fonts ttf-dejavu terminus-font ttf-droid ttf-font-awesome ttf-liberation ttf-ubuntu-font-family ttf-hack
			 read -s -n1 "Нажмите любую клавишу."
                    else echo "Пропустили."
                    fi
            }
#********************************************************************************************Window_Manager
function Window_Manager {
        echo -e "\x1B[36m""Установка менеджера окон\v""\x1B[0m"
        echo -e "\x1B[36m""1) Openbox""\x1B[0m"
        echo -e "\x1B[36m""2) i3wm""\x1B[0m"
        echo -e "\x1B[36m""3) Другое""\x1B[0m"
                read -s -n1 var
                    if [ "$var" == "1" ];then
                        pacman -S openbox obmenu obconf tint2 
			 read -s -n1 "Нажмите любую клавишу."
                    elif [ "$var" == "2" ];then
                        pacman -S i3-wm i3status
			 read -s -n1 "Нажмите любую клавишу."
                    elif [ "$var" == "3" ];then
                        echo -e "\x1B[36m""Введите имя менеджера окон или окружение рабочего стола""\x1B[0m"
                        echo -e "\x1B[36m""а также имена необходимых ему пакетов ""\x1B[0m"
                        read var
                        pacman -S $var
			 read -s -n1 "Нажмите любую клавишу."
                    else echo "Пропустили."
                    fi
                echo -e "\x1B[36m""Установка пакетов первой необходимости""\x1B[0m"
                echo -e "\x1B[36m""Будут установлены:lxappearance scrot nitrogen rofi""\x1B[0m"
                echo -e "\x1B[36m""pcmanfm file-roller p7zip unrar deluge speedcrunch gvfs gvfs-mtp""\x1B[0m"
                echo -e "\x1B[36m""ntfs-3g dosfstools udevil xterm moc geany ""\x1B[0m"
                echo "Продолжить?  y/N"
                read var
                    if [ "$var" == "y" ];then
                        pacman -S lxappearance scrot nitrogen rofi pcmanfm file-roller p7zip unrar deluge speedcrunch gvfs gvfs-mtp ntfs-3g dosfstools udevil xterm moc geany            
			 read -s -n1 "Нажмите любую клавишу."
                    else echo "Пропустили."
                    fi
                
            }
#********************************************************************************************Display_Manager
function Display_Manager {
        echo -e "\x1B[36m""Установка Менеджера входа(Display Manager)\v""\x1B[0m"
        echo -e "\x1B[36m""
        1) Установить Slim
        2) Установить Lxdm
        3) Установить Lightdm
        4) Настроить автовход без использования DM
        5) Пропустить.""\x1B[0m"
        read -s -n1 var
if [ "$var" == "1" ];then
    echo "Устанавливаем Slim"
    pacman -S slim
    read -s -n1 "Нажмите любую клавишу."
    systemctl enable slim.service
elif [ "$var" == "2" ];then
    echo "Устанавливаем lxdm"
    pacman -S lxdm
    read -s -n1 "Нажмите любую клавишу."
    systemctl enable slim.service
elif [ "$var" == "3" ];then
    echo "Устанавливаем lightdm"
    pacman -S lightdm
    read -s -n1 "Нажмите любую клавишу."
    systemctl enable slim.service
elif [ "$var" == "4" ];then
echo "# start some nice programs
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x \"\$f\" ] && . \"\$f\"
 done
unset f
fi

# Dbus fix
if [ -z \"\$DBUS_SESSION_BUS_ADDRESS\" ]; then
eval \"\$(dbus-launch --sh-syntax --exit-with-session)\"
fi

# Window Manager of your choice
#exec gnome-session
#exec startkde
#exec startxfce4
#exec awesome
#exec i3
#exec openbox-session" > /home/$namevar/.xinitrc
read -s -n1 "Нажмите любую клавишу."

echo "#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

[[ -z \$DISPLAY && \$XDG_VTNR -eq 1 ]] && exec startx" > /home/$namevar/.bash_profile
mkdir /etc/systemd/system/getty@tty1.service.d/
read -s -n1 "Нажмите любую клавишу."

echo "[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $namevar --noclear %I \$TERM" > /etc/systemd/system/getty@tty1.service.d/override.conf
echo -e "\x1B[36m""Раскоментируйте строку запуска установленного WM""\x1B[0m"
read -s -n1 -p $'\x1B[32m Нажмите любую клавишу чтобы продолжить\n\x1B[0m'
nano /home/$namevar/.xinitrc
elif [[ -z "$var" || "$var" == "5" ]];then   
    echo "Пропустили."
fi
            }
#********************************************************************************************menu_installer      
function dialog_my {
        echo -e "\x1B[36m""\t\t\t\tШаг ($step): ${stepn[$(($step))]} выполнен(а) или пропущен(а) пользователем \v ""\x1B[0m"
        echo -e "\x1B[33m""\t\t\t\t___________________Выберите_нужный_пункт_____________________""\x1B[0m"
        echo -e "\x1B[36m""\t\t\t\t1) Перейти к следующему шагу:""\x1B[0m"${stepn[$(($step+1))]}
        echo -e "\x1B[36m""\t\t\t\t2) Пропустить следующий ${stepn[$(($step+1))]} и перейти к:""\x1B[0m"${stepn[$(($step+2))]}
        echo -e "\x1B[36m""\t\t\t\t3) Повторить предыдущий шаг:""\x1B[0m"${stepn[$step]} 
        echo -e "\x1B[36m""\t\t\t\t4) Вернуться на старт""\x1B[0m"
        echo -e "\x1B[36m""\t\t\t\t5) Список шагов""\x1B[0m"
        echo -e "\x1B[31m""\t\t\t\tq) Выйти""\x1B[0m"
        read -s -n1 var
        echo -e "\x1B[33m""\t\t\t\t_______________________________V______________________________""\x1B[0m"

            if [ "$var" == "1" ];then
                step=$(($step+1))
            elif [ "$var" == "2" ];then
                echo -e "\x1B[36m""Пропустили "${stepn[$(($step+1))]}", переход к следующему!\v""\x1B[0m"
                step=$(($step+2))
            elif [ "$var" == "3" ];then
                echo -e "\x1B[36m""Повтор!""\x1B[0m"  
            elif [ "$var" == "4" ];then
                step=0
                echo -e "\x1B[36m""Возврощаемся на start!""\x1B[0m"
            elif [ "$var" == "5" ];then
                echo -e "\x1B[36m""select and enter number item""\x1B[0m"
                echo -e "\x1B[36m""1) Создать пользователя""\x1B[0m"
                echo -e "\x1B[36m""2) Дать пользователю root привилегии""\x1B[0m"
                echo -e "\x1B[36m""3) Установка Xorg и его компонентов""\x1B[0m"
                echo -e "\x1B[36m""4) Установка alsa и его компонентов""\x1B[0m"
                echo -e "\x1B[36m""5) Установка шрифтов""\x1B[0m"
                echo -e "\x1B[36m""6) Менеджер окон(WM)""\x1B[0m"
                echo -e "\x1B[36m""7) Менеджер входа(DM)""\x1B[0m"
                
                echo -e "\x1B[33m""______________________________________V_________________________________________________\v\v""\x1B[0m"
                read -s -n1 step
                if [ "$step" == "" ]
                then echo "skip"
                fi
            elif [ "$var" == "q" ];then
                echo "Выходим..."
                read -t 2
                clear
                exit
            elif [ -z "$var" ];then
                echo -e "\x1B[36m""Продолжаем!\v""\x1B[0m"
                step=$(($step+1))
            else echo "Внимание, ошибка"
            fi
            }
#********************************************************************************************exit
function exit_inst {
            echo -e "\x1B[36m""Xorg и другие компаненты установлены!""\x1B[0m"
            echo -e "\x1B[36m""Теперь вы можете перезагрузить компьютер.""\x1B[0m"
            read -s -n1 -p $'\x1B[32m Нажмите любую клавишу чтобы выйти\n\x1B[0m'
            echo "Выходим..."
                    read -t 2
                    clear
                    exit
            }
#********************************************************************************************logotip
function logotip {
echo -e "\x1B[34m \n" \
"                   -\`                     \n" \
"                  .o+\`                    \n" \
"                \`ooo/                     \n" \
"                \`+oooo:                   \n" \
"               \`+oooooo:                  \n" \
"               -+oooooo+:                  \n" \
"             \`/:-:++oooo+:                \n" \
"            \`/++++/+++++++:               \n" \
"          \`/++++++++++++++:               \n" \
"         \`/+++ooooooooooooo/\`            \n" \
"        ./ooosssso++osssssso+\`            \n" \
"        .oossssso-\`\`\`\`/ossssss+\`      \n" \
"      -osssssso.      :ssssssso.           \n" \
"     :osssssss/        osssso+++.          \n" \
"     /ossssssss/        +ssssooo/-         \n" \
"   \`/ossssso+/:-        -:/+osssso+-      \n" \
"  \`+sso+:-\`                 \`.-/+oso:   \n" \
" \`++:.                           \`-/+/   \n" \
" .\`                                 \`/""\033[0m"
echo -e "\x1B[36m""Wellcome to the ArchLinux Xorg install""\x1B[0m"
}
#********************************************************************************************main
stepn=(
   'start'
   'Создать пользователя'
   'Дать пользователю привилегии root'
   'Установка Xorg и его компонентов'
   'Установка alsa и его компонентов'
   'Установка шрифтов'
   'Менеджер окон(WM)'
   'Менеджер входа(DM)'
   'Выходим'
      )
clear
        


    while :
    do
        
        case $step in
              0  ) logotip                ;;
              1  ) create_user            ;;
              2  ) sudo_for_user          ;;
              3  ) xorg_component_install ;;
              4  ) alsa_component_install ;;
              5  ) font_install           ;;
              6  ) Window_Manager         ;;
              7  ) Display_Manager        ;;
              8  ) exit_inst              ;;
        esac

    read -s -n1 -p $'\x1B[32mНажмите любую клавишу для продолжения\x1B[0m'
    clear
    echo -e "\v\v\v\v\v\v"
        
    dialog_my
    done


