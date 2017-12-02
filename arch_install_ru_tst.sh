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
#EFI "e", BIOS "b"
mng_boot="e"
editor=nano
step=0
#********************************************************************************************1-inet_test
function inet_test {        
        echo -e "\x1B[36m""Интернет, проверка соединения\v""\x1B[0m"
            echo "Продолжить?  Y/n"
                read var
                    if [[ -z  "$var" || "$var" == "Y" || "$var" == "y" ]];then
                      while :
		      do
                        var=$(ping -c3 8.8.8.8 | awk '/transmitted/{print $1+$4}')
                        if [ $var  == "6" ];then 
			     echo -e "\x1B[36m""Есть соединение с интернетом""\x1B[0m"
			     break
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
                                 echo "wait..."
                                 sleep 8
                        fi
		    done
                    else echo "Пропустили."
                  fi    
        }
        
#*********************************************************************************************2-parted_disk       
function parted_disk {
        echo -e "\x1B[36m""Разбить диск на разделы\v""\x1B[0m"
            echo "Продолжить?  Y/n"
                read var
                    if [[ -z  "$var" || "$var" == "Y" || "$var" == "y" ]];then
                        lsblk -f
                        echo -e "\x1B[35m""Введите имя устройства (например sda)""\x1B[0m"
                        read var
                        d_target="/dev/"$var
                        sudo cfdisk $d_target
                    else echo "Пропустили."
                    fi
            }
#********************************************************************************************3-assign_sections
function assign_sections {
        echo -e "\x1B[36m""Выбор точки монтирования для каждого раздела\v""\x1B[0m"
            echo "Продолжить?  Y/n"
                read var
                    if [[ -z  "$var" || "$var" == "Y" || "$var" == "y" ]];then
                        if [ -z "$d_target" ];then
                        echo "Введите имя целевого устройства (например sda)"
                        read var
                        d_target="/dev/"$var
                        fi
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
            echo "Продолжить?  Y/n"
                read var
                    if [[ -z  "$var" || "$var" == "Y" || "$var" == "y" ]];then
                        if [[ -z "$d_target" || -z "$d_boot" || -z "$d_root" || -z "$d_home" ]]
                        then
                            assign_sections
                        fi
                        while :
                        do
                            if [ "$mng_boot" == "b" ];then
                                mkfs.ext2 $d_boot
                                read -t 3
                                if [[ $(lsblk -f $d_boot | awk '/sd/{print $2}') == "ext2" ]];then
                                    echo "$d_boot format ext2 Ok"
                                else
                                    echo -e "\x1B[31m""ERROR попробуйте повторить этот шаг""\x1B[0m"
                                    read -s -n1 -p $'\x1B[32m Нажмите любую клавишу\x1B[0m'
                                    break
                                fi
                            fi
                            if [ "$mng_boot" == "e" ];then
                                mkfs.vfat $d_boot
                                read -t 3
                                if [[ $(lsblk -f $d_boot | awk '/sd/{print $2}') == "vfat" ]];then
                                    echo "$d_boot format ext2 Ok"
                                else
                                    echo -e "\x1B[31m""ERROR попробуйте повторить этот шаг""\x1B[0m"
                                    read -s -n1 -p $'\x1B[32m Нажмите любую клавишу\x1B[0m'
                                    break
                                fi
                            fi
                            mkfs.ext4 $d_root
                            read -t 3
                            if [[ $(lsblk -f $d_root | awk '/sd/{print $2}') == "ext4" ]];then
                                echo "$d_root format ext4 Ok"
                            else
                                echo -e "\x1B[31m""ERROR попробуйте повторить этот шаг""\x1B[0m"
                                read -s -n1 -p $'\x1B[32m Нажмите любую клавишу\x1B[0m'
                                break
                            fi
                            mkfs.ext4 $d_home
                            read -t 3
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
                        clear
                        echo -e "\x1B[31m""Форматирование закончено, выводим результат:""\x1B[0m"
                            lsblk -f
                        }
#********************************************************************************************5-mounting_disk
function mounting_disk {        
        echo -e "\x1B[36m""Монтирование разделов\v""\x1B[0m"
            echo "Продолжить?  Y/n"
                read var
                    if [[ -z  "$var" || "$var" == "Y" || "$var" == "y" ]];then
                        if [[ -z "$d_target" || -z "$d_boot" || -z "$d_root" || -z "$d_home" ]]
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
                clear
                lsblk -f
            }
#********************************************************************************************6-edit_mirrorlist
function edit_mirrorlist {
        echo -e "\x1B[36m""Редактировать список зеркал\v""\x1B[0m"
            echo "1) Выполнить вручную"
            echo "2) Выполнить с помощью утилиты reflector"
                read var 
                if [ "$var" == "1" ];then
                    $editor /etc/pacman.d/mirrorlist
                elif [ "$var" == "2" ];then
                    if [[ $(pacman -Qs reflector | awk '/\//{print $1}') == "local/reflector" ]];then
                    /usr/bin/reflector --verbose -l 5 --sort rate --save /etc/pacman.d/mirrorlist
                    elif [[ -z $(pacman -Qs reflector | awk '/\//{print $1}') ]];then
                    pacman -S reflector
                    /usr/bin/reflector --verbose -l 5 --sort rate --save /etc/pacman.d/mirrorlist
                    fi
                else echo "Пропустили."
                fi
            }
  
#********************************************************************************************7-pacman_update
function pacman_update {
        echo -e "\x1B[36m""Обновляем список пакетов в базе данных pacman\v""\x1B[0m"
            echo "Продолжить?  Y/n"
                read var
                    if [[ -z  "$var" || "$var" == "Y" || "$var" == "y" ]];then
                        pacman -Syy
                    else echo "Пропустили."
                    fi
            }
#********************************************************************************************8-istall_base
function istall_base {
        echo -e "\x1B[36m""Установка основных пакетов\v""\x1B[0m"
            echo "Продолжить?  Y/n"
                read var
                    if [[ -z  "$var" || "$var" == "Y" || "$var" == "y" ]];then
                        pacstrap /mnt base base-devel
                    else echo "Пропустили."
                    fi
            }
#********************************************************************************************9-generate_fstab
function generate_fstab {
        echo -e "\x1B[36m""Генерация fstab\v""\x1B[0m"
            echo "Продолжить?  Y/n"
                read var
                    if [[ -z  "$var" || "$var" == "Y" || "$var" == "y" ]];then
                        genfstab -pU /mnt >> /mnt/etc/fstab
                    else echo "Пропустили."
                    fi
            }
#********************************************************************************************10-goto_arch_chroot
function goto_arch_chroot {
        echo -e "\x1B[36m""Переходим в arch-chroot\v""\x1B[0m"
            echo "Продолжить?  Y/n"
                read var
                    if [[ -z  "$var" || "$var" == "Y" || "$var" == "y" ]];then
                        cp $0 /mnt/root
                        chmod 755 /mnt/root/$(basename "$0")
                        arch-chroot /mnt /root/$(basename "$0") --chroot $d_target
                        rm /mnt/root/$(basename "$0")
                    else echo "Пропустили."
                    fi
            }
#********************************************************************************************11-grub_pkg_install
function grub_pkg_install {
        echo -e "\x1B[36m""Установка пакета загрузчика\v""\x1B[0m"
            echo "Продолжить?  Y/n"
                read var
                    if [[ -z  "$var" || "$var" == "Y" || "$var" == "y" ]];then
                        if [ "$mng_boot" == "b" ];then
                            pacman -S grub vim ranger
                        elif [ "$mng_boot" == "e" ];then
                            pacman -S grub efibootmgr vim ranger
                        fi
                    else echo "Пропустили."
                    fi
            }
#********************************************************************************************13-host_name
function host_name {
            echo -e "\x1B[36m""Имя машины\v""\x1B[0m"
            echo "Продолжить?  Y/n"
                read var
                    if [[ -z  "$var" || "$var" == "Y" || "$var" == "y" ]];then
                            echo "Введите имя машины:"
                            read var
                            echo $var > /etc/hostname
                        else echo "Пропустили."
                        fi
            }
#********************************************************************************************14-time_zone
function time_zone {
            echo -e "\x1B[36m""Выбор часового пояса\v""\x1B[0m"
            echo "Продолжить?  Y/n"
                read var
                    if [[ -z  "$var" || "$var" == "Y" || "$var" == "y" ]];then
                        ls /usr/share/zoneinfo/Europe
                        echo "Выберите из списка часовой пояс"
                        read var
                        ln -sf /usr/share/zoneinfo/Europe/$var /etc/localtime
                    else echo "Пропустили."
                    fi
            }
#********************************************************************************************15-edit_locale
function edit_locale {
        echo -e "\x1B[36m""Язык системы\v""\x1B[0m"
            echo "Продолжить?  Y/n"
                read var
                    if [[ -z  "$var" || "$var" == "Y" || "$var" == "y" ]];then
                     echo -e "en_US.UTF-8 UTF-8" >> /etc/locale.gen
                     echo -e "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
                else echo "Пропустили."
                fi
            clear
            echo "LANG=ru_RU.UTF-8" > /etc/locale.conf
            echo 'KEYMAP=ru' >> /etc/vconsole.conf
            echo 'FONT=cyr-sun16' >> /etc/vconsole.conf
            echo -e "\x1B[36m""Генерируем локаль, продолжить? Y/n ""\x1B[0m"
                read var
                    if [[ -z  "$var" || "$var" == "Y" || "$var" == "y" ]];then
                     locale-gen
                else echo "Пропустили."
                fi
            }
#********************************************************************************************16-create_linux_img
function create_linux_img {
        echo -e "\x1B[36m""Создаем linux_img\v""\x1B[0m"
            echo "Продолжить?  Y/n"
                read var
                    if [[ -z  "$var" || "$var" == "Y" || "$var" == "y" ]];then
                        mkinitcpio -p linux
                    else echo "Пропустили."
                    fi
            }
#********************************************************************************************17-grub_config
function grub_config {
        echo -e "\x1B[36m""Обновляем конфигурацию GRUB\v""\x1B[0m"
            echo "Продолжить?  Y/n"
                read var
                    if [[ -z  "$var" || "$var" == "Y" || "$var" == "y" ]];then
                        grub-mkconfig -o /boot/grub/grub.cfg
                    else echo "Пропустили."
                    fi
            }
#********************************************************************************************18-bootloader_installation
function bootloader_installation {
        echo -e "\x1B[36m""Установка загрузчика\v""\x1B[0m"
            echo "Продолжить?  Y/n"
                read var
                    if [[ -z  "$var" || "$var" == "Y" || "$var" == "y" ]];then
                        if [ "$mng_boot" == "b" ];then
                            if [ -z $d_target ];then
                                echo "Введите имя целевого устройства (sd(a,b,c))"
                                read var
                                d_target="/dev/"$var
                            fi
                            grub-install $d_target
                        elif [ "$mng_boot" == "e" ];then
                            grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub    
                        fi
                    else echo "Пропустили."
                    fi
            }
#********************************************************************************************19-create_pass_root
function create_pass_root {
        echo -e "\x1B[36m""Создать пороль root\v""\x1B[0m"
            echo "Продолжить?  Y/n"
                read var
                    if [[ -z  "$var" || "$var" == "Y" || "$var" == "y" ]];then
                        echo "Введите пароль для root"
                        passwd
                    else echo "Пропустили."
                    fi
            }
#********************************************************************************************create_user
function create_user {
        echo -e "\x1B[36m""Создать пользователя и дать ему привилегии root\v""\x1B[0m"
            echo "Продолжить?  Y/n"
                read var
                    if [[ -z  "$var" || "$var" == "Y" || "$var" == "y" ]];then
                         echo "Введите имя пользователя"
                         read namevar
                         echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
                         useradd -m -g users -G wheel -s /bin/bash $namevar
                         echo "Введите пароль пользователя"
                         passwd $namevar
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
#********************************************************************************************menu_installer      
function dialog_my {
        echo -e "\x1B[36m""\t\t\t\tШаг ($step): ${stepn[$(($step))]} выполнен(а) или пропущен(а) пользователем \v ""\x1B[0m"
        echo -e "\x1B[33m""\t\t\t\t___________________Выберите_нужный_пункт_____________________""\x1B[0m"
        echo -e "\x1B[36m""\t\t\t\t1) Перейти к следующему шагу:""\x1B[0m"${stepn[$(($step+1))]}
        echo -e "\x1B[36m""\t\t\t\t2) Пропустить ${stepn[$(($step+1))]} и перейти к:""\x1B[0m"${stepn[$(($step+2))]}
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
                    read step
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
        echo -e "\x1B[36m""\t\t\t\t2) Пропустить ${stepn_chr[$(($step+1))]} и перейти к:""\x1B[0m"${stepn_chr[$(($step+2))]}
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
                echo -e "\x1B[36m"" 0) Установка пакета загрузчика""\x1B[0m"
                echo -e "\x1B[36m"" 1) Имя машины""\x1B[0m"
                echo -e "\x1B[36m"" 2) Выбор часового пояса""\x1B[0m"
                echo -e "\x1B[36m"" 3) Язык системы""\x1B[0m"
                echo -e "\x1B[36m"" 4) Создаем linux_img""\x1B[0m"
                echo -e "\x1B[36m"" 5) Обновляем конфигурацию GRUB""\x1B[0m"
                echo -e "\x1B[36m"" 6) Установка загрузчика""\x1B[0m"
                echo -e "\x1B[36m"" 7) Создать пороль root""\x1B[0m"
                echo -e "\x1B[36m"" 8) Создать пользователя и дать ему привилегии root""\x1B[0m"
                echo -e "\x1B[36m"" 9) Установка xorg""\x1B[0m"
		echo -e "\x1B[36m"" 10) Установка alsa(звук)""\x1B[0m"
                echo -e "\x1B[36m"" 11) Установка шрифтов""\x1B[0m"
                echo -e "\x1B[33m""______________________________________V_________________________________________________\v\v""\x1B[0m"
                read step
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
            echo -e "\x1B[36m""Здесь мы закончили, выходим из arch-chroot""\x1B[0m"
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
   'start'
   'Провека интернет соединения'
   'Разметка жесткого диска'
   'Форматирование разделов'
   'Монтирование разделов'
   'Редактируем mirrorlist'
   'Обновление информации о пакетах'
   'Установка основных пакетов'
   'Генерируем fstab'
   'Переходим в arch chroot'
   'Выходим'
      )
stepn_chr=(
   'Устанавливаем пакет grub'
   'Даем имя компьютеру'
   'Выбераем часовой пояс'
   'Устанавливаем язык системы'
   'Создаем linux img'
   'Обновляем конфигурацию grub'
   'Устанавливаем загрузчик'
   'Создаем пароль root'
   'Создаем пользователя и даем ему привилегии root'
   'Устанавливаем XORG'
   'Устанавливаем ALSA'
   'Устанавливаем шрифты'
   'Выходим'
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
             1  ) host_name        ;;
             2  ) time_zone        ;;
             3  ) edit_locale      ;;
             4  ) create_linux_img ;;
             5  ) grub_config      ;;
             6  ) bootloader_installation ;;
             7  ) create_pass_root ;;
             8  ) create_user      ;;
             9  ) xorg_component_install  ;;
             10 ) alsa_component_install  ;;
             11 ) font_install     ;;
             12 ) exit_chroot      ;;
        esac
    
        read -s -n1 -p $'\x1B[32mНажмите любую клавишу для продолжения\x1B[0m'
        clear
        echo -e "\v\v\v\v\v\v"
        
        dialog_my_chroot
    done
fi
