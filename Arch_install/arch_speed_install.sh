#!/bin/bash
loadkeys ru
setfont cyr-sun16
clear
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
#start
d_target=""
d_boot=""
d_root=""
d_swap=""
d_home=""
step=0
#********************************************************************************************1-inet_test
function inet_test {        
        echo -e "\x1B[32m""Интернет, проверка соединения""\x1B[0m"
                        var=$(ping -c3 8.8.8.8 | awk '/transmitted/{print $1+$4}')
                        if [ $var  == "6" ]
                        then echo -e "\x1B[32m""Есть соединение с интернетом""\x1B[0m"
                        else echo -e "\x1B[32m""Соединение с интернетом нет!""\x1B[0m"
                             echo -e "\x1B[32m""Пожалуйста, настройте соединение с интернетом""\x1B[0m"
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
                                    then
                                    echo -e "\x1B[32m""Есть соединение с интернетом""\x1B[0m"
                                    read -s -n1 -p $'\x1B[32m Нажмите любую клавишу для продолжения\x1B[0m'
                                    clear
                                    else
                                        echo -e "\x1B[32m""Соединение с интернетом отсутствует!""\x1B[0m"
                                        read -s -n1 -p $'\x1B[32m Нажмите любую клавишу для продолжения\x1B[0m'
                                        exit
                                    fi
                        fi
        }
        
#*********************************************************************************************2-parted_disk       
function parted_disk {
        echo -e "\x1B[36m""Разбить диск на разделы""\x1B[0m"
            lsblk -f
            echo -e "\x1B[35m""Введите имя устройства (например sda)""\x1B[0m"
            read var
            cfdisk "/dev/"$var
            lsblk -f
            read -s -n1 -p $'\x1B[32m Нажмите любую клавишу для продолжения\x1B[0m'
            clear
            }
#********************************************************************************************assign_sections
function assign_sections {
        echo -e "\x1B[36m""Выбор точки монтирования для каждого раздела""\x1B[0m"
                        echo "Введите имя целевого устройства (например sd(a, b, c ...))"
                        read var
                        d_target="/dev/"$var
                        echo "Введите имя раздела (например 1 , 2 , 3 ...) для boot"
                        read var
                        d_boot=$d_target$var   
                        echo "Введите имя раздела (например 1 , 2 , 3 ...) для root"
                        read var
                        d_root=$d_target$var
                        echo "Введите имя раздела (например 1 , 2 , 3 ...) для swap"
                        read var
                        d_swap=$d_target$var
                        echo "Введите имя раздела (например 1 , 2 , 3 ...) для home"
                        read var
                        d_home=$d_target$var
                        echo "target:"$d_target
                        echo "for boot:"$d_boot
                        echo "for root:"$d_root
                        echo "for swap:"$d_swap
                        echo "for home:"$d_home
                        
            read -s -n1 -p $'\x1B[32m Нажмите любую клавишу для продолжения\x1B[0m'
            clear
            }
#********************************************************************************************3-formating_disk
function formating_disk {
        echo -e "\x1B[36m""Форматирование разделов""\x1B[0m"
            if [[ -z $d_target && -z $d_boot && -z $d_root && -z $d_home ]]
            then
            assign_sections
            fi
            mkfs.ext2 $d_boot
            mkfs.ext4 $d_root
            mkfs.ext4 $d_home
                lsblk -f
                
            read -s -n1 -p $'\x1B[32m Нажмите любую клавишу для продолжения\x1B[0m'
            clear
            }
#********************************************************************************************4-mounting_disk
function mounting_disk {        
        echo -e "\x1B[36m""Монтирование разделов""\x1B[0m"
        
                        if [[ -z $d_target && -z $d_boot && -z $d_root && -z $d_home ]]
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
                    
                lsblk -f
                
            read -s -n1 -p $'\x1B[32m Нажмите любую клавишу для продолжения\x1B[0m'
            clear
            }
#********************************************************************************************5-edit_mirrorlist
function edit_mirrorlist {
        echo -e "\x1B[36m""Редактировать список зеркал""\x1B[0m"      
            echo "какой редактор 1)-vim 2)-nano "
                read var 
                if [ "$var" == "1" ]
                then
                     vim /etc/pacman.d/mirrorlist
                elif [ "$var" == "2" ]
                then
                     nano /etc/pacman.d/mirrorlist
                fi
            }
  
#********************************************************************************************6-pacman_update
function pacman_update {
        echo -e "\x1B[36m""Обновляем список пакетов pacman""\x1B[0m"
            pacman -Syy
            read -s -n1 -p $'\x1B[32m Нажмите любую клавишу для продолжения\x1B[0m'
            clear
            }
#********************************************************************************************7-istall_base
function istall_base {
        echo -e "\x1B[36m""Установка основных пакетов""\x1B[0m"
            pacstrap /mnt base base-devel
            read -s -n1 -p $'\x1B[32m Нажмите любую клавишу для продолжения\x1B[0m'
            clear
            }
#********************************************************************************************8-generate_fstab
function generate_fstab {
        echo -e "\x1B[36m""Генерация fstab""\x1B[0m"
            genfstab -pU /mnt >> /mnt/etc/fstab
            read -s -n1 -p $'\x1B[32m Нажмите любую клавишу для продолжения\x1B[0m'
            clear
            }
#********************************************************************************************9-goto_arch_chroot
function goto_arch_chroot {
        echo -e "\x1B[36m""Переходим в arch-chroot""\x1B[0m"
                        cp $0 /mnt/root
                        chmod 755 /mnt/root/$(basename "0")
                        arch-chroot /mnt /root/$(basename "0") --chroot $d_target
                        umount $d_boot
                        umount $d_home
                        umount $d_root
                        swapoff $d_swap
            echo "Exit"
            read -s -n1 -p $'\x1B[32m Нажмите любую клавишу для продолжения\x1B[0m'
            clear
            }
#********************************************************************************************10-grub_pkg_install
function grub_pkg_install {
        echo -e "\x1B[36m""Установка пакета загрузчика""\x1B[0m"
            pacman -S grub
            read -s -n1 -p $'\x1B[32m Нажмите любую клавишу для продолжения\x1B[0m'
            clear
            }
#********************************************************************************************11-pakages_install
function pakages_install {
            echo -e "\x1B[36m""Установка дополнительных пакетов""\x1B[0m"
                echo "Введите названия необходимых пакетов разделяя пробелом "
                read var
                pacman -S $var
                read -s -n1 -p $'\x1B[32m Нажмите любую клавишу для продолжения\x1B[0m'
                clear
            }
#********************************************************************************************12-host_name
function host_name {
            echo -e "\x1B[36m""Имя машины""\x1B[0m"
                echo "Введите имя машины:"
                read var
                echo $var > /etc/hostname
            }
#********************************************************************************************13-time_zone
function time_zone {
            echo -e "\x1B[36m""Выбор часового пояса""\x1B[0m"
                ls /usr/share/zoneinfo/Europe
                echo "Выберите из списка часовой пояс"
                read var
                rm /etc/localtime
                ln -s /usr/share/zoneinfo/Europe/$var /etc/localtime
            }
#********************************************************************************************14-edit_locale
function edit_locale {
        echo -e "\x1B[36m""Язык системы""\x1B[0m"      
                echo "какой редактор 1)-vim 2)-nano "
                read var 
                if [ "$var" == "1" ]
                then
                     echo   "Разкоментируйте нужные локали в файле locale.gen"
                     read -s -n1 -p $'\x1B[32m Нажмите любую клавишу для продолжения. \x1B[0m'
                     vim /etc/locale.gen
                     clear
                     echo   "Впишите нужную локаль в файл locale.conf (например LANG=en_US.UTF-8)"
                     read -s -n1 -p $'\x1B[32m Нажмите любую клавишу для продолжения. \x1B[0m'
                     vim /etc/locale.conf
                     clear
                elif [ "$var" == "2" ]
                then
                     echo   "Разкоментируйте нужные локали в файле locale.gen"
                     read -s -n1 -p $'\x1B[32m Нажмите любую клавишу для продолжения. \x1B[0m'
                     nano /etc/locale.gen
                     clear
                     echo   "Впишите нужную локаль в файл locale.conf (например LANG=en_US.UTF-8)"
                     read -s -n1 -p $'\x1B[32m Нажмите любую клавишу для продолжения. \x1B[0m'
                     nano /etc/locale.conf
                     clear
                fi

                locale-gen
            }
#********************************************************************************************15-create_linux_img
function create_linux_img {
        echo -e "\x1B[36m""Создаем linux_img""\x1B[0m"
                        mkinitcpio -p linux
            read -s -n1 -p $'\x1B[32m Нажмите любую клавишу для продолжения\x1B[0m'
            clear       
            }
#********************************************************************************************16-grub_config
function grub_config {
        echo -e "\x1B[36m""Обновляем конфигурацию GRUB""\x1B[0m"
            grub-mkconfig -o /boot/grub/grub.cfg
            read -s -n1 -p $'\x1B[32m Нажмите любую клавишу для продолжения\x1B[0m'
            clear
            }
#********************************************************************************************17-bootloader_installation
function bootloader_installation {
        echo -e "\x1B[36m""Установка загрузчика""\x1B[0m"
                        if [ -z "$d_target" ]
                        then
                            echo "Введите имя целевого устройства (sd(a,b,c))"
                            read var
                            d_target="/dev/"$var
                        fi
                        grub-install $d_target
            read -s -n1 -p $'\x1B[32m Нажмите любую клавишу для продолжения\x1B[0m'
            clear     
            }
#********************************************************************************************18-create_pass_root
function create_pass_root {
        echo -e "\x1B[36m""Создать пороль root""\x1B[0m"
            echo "Введите пароль для root"
            echo "Выходим из chroot"
            read -s -n1 -p $'\x1B[32m Нажмите любую клавишу для продолжения\x1B[0m'
            clear
            }

#********************************************************************************************main
if [[ -z "$1" ]]
then 
echo -e "\x1B[36m""Wellcome to the ArchLinux""\x1B[0m"
echo "The start" 
inet_test        
parted_disk      
assign_sections  
formating_disk   
mounting_disk    
edit_mirrorlist  
pacman_update    
istall_base      
generate_fstab   
goto_arch_chroot
elif [[ -n "$1" && "$1" == "--chroot" ]]
then
    if [ -z "$2" ]
    then
    echo "Введите имя целевого устройства (sd(a,b,c))"
    read var
    d_target="/dev/"$var
    elif [ -n "$2" ]
    then
    d_target=$2
    fi
grub_pkg_install 
pakages_install  
host_name        
time_zone        
edit_locale      
create_linux_img 
grub_config      
bootloader_installation 
create_pass_root 
exit_installer
fi
echo -e "\x1B[36m""********************END****************************""\x1B[0m"
echo -e "\x1B[36m""Базовая система установлена  ""\x1B[0m"        
read -s -n1 -p $'\x1B[32m Нажмите любую клавишу для выхода\x1B[0m'
