# Steganos BMP Toolkit

The Steganos BMP Toolkit is an assembly x86 program that allows you to cipher messages and hide them inside a BMP image file, and to recover and decrypt hidden messages from BMP image files. This toolkit provides two main tools, "steganos-bmp-cover" for hiding messages, and "steganos-bmp-recover" for revealing hidden messages.

## Table of Contents
- [Getting Started](#getting-started)
- [Building](#building)
- [Usage](#usage)
- [Feedback](#feedback)
- [License](#license)

## Getting Started

To get started with the Steganos BMP Toolkit, you will need an x86 compatible environment. Ensure you have the necessary tools to assemble and run the provided code. This toolkit has been designed for use on Linux systems.

## Building

You can build the Steganos BMP Toolkit using either the provided shell script `build.sh` or the `Makefile`. Below are instructions for both methods:

### Shell script

1. Make sure the `build.sh` script has execute permissions. If not, you can grant them using the chmod command:
```bash
chmod +x build.sh
```
2. Run the `build.sh` script to compile the project:
```bash
./build.sh
```

The script will compile the project, and it includes some helpful coloring for output. Additionally, it provides suggestions on how to run the compiled programs, such as using gdb for debugging.

### Makefile

1. Use the `make` command to compile the project:
```bash
make
```
This will compile the project using the instructions specified in the Makefile. The compiled executables, "steganos-bmp-cover" and "steganos-bmp-recover," will be created in the project directory and will be ready for use.

## Usage

### Steganos BMP Cover

The "steganos-bmp-cover" tool allows you to hide a message inside a BMP image file. To use it, follow this command format:

```shell
./steganos-bmp-cover <message_file> <rotation_factor> <input_image> <output_image>
```

Where:
- <message_file>: The path to the text file containing the message you want to hide.
- <rotation_factor>: The number of rotations to apply to each char of the message before hiding it in the image.
- <input_image>: The name of the source BMP image file.
- <output_image>: The name of the output BMP image file that will contain the hidden message.

### Steganos BMP Recover

The "steganos-bmp-recover" tool allows you to recover and decrypt a hidden message from a BMP image file. To use it, follow this command format:

```bash
./steganos-bmp-recover <rotation_factor> <input_image>
```

Where:
- <rotation_factor>: The number of rotations that were applied to each character when hiding the message.
- <input_image>: The BMP image file from which you want to recover the hidden message.

## Feedback

If you have any feedback, please reach out to me at guilemosmarcello@gmail.com

## License

MIT