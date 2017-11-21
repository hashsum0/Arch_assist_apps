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
#***************************************************

loadkeys ru
setfont cyr-sun16
clear
#pacman -Sy vim p7zip ranger reflector
#/usr/bin/reflector --protocol http --latest 30 --number 20 --sort rate --save /etc/pacman.d/mirrorlist
#start
d_target=""
d_boot=""
d_root=""
d_swap=""
d_home=""
step=0
#********************************************************************************************1-inet_test
function inet_test {        
        echo -e "\x1B[36m""Интернет, проверка соединения\v""\x1B[0m"
        echo -e "\x1B[36m""Здесь будет проверено соединение с интернетом""\x1B[0m"
        echo -e "\x1B[36m""с помощью команды ping -c3 8.8.8.8""\x1B[0m"
            echo "Продолжить?  y/N"
                read var
                    if [ "$var" == "y" ]
                    then
                        var=$(ping -c3 8.8.8.8 | awk '/transmitted/{print $1+$4}')
                        if [ $var  == "6" ]
                        then echo -e "\x1B[36m""Есть соединение с интернетом""\x1B[0m"
                        else echo -e "\x1B[36m""Соединение с интернетом нет!""\x1B[0m"
                             echo -e "\x1B[36m""Пожалуйста, настройте соединение с интернетом""\x1B[0m"
                             echo "Выберите какое у вас подключение"
                             echo "1)Wi-fi интернет будет настроен с помощью диалога программы wifi-menu"
                             echo "2)Проводное подключение, интернет будет настроен с помощью команды dhcpcd"
                             read var
                                 if [ "$var" == "1" ]
                                 then wifi-menu
                                 elif [ "$var" == "2" ]
                                 then dhcpcd
                                 fi
                                 var=$(ping -c3 8.8.8.8 | awk '/transmitted/{print $1+$4}')
                                    if [ $var  == "2" ]
                                    then echo -e "\x1B[36m""Есть соединение с интернетом""\x1B[0m"
                                    else
                                        echo -e "\x1B[36m""Соединение с интернетом отсутствует!""\x1B[0m"
                                        read -s -n1 -p $'\x1B[36m Нажмите любую клавишу для выхода\x1B[0m'
                                        exit
                                    fi
                        fi
                    else echo "Пропустили."
                    fi    
        }
        
#*********************************************************************************************2-parted_disk       
function parted_disk {
        echo -e "\x1B[36m""Разбить диск на разделы\v""\x1B[0m"
        echo -e "\x1B[36m""Здесь вам нужно будет разбить диск на разделы""\x1B[0m"
        echo -e "\x1B[36m""с помощью программы \x1B[32m cfdisk \x1B[36m, перед этим с помощью""\x1B[0m"
        echo -e "\x1B[36m""команды \x1B[32m lsblk -f \x1B[36m будут показаны все диски, чтобы ""\x1B[0m"
        echo -e "\x1B[36m""вы могли выбрать тот на каторый будет ставиться ОС ""\x1B[0m"
        echo -e "\x1B[36m""Вам нужно разделить выбранный диск на 4 раздела ""\x1B[0m"
        echo -e "\x1B[36m""sd*1 для boot(150M) sd*2""\x1B[0m"
        echo -e "\x1B[36m""sd*2 для корневого раздела / (не менее 8G, желательно 25G +) ""\x1B[0m"
        echo -e "\x1B[36m""sd*3 для swap(размер ОЗУ+) ""\x1B[0m"
        echo -e "\x1B[36m""sd*4 для раздела /home (обычно все остальное) ""\x1B[0m"
            echo "Продолжить?  y/N"
                read var
                    if [ "$var" == "y" ]
                    then
                        lsblk -f
                        echo -e "\x1B[35m""Введите имя устройства (например sda)""\x1B[0m"
                        read var
                        sudo cfdisk "/dev/"$var
                    else echo "Пропустили."
                    fi
            }
#********************************************************************************************3-assign_sections
function assign_sections {
        echo -e "\x1B[36m""Выбор точки монтирования для каждого раздела\v""\x1B[0m"
        echo -e "\x1B[36m""Этот шаг нужен для работы скрипта чтобы он знал""\x1B[0m"
        echo -e "\x1B[36m""какой раздел куда монтировать, по этому просто делаем что он просит;-)""\x1B[0m"
            echo "Продолжить? y/N"
                read var
                    if [ "$var" == "y" ]
                    then
                        echo "Введите имя целевого устройства (например sda)"
                        read var
                        d_target="/dev/"$var
                        echo "Введите номер раздела который вы выделили для boot (например 1)"
                        read var
                        d_boot=$d_target$var   
                        echo "Введите номер раздела который вы выделили для root (например 2)"
                        read var
                        d_root=$d_target$var
                        echo "Введите номер раздела который вы выделили для swap (например 3)"
                        read var
                        d_swap=$d_target$var
                        echo "Введите номер раздела который вы выделили для home (например 4)"
                        read var
                        d_home=$d_target$var
                        echo "target:"$d_target
                        echo "for boot:"$d_boot
                        echo "for root:"$d_root
                        echo "for swap:"$d_swap
                        echo "for home:"$d_home
                    else echo "Пропустили."
                    fi
            }
#********************************************************************************************4-formating_disk
function formating_disk {
        echo -e "\x1B[36m""Форматирование разделов\v""\x1B[0m"
        echo -e "\x1B[36m""Здесь будет произведино форматирование разделов""\x1B[0m"
        echo -e "\x1B[36m""с помощью следующих команд:""\x1B[0m"
        echo -e "\x1B[36m""mkfs.ext2 /dev/sdXX для boot""\x1B[0m"
        echo -e "\x1B[36m""mkfs.ext4 /dev/sdXX для /""\x1B[0m"
        echo -e "\x1B[36m""mkfs.ext4 /dev/sdXX для home""\x1B[0m"         
            echo "Продолжить?  y/N"
                read var
                    if [ "$var" == "y" ]
                    then
                        if [[ -z "$d_target" && -z "$d_boot" && -z "$d_root" && -z "$d_home" ]]
                        then
                            assign_sections
                        fi
                        while :
                        do
                        mkfs.ext2 $d_boot
                        if [[ $(lsblk -f $d_boot | awk '/sd/{print $2}') == "ext2" ]];then
                            echo "$d_boot format ext2 Ok"
                        else
                            echo -e "\x1B[31m""ERROR попробуйте повторить этот шаг""\x1B[0m"
                            read -s -n1 -p $'\x1B[32m Нажмите любую клавишу\x1B[0m'
                            break
                        fi
                        mkfs.ext4 $d_root
                        if [[ $(lsblk -f $d_root | awk '/sd/{print $2}') == "ext4" ]];then
                            echo "$d_root format ext4 Ok"
                        else
                            echo -e "\x1B[31m""ERROR попробуйте повторить этот шаг""\x1B[0m"
                            read -s -n1 -p $'\x1B[32m Нажмите любую клавишу\x1B[0m'
                            break
                        fi
                        mkfs.ext4 $d_home
                        if [[ $(lsblk -f $d_home | awk '/sd/{print $2}') == "ext4" ]];then
                            echo "$d_home format ext4 Ok"
                            read -s -n1 -p $'\x1B[32m Нажмите любую клавишу\x1B[0m'
                            break
                        else
                            echo -e "\x1B[31m""ERROR попробуйте повторить этот шаг""\x1B[0m"
                            read -s -n1 -p $'\x1B[32m Нажмите любую клавишу\x1B[0m'
                            break
                        fi
                        done
                    else echo "Пропустили."
                    fi
                lsblk -f
            }
#********************************************************************************************5-mounting_disk
function mounting_disk {        
        echo -e "\x1B[36m""Монтирование разделов\v""\x1B[0m"
        echo -e "\x1B[36m""На этом этапе будет создан и подключен раздел swap""\x1B[0m"
        echo -e "\x1B[36m""примонтирован корневой раздел в директорию /mnt/""\x1B[0m"
        echo -e "\x1B[36m""в этой директории будут созданы директории boot и home""\x1B[0m"
        echo -e "\x1B[36m""в которые будут примонтированы соответствующие разделы""\x1B[0m"
        echo -e "\x1B[36m""mkswap /dev/sd*№ создаем раздел swap""\x1B[0m"
        echo -e "\x1B[36m""swapon /dev/sd*№ подключаем его""\x1B[0m"
        echo -e "\x1B[36m""mount /dev/sd*№ /mnt монтируем корневой раздел""\x1B[0m"
        echo -e "\x1B[36m""mkdir /mnt/{boot,home} создаем директории boot и home""\x1B[0m"
        echo -e "\x1B[36m""mount /dev/sd*№ /mnt/boot монтируем разделы""\x1B[0m"
        echo -e "\x1B[36m""mount /dev/sd*№ /mnt/home""\x1B[0m"
        echo -e "\x1B[36m""по окончании с помощью команды lsblk -f ""\x1B[0m"
        echo -e "\x1B[36m""пбудет выведен результат ""\x1B[0m"
            echo "Продолжить?  y/N"
                read var
                    if [ "$var" == "y" ]
                    then
                        if [[ -z "$d_target" && -z "$d_boot" && -z "$d_root" && -z "$d_home" ]]
                        then
                            assign_sections
                        fi
                        mkswap $d_swap
                        swapon $d_swap
                            var=$(lsblk -f $d_root | awk '/sd*/{print $4}')
                            if [ "$var" != "" ]
                            then
                                umount $d_root
                                mount $d_root /mnt
                            else
                                mount $d_root /mnt
                            fi
                        mkdir /mnt/{boot,home}
                        var=$(lsblk -f $d_root | awk '/sd*/{print $4}')
                            if [ "$var" != "" ]
                            then
                                umount $d_boot
                                mount $d_boot /mnt/boot
                            else
                                mount $d_boot /mnt/boot
                            fi
                        var=$(lsblk -f $d_home | awk '/sd*/{print $4}')
                            if [ "$var" != "" ]
                            then
                                umount $d_home
                                mount $d_home /mnt/home
                            else
                                mount $d_home /mnt/home
                            fi
                    else echo "Пропустили."
                    fi
                lsblk -f
            }
#********************************************************************************************6-edit_mirrorlist
function edit_mirrorlist {
        echo -e "\x1B[36m""Редактировать список зеркал\v""\x1B[0m"
            echo "1) Выполнить вручную"
            echo "2) Выполнить с помощью утилиты reflector"
                read var 
                if [ "$var" == "1" ];then
                    nano /etc/pacman.d/mirrorlist
                elif [ "$var" == "2" ];then
                    if [[ $(pacman -Qs reflector | awk '/\//{print $1}') == "local/reflector" ]];then
                    /usr/bin/reflector --protocol http --latest 30 --number 20 --sort rate --save /etc/pacman.d/mirrorlist
                    elif [[ -z $(pacman -Qs reflector | awk '/\//{print $1}') ]];then
                    pacman -S reflector
                    /usr/bin/reflector --protocol http --latest 30 --number 20 --sort rate --save /etc/pacman.d/mirrorlist
                    fi
                else echo "Пропустили."
                fi
            }
  
#********************************************************************************************7-pacman_update
function pacman_update {
        echo -e "\x1B[36m""Обновляем список пакетов в базе данных pacman\v""\x1B[0m"
        echo -e "\x1B[36m""команда:pacman -Syy""\x1B[0m"
            echo "Продолжить?  y/N"
                read var
                    if [ "$var" == "y" ]
                    then
                        pacman -Syy
                    else echo "Пропустили."
                    fi
            }
#********************************************************************************************8-istall_base
function istall_base {
        echo -e "\x1B[36m""Установка основных пакетов\v""\x1B[0m"
        echo -e "\x1B[36m""На данном этапе, будут установлены базовые пакеты ""\x1B[0m"
        echo -e "\x1B[36m""будующей системы и пакеты разработчика, для сборки из исходников ""\x1B[0m"
        echo -e "\x1B[36m""команда:pacstrap /mnt base base-devel ""\x1B[0m"
            echo "Продолжить?  y/N"
                read var
                    if [ "$var" == "y" ]
                    then
                        pacstrap /mnt base base-devel
                    else echo "Пропустили."
                    fi
            }
#********************************************************************************************9-generate_fstab
function generate_fstab {
        echo -e "\x1B[36m""Генерация fstab\v""\x1B[0m"
        echo -e "\x1B[36m""Здесь мы должны будем сгенерировать файл fstab""\x1B[0m"
        echo -e "\x1B[36m""в котором будет храниться спиок разделов, монтируемых ""\x1B[0m"
        echo -e "\x1B[36m""автоматически при загрузке системы и параметров их монтирования""\x1B[0m"
        echo -e "\x1B[36m""команда:genfstab -pU /mnt >> /mnt/etc/fstab""\x1B[0m"
            echo "Продолжить?  y/N"
                read var
                    if [ "$var" == "y" ]
                    then
                        genfstab -pU /mnt >> /mnt/etc/fstab
                    else echo "Пропустили."
                    fi
            }
#********************************************************************************************10-goto_arch_chroot
function goto_arch_chroot {
        echo -e "\x1B[36m""Переходим в arch-chroot\v""\x1B[0m"
        echo -e "\x1B[36m""На этом этапе произайдет подмена файловой системы установщика,""\x1B[0m"
        echo -e "\x1B[36m""на ту которую мы устанавливаем, где мы сможем произвести ""\x1B[0m"
        echo -e "\x1B[36m""предворительные настройки нашей будующей системы ""\x1B[0m"
            echo "Продолжить?  y/N"
                read var
                    if [ "$var" == "y" ]
                    then
                        cp $0 /mnt/root
                        cp arch_install_xorg_ru.sh /mnt/root
                        chmod 755 /mnt/root/arch_install_xorg_ru.sh
                        chmod 755 /mnt/root/$(basename "$0")
                        arch-chroot /mnt /root/$(basename "$0") --chroot $d_target
                        rm /mnt/root/$(basename "$0")
                    else echo "Пропустили."
                    fi
            }
#********************************************************************************************11-grub_pkg_install
function grub_pkg_install {
        echo -e "\x1B[36m""Установка пакета загрузчика\v""\x1B[0m"
        echo -e "\x1B[36m""Будет установлен пакет Grub""\x1B[0m"
        echo "Продолжить?  y/N"
                read var
                    if [ "$var" == "y" ]
                    then
                        pacman -S grub
                    else echo "Пропустили."
                    fi
            }
#********************************************************************************************12-pakages_install
function pakages_install {
            echo -e "\x1B[36m""Установка дополнительных пакетов\v""\x1B[0m"
            echo -e "\x1B[36m""Нужно перечислить список программ которые вам понадобятся""\x1B[0m"
            echo -e "\x1B[36m""на этапе установки""\x1B[0m"
                echo "Продолжить?  y/N"
                    read var
                        if [ "$var" == "y" ]
                        then
                            echo "Введите названия необходимых пакетов разделяя пробелом "
                            read var
                            pacman -S $var
                        else echo "Пропустили."
                        fi
            }
#********************************************************************************************13-host_name
function host_name {
            echo -e "\x1B[36m""Имя машины\v""\x1B[0m"
            echo -e "\x1B[36m""Здесь нужно дать имя вашей машине""\x1B[0m"
                echo "Продолжить?  y/N"
                    read var
                        if [ "$var" == "y" ]
                        then
                            echo "Введите имя машины:"
                            read var
                            echo $var > /etc/hostname
                        else echo "Пропустили."
                        fi
            }
#********************************************************************************************14-time_zone
function time_zone {
            echo -e "\x1B[36m""Выбор часового пояса\v""\x1B[0m"
                echo "Продолжить?  y/N"
                    read var
                        if [ "$var" == "y" ]
                        then
                            ls /usr/share/zoneinfo/Europe
                            echo "Выберите из списка часовой пояс"
                            read var
                            rm /etc/localtime
                            ln -s /usr/share/zoneinfo/Europe/$var /etc/localtime
                        else echo "Пропустили."
                        fi
            }
#********************************************************************************************15-edit_locale
function edit_locale {
        echo -e "\x1B[36m""Язык системы\v""\x1B[0m"
            echo -e "\x1B[36m""Разкоментируйте нужные локали в файле locale.gen""\x1B[0m"    
            echo "Продолжить? y/N "
            read var 
                if [ "$var" == "y" ]
                then
                     nano /etc/locale.gen
                else echo "Пропустили."
                fi
            clear
            echo -e "\x1B[36m""Впишите нужную локаль в файл locale.conf (например LANG=en_US.UTF-8)""\x1B[0m"
            echo "Продолжить? y/N "
            read var 
                if [ "$var" == "y" ]
                then
                     nano /etc/locale.conf
                else echo "Пропустили."
                fi
            clear
            echo -e "\x1B[36m""Генерируем локаль, продолжить? y/N ""\x1B[0m"
            read var 
                if [ "$var" == "y" ]
                then
                     locale-gen
                else echo "Пропустили."
                fi
            }
#********************************************************************************************16-create_linux_img
function create_linux_img {
        echo -e "\x1B[36m""Создаем linux_img\v""\x1B[0m"
        echo -e "\x1B[36m""Команда:mkinitcpio -p linux""\x1B[0m"
        echo "Продолжить?  y/N"
                read var
                    if [ "$var" == "y" ]
                    then
                        mkinitcpio -p linux
                    else echo "Пропустили."
                    fi
            }
#********************************************************************************************17-grub_config
function grub_config {
        echo -e "\x1B[36m""Обновляем конфигурацию GRUB\v""\x1B[0m"
        echo -e "\x1B[36m""Команда:grub-mkconfig -o /boot/grub/grub.cfg""\x1B[0m"
        echo "Продолжить?  y/N"
                read var
                    if [ "$var" == "y" ]
                    then
                        grub-mkconfig -o /boot/grub/grub.cfg
                    else echo "Пропустили."
                    fi
            }
#********************************************************************************************18-bootloader_installation
function bootloader_installation {
        echo -e "\x1B[36m""Установка загрузчика\v""\x1B[0m"
        echo -e "\x1B[36m""Команда:grub-install /dev/sdX""\x1B[0m"
        echo "Продолжить?  y/N"
                read var
                    if [ "$var" == "y" ]
                    then
                        if [ -z $d_target ]
                        then
                            echo "Введите имя целевого устройства (sd(a,b,c))"
                            read var
                            d_target="/dev/"$var
                        fi
                        grub-install $d_target
                    else echo "Пропустили."
                    fi
            }
#********************************************************************************************19-create_pass_root
function create_pass_root {
        echo -e "\x1B[36m""Создать пороль root\v""\x1B[0m"
        echo "Продолжить?  y/N"
                read var
                    if [ "$var" == "y" ]
                    then
                        echo "Введите пароль для root"
                        passwd
                    else echo "Пропустили."
                    fi
            }
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
                         mv /home/$namevar/arch_install_xorg_ru.sh
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
                         $editor /etc/sudoers
                    else echo "Пропустили."
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

                
                if [[ "$var" == "1" || -z "$var" ]];then
                    step=$(($step+1))
                    echo -e "\x1B[36m""Продолжаем!\v""\x1B[0m"
                elif [ "$var" == "2" ];then
                    echo -e "\x1B[36m""Пропустили "${stepn[$(($step+1))]}", переход к следующему!\v""\x1B[0m"
                    step=$(($step+2))
                    if [ $step -gt 9 ];then
                    echo "Выходим..."
                    read -t 2
                    clear
                    exit
                    fi
                elif [ "$var" == "3" ];then
                    echo -e "\x1B[36m""Повтор!""\x1B[0m"  
                elif [ "$var" == "4" ];then
                    step=0
                    echo -e "\x1B[36m""Возврощаемся на start!""\x1B[0m"
                elif [ "$var" == "5" ];then
                    echo -e "\x1B[36m""select and enter number item""\x1B[0m"
                    echo -e "\x1B[36m""1) Интернет, проверка соединения""\x1B[0m"
                    echo -e "\x1B[36m""2) Разбить диск на разделы ""\x1B[0m"
                    echo -e "\x1B[36m""3) Форматирование разделов""\x1B[0m"
                    echo -e "\x1B[36m""4) Монтирование разделов""\x1B[0m"
                    echo -e "\x1B[36m""5) Редактировать список зеркал""\x1B[0m"
                    echo -e "\x1B[36m""6) Обновляем список пакетов pacman""\x1B[0m"
                    echo -e "\x1B[36m""7) Установка основных пакетов""\x1B[0m"
                    echo -e "\x1B[36m""8) Генерация fstab""\x1B[0m"
                    echo -e "\x1B[36m""9) Переходим в arch-chroot""\x1B[0m"
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
                else echo "Внимание, ошибка"
                fi
            }
#********************************************************************************************menu_installer_chroot      
function dialog_my_chroot {
        echo -e "\x1B[36m""\t\t\t\tШаг ($step): ${stepn_chr[$(($step))]} выполнен(а) или пропущен(а) пользователем \v ""\x1B[0m"
        echo -e "\x1B[33m""\t\t\t\t___________________Выберите_нужный_пункт_____________________""\x1B[0m"
        echo -e "\x1B[36m""\t\t\t\t1) Перейти к следующему шагу:""\x1B[0m"${stepn_chr[$(($step+1))]}
        echo -e "\x1B[36m""\t\t\t\t2) Пропустить следующий ${stepn_chr[$(($step+1))]} и перейти к:""\x1B[0m"${stepn_chr[$(($step+2))]}
        echo -e "\x1B[36m""\t\t\t\t3) Повторить предыдущий шаг:""\x1B[0m"${stepn_chr[$step]} 
        echo -e "\x1B[36m""\t\t\t\t4) Вернуться на старт""\x1B[0m"
        echo -e "\x1B[36m""\t\t\t\t5) Список шагов""\x1B[0m"
        echo -e "\x1B[31m""\t\t\t\tq) Выйти""\x1B[0m"
        read -s -n1 var
        echo -e "\x1B[33m""\t\t\t\t_______________________________V______________________________""\x1B[0m"

            if [ "$var" == "1" ];then
                step=$(($step+1))
            elif [ "$var" == "2" ];then
                echo -e "\x1B[36m""Пропустили "${stepn_chr[$(($step+1))]}", переход к следующему!\v""\x1B[0m"
                step=$(($step+2))
            elif [ "$var" == "3" ];then
                echo -e "\x1B[36m""Повтор!""\x1B[0m"  
            elif [ "$var" == "4" ];then
                step=0
                echo -e "\x1B[36m""Возврощаемся на start!""\x1B[0m"
            elif [ "$var" == "5" ];then
                echo -e "\x1B[36m""Выберите нужный пункт""\x1B[0m"
                echo -e "\x1B[36m""0) Установка пакета загрузчика""\x1B[0m"
                echo -e "\x1B[36m""1) Установка дополнительных пакетов""\x1B[0m"
                echo -e "\x1B[36m""2) Имя машины""\x1B[0m"
                echo -e "\x1B[36m""3) Выбор часового пояса""\x1B[0m"
                echo -e "\x1B[36m""4) Язык системы""\x1B[0m"
                echo -e "\x1B[36m""5) Создаем linux_img""\x1B[0m"
                echo -e "\x1B[36m""6) Обновляем конфигурацию GRUB""\x1B[0m"
                echo -e "\x1B[36m""7) Установка загрузчика""\x1B[0m"
                echo -e "\x1B[36m""8) Создать пороль root""\x1B[0m"
                echo -e "\x1B[36m""7) Создать пользователя""\x1B[0m"
                echo -e "\x1B[36m""8) Дать пользователю привилегии root""\x1B[0m"
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
            umount -R /mnt
            echo -e "\x1B[36m""Базовая система установлена!""\x1B[0m"
            echo -e "\x1B[36m""Теперь вы можете перезагрузить компьютер.""\x1B[0m"
            read -s -n1 -p $'\x1B[32m Нажмите любую клавишу чтобы выйти\n\x1B[0m'
            echo "Выходим..."
                    read -t 2
                    clear
                    exit
            }
#********************************************************************************************exit_chroot
function exit_chroot {
            echo -e "\x1B[36m""Здесь мы закончили можно выходить из arch-chroot""\x1B[0m"
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
}
#********************************************************************************************
stepn=(
   start
   Провека_интернет_соединения
   Разметка_жесткого_диска
   Форматирование_разделов
   Монтирование_разделов
   Редактируем_mirrorlist
   Обновление_информации_о_пакетах
   Установка_основных_пакетов
   Генерируем_fstab
   Переходим_в_arch_chroot
   Выходим
      )
stepn_chr=(
   Устанавливаем_пакет_grub
   Устанавливаем_необходимые_пакеты
   Даем_имя_компьютеру
   Выбераем_часовой_пояс
   Устанавливаем_язык_системы
   Создаем_linux_img
   Обновляем_конфигурацию_grub
   Устанавливаем_загрузчик
   Создаем_пароль_root
   Создать пользователя
   Дать_пользователю_привилегии root
   Выходим
      )
#********************************************************************************************main
if [ -z "$1" ];then
logotip        
echo -e "\x1B[36m""Wellcome to the ArchLinux base install""\x1B[0m"
    while :
    do
        
        case $step in
              0  ) echo "Начинаем!" ;;
              1  ) inet_test        ;;
              2  ) parted_disk      ;;
              3  ) formating_disk   ;;
              4  ) mounting_disk    ;;
              5  ) edit_mirrorlist  ;;
              6  ) pacman_update    ;;
              7  ) istall_base      ;;
              8  ) generate_fstab   ;;
              9  ) goto_arch_chroot ;;
              10 ) exit_inst        ;;
        esac

    read -s -n1 -p $'\x1B[32mНажмите любую клавишу для продолжения\x1B[0m'
    clear
    echo -e "\v\v\v\v\v\v"
        
    dialog_my
    done
elif [[ -n "$1" && "$1" == "--chroot" ]];then
    if [[ -n "$2" ]];then
    d_target=$2
    fi
step=0
    while :
    do
        case $step in
             0  ) grub_pkg_install ;;
             1  ) pakages_install  ;;
             2  ) host_name        ;;
             3  ) time_zone        ;;
             4  ) edit_locale      ;;
             5  ) create_linux_img ;;
             6  ) grub_config      ;;
             7  ) bootloader_installation ;;
             8  ) create_pass_root ;;
             9  ) create_user      ;;
             10 ) sudo_for_user    ;;
             11 ) exit_chroot      ;;
        esac
    
        read -s -n1 -p $'\x1B[32mНажмите любую клавишу для продолжения\x1B[0m'
        clear
        echo -e "\v\v\v\v\v\v"
        
        dialog_my_chroot
    done
fi
