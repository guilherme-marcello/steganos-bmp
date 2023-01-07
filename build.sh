#!/bin/bash

set -eu pipefail

green=`echo "\033[92;1m"`
cyan=`echo "\033[96;1m"`
yellow=`echo "\033[93;1m"`
blue_menu=`echo "\033[36m"`
normal=`echo "\033[m"`
menu=`echo "\033[36m"`
number=`echo "\033[33m"` 

printf "${yellow}[*][steganos-bmp-cover] Compiling and linking....${blue_menu}\n"
nasm -f elf64 -F dwarf steganos-bmp-cover.asm
nasm -f elf64 -F dwarf util/IOUtil.asm
nasm -f elf64 -F dwarf util/ArgsUtil.asm
nasm -f elf64 -F dwarf util/NumericUtil.asm
ld steganos-bmp-cover.o util/IOUtil.o util/ArgsUtil.o util/NumericUtil.o -o steganos-bmp-cover
printf "${green}[+] Done.\n"

printf "${cyan}[i] Useful debug commands: \n" 
printf "${number}[1] ${menu}./steganos-bmp-cover samples/message 3 samples/snail.bmp samples/snail_with_message.bmp\n"
