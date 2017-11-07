#!/bin/bash
#проверка русской локали
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
d_target=0
d_boot=0
d_root=0
d_swap=0
d_home=0
step=0
#********************************************************************************************1-inet_test
function inet_test {        
        echo -e "\x1B[32m""Интернет, проверка соединения""\x1B[0m"
            echo "Продолжить?  y/N"
                read var
                    if [ "$var" == "y" ]
                    then
                        var=$(ping -c1 8.8.8.8 | awk '/transmitted/{print $1+$4}')
                        if [ $var  == "2" ]
                        then echo -e "\x1B[32m""Есть соединение с интернетом""\x1B[0m"
                        else echo -e "\x1B[32m""Соединение с интернетом нет!""\x1B[0m"
                             echo -e "\x1B[32m""Пожалуйста, настройте соединение с интернетом""\x1B[0m"
                        fi
                    else echo "Пропустили."
                    fi    
        }
        
#*********************************************************************************************2-parted_disk       
function parted_disk {
        echo -e "\x1B[36m""Разбить диск на разделы""\x1B[0m"
            echo "Продолжить?  y/N"
                read var
                    if [ "$var" == "y" ]
                    then
                        echo -e "\x1B[35m""Введите имя устройства (например sda)""\x1B[0m"
                        read var
                        sudo cfdisk "/dev/"$var
                    else echo "Пропустили."
                    fi
            }
#********************************************************************************************3-assign_sections
function assign_sections {
        echo -e "\x1B[36m""Выбор точки монтирования для каждого раздела""\x1B[0m"
            echo "Продолжить? y/N"
                read var
                    if [ "$var" == "y" ]
                    then
                        echo "Введите имя целевого устройства (например sda)"
                        read var
                        d_target="/dev/"$var
                        echo "Введите имя раздела (например sda1) для boot"
                        read var
                        d_boot="/dev/"$var   
                        echo "Введите имя раздела (например sda2) для root"
                        read var
                        d_root="/dev/"$var
                        echo "Введите имя раздела (например sda3) для swap"
                        read var
                        d_swap="/dev/"$var
                        echo "Введите имя раздела (sнапример sda4) для home"
                        read var
                        d_home="/dev/"$var
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
        echo -e "\x1B[36m""Форматирование разделов""\x1B[0m"
                
            echo "Продолжить?  y/N"
                read var
                    if [ "$var" == "y" ]
                    then
                        if [[ $d_target -eq 0 || $d_boot -eq 0 || $d_root -eq 0 || $d_home -eq 0 ]]
                        then
                            assign_sections
                        fi
                        mkfs.ext2 $d_boot
                        mkfs.ext4 $d_root
                        mkfs.ext4 $d_home
                    else echo "Пропустили."
                    fi
                lsblk -f
            }
#********************************************************************************************5-mounting_disk
function mounting_disk {        
        echo -e "\x1B[36m""Монтирование разделов""\x1B[0m"
            echo "Продолжить?  y/N"
                read var
                    if [ "$var" == "y" ]
                    then
                        if [[ $d_target -eq 0 || $d_boot -eq 0 || $d_root -eq 0 || $d_home -eq 0 ]]
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
        echo -e "\x1B[36m""Редактировать список зеркал""\x1B[0m"      
            echo "Продолжить? y/N "
                read var 
                if [ "$var" == "y" ]
                then
                     nano /etc/pacman.d/mirrorlist
                else echo "Пропустили."
                fi
            }
  
#********************************************************************************************7-pacman_update
function pacman_update {
        echo -e "\x1B[36m""Обновляем список пакетов pacman""\x1B[0m"
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
        echo -e "\x1B[36m""Установка основных пакетов""\x1B[0m"
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
        echo -e "\x1B[36m""Генерация fstab""\x1B[0m"
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
        echo -e "\x1B[36m""Переходим в arch-chroot""\x1B[0m"
        echo -e "\x1B[36m""После выполнения этого пункта""\x1B[0m"
        echo -e "\x1B[36m""произойдет копирование этого скрипта""\x1B[0m"
        echo -e "\x1B[36m""в /mnt/home и переход в arch-chroot""\x1B[0m"
        echo -e "\x1B[36m""для продолжения нужно перейти в папку /home""\x1B[0m"
        echo -e "\x1B[36m""и запустить скрипт, в меню выбрать пункт 6""\x1B[0m"
        echo -e "\x1B[36m""и из списка выбрать 11 шаг""\x1B[0m"
            echo "Continue?  y/N"
                read var
                    if [ "$var" == "y" ]
                    then
                        cp arch_install /mnt/home
                        arch-chroot /mnt
                    else echo "Пропустили."
                    fi
            }
#********************************************************************************************11-grub_pkg_install
function grub_pkg_install {
        echo -e "\x1B[36m""Установка пакета загрузчика""\x1B[0m"
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
            echo -e "\x1B[36m""Установка дополнительных пакетов""\x1B[0m"
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
            echo -e "\x1B[36m""Имя машины""\x1B[0m"
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
            echo -e "\x1B[36m""Выбор часового пояса""\x1B[0m"
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
        echo -e "\x1B[36m""Язык системы""\x1B[0m"      
            echo "Продолжить? y/N "
                read var 
                if [ "$var" == "y" ]
                then
                     echo   "Разкоментируйте нужные локали в файле locale.gen"
                     read -s -n1 -p $'\x1B[32m Нажмите любую клавишу для продолжения. \x1B[0m'
                     nano /etc/locale.gen
                     echo   "Впишите нужную локаль в файл locale.conf (например LANG=en_US.UTF-8)"
                     read -s -n1 -p $'\x1B[32m Нажмите любую клавишу для продолжения. \x1B[0m'
                     nano /etc/locale.conf
                else echo "Пропустили."
                fi
            echo "Генерируем локаль, продолжить? y/N "
                read var 
                if [ "$var" == "y" ]
                then
                     locale-gen
                else echo "Пропустили."
                fi
            }
#********************************************************************************************16-create_linux_img
function create_linux_img {
        echo -e "\x1B[36m""Создаем linux_img""\x1B[0m"
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
        echo -e "\x1B[36m""Обновляем конфигурацию GRUB""\x1B[0m"
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
        echo -e "\x1B[36m""Установка загрузчика""\x1B[0m"
        echo "Продолжить?  y/N"
                read var
                    if [ "$var" == "y" ]
                    then
                        if [ $d_target -eq 0 ]
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
        echo -e "\x1B[36m""Создать пороль root""\x1B[0m"
        echo "Продолжить?  y/N"
                read var
                    if [ "$var" == "y" ]
                    then
                        echo "Введите пароль для root"
                        passwd
                    else echo "Пропустили."
                    fi
            }
#********************************************************************************************20-exit_installer
function exit_installer {
        echo -e "\x1B[36m""EXIT""\x1B[0m"
        echo "Continue?  y/N"
                read var
                    if [ "$var" == "y" ]
                    then
                        echo "exit of arch-chroot"
                        exit
                        
                    else echo "Skip"
                    fi
            }
#********************************************************************************************z-dialog_my       
function dialog_my {
        echo -e "\x1B[33m""___Выберите_нужный_пункт__________""\x1B[0m"
        echo -e "\x1B[36m""1)Продолжить:""\x1B[0m"${stepn[$(($step+1))]}
        echo -e "\x1B[36m""2)Следующий:""\x1B[0m"${stepn[$(($step+2))]}
        echo -e "\x1B[36m""3)Предыдущий:""\x1B[0m"${stepn[$step]} 
        echo -e "\x1B[36m""4)Вернуться к:""\x1B[0m"${stepn[$(($step-1))]}
        echo -e "\x1B[36m""5)Вернуться на старт""\x1B[0m"
        echo -e "\x1B[36m""6)Список шагов""\x1B[0m"
        echo -e "\x1B[31m""7)Выйти""\x1B[0m"
        read var
        echo -e "\x1B[33m""______________V______________""\x1B[0m"

                if [ "$var" == "1" ]
                then
                    step=$(($step+1))
                    echo -e "\x1B[36m""Continue!""\x1B[0m"
                elif [ "$var" == "2" ]
                then
                    echo -e "\x1B[36m""Пропустили "${stepn[$(($step+1))]}", переход к следующему!""\x1B[0m"
                    step=$(($step+2))
                elif [ "$var" == "3" ]
                then
                    echo -e "\x1B[36m""Повтор!""\x1B[0m"  
                elif [ "$var" == "4" ]
                then
                    step=$(($step-1))
                    echo -e "\x1B[36m""Возврощаемся!""\x1B[0m"
                elif [ "$var" == "5" ]
                then
                    step=0
                    echo -e "\x1B[36m""Возврощаемся на start!""\x1B[0m"
                elif [ "$var" == "6" ]
                then
                    echo -e "\x1B[36m""select and enter number item""\x1B[0m"
                    echo -e "\x1B[36m""1) Интернет, проверка соединения                                          11) Установка пакета загрузчика""\x1B[0m"
                    echo -e "\x1B[36m""2) Разбить диск на разделы                                                      12) Установка дополнительных пакетов""\x1B[0m"
                    echo -e "\x1B[36m""3) Выбор точки монтирования для каждого раздела          13) Имя машины""\x1B[0m"
                    echo -e "\x1B[36m""4) Форматирование разделов                                                  14) Выбор часового пояса""\x1B[0m"
                    echo -e "\x1B[36m""5) Монтирование разделов                                                      15) Язык системы""\x1B[0m"
                    echo -e "\x1B[36m""6) Редактировать список зеркал                                             16) Создаем linux_img""\x1B[0m"
                    echo -e "\x1B[36m""7) Обновляем список пакетов pacman                                   17) Обновляем конфигурацию GRUB""\x1B[0m"
                    echo -e "\x1B[36m""8) Установка основных пакетов                                              18) Установка загрузчика""\x1B[0m"
                    echo -e "\x1B[36m""9) Генерация fstab                                                                     19) Создать пороль root""\x1B[0m"
                    echo -e "\x1B[36m""10) Переходим в arch-chroot                                                   20) exit_installer""\x1B[0m"
                    read step
                    if [ "$step" == "" ]
                    then echo "skip"
                    fi
                elif [ "$var" == "7" ]
                then echo "exit"
                     exit
                fi
            }                   
#********************************************************************************************main
stepn=(
   start
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
      )
        
echo -e "\x1B[36m""Wellcome to the ArchLinux""\x1B[0m"
while :
    do
    case $step in
          0  ) echo "The start" ;;
          1  ) inet_test        ;;
          2  ) parted_disk      ;;
          3  ) assign_sections  ;;
          4  ) formating_disk   ;;
          5  ) mounting_disk    ;;
          6  ) edit_mirrorlist  ;;
          7  ) pacman_update    ;;
          8  ) istall_base      ;;
          9  ) generate_fstab   ;;
         10  ) goto_arch_chroot ;;
         11  ) grub_pkg_install ;;
         12  ) pakages_install  ;;
         13  ) host_name        ;;
         14  ) time_zone        ;;
         15  ) edit_locale      ;;
         16  ) create_linux_img ;;
         17  ) grub_config      ;;
         18  ) bootloader_installation ;;
         19  ) create_pass_root ;;
         20  ) exit_installer   ;;
    esac

    read -s -n1 -p $'\x1B[32m press any key to continue\x1B[0m'
    clear
    echo -e "\x1B[33m""__________step____________""\x1B[0m"
    if [ $step -gt 0 ]
    then
    echo "previous step:"${stepn[$(($step-1))]}
    fi
    echo "done     step:"${stepn[$step]}
    echo "next     step:"${stepn[$(($step+1))]}
    echo -e "\x1B[33m""___________^______________""\x1B[0m"
    echo ""
    echo ""
    echo ""
    dialog_my
    done

echo -e "\x1B[36m""********************END****************************""\x1B[0m"        
