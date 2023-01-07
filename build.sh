#!/bin/bash

set -eu pipefail

green=`echo "\033[92;1m"`
cyan=`echo "\033[96;1m"`
yellow=`echo "\033[93;1m"`
blue_menu=`echo "\033[36m"`
normal=`echo "\033[m"`
menu=`echo "\033[36m"`
number=`echo "\033[33m"` 

printf "${yellow}[*][IOUtil, ArgsUtil and NumericUtil] Compiling libs....${blue_menu}\n"
nasm -f elf64 -F dwarf util/IOUtil.asm
nasm -f elf64 -F dwarf util/ArgsUtil.asm
nasm -f elf64 -F dwarf util/NumericUtil.asm
printf "${green}[+] Done.\n"

printf "${yellow}[*][steganos-bmp-cover] Compiling and linking....${blue_menu}\n"
nasm -f elf64 -F dwarf steganos-bmp-cover.asm
ld steganos-bmp-cover.o util/IOUtil.o util/ArgsUtil.o util/NumericUtil.o -o steganos-bmp-cover
printf "${green}[+] Done.\n"

printf "${yellow}[*][steganos-bmp-recover] Compiling and linking....${blue_menu}\n"
nasm -f elf64 -F dwarf steganos-bmp-recover.asm
ld steganos-bmp-recover.o util/IOUtil.o util/ArgsUtil.o util/NumericUtil.o -o steganos-bmp-recover
printf "${green}[+] Done.\n"

printf "${cyan}[i] Useful debug commands: \n" 
printf "${number}[1] ${menu}./steganos-bmp-cover samples/message 3 samples/snail.bmp samples/snail_with_message.bmp\n"
printf "${number}[2] ${menu}gdb -tui -ex='b _start' --args steganos-bmp-recover 3 samples/snail_with_message.bmp\n"
printf "${number}[3] ${menu}./steganos-bmp-recover 3 samples/snail_with_message.bmp${normal}\n"