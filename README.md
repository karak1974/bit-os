# Bit OS  
A BusyBox based minimal operation system  

## Dependencies  
It has 2 dependencies what you need to install before anything.  

On Arch Linux:  
`sudo pacman -S musl kernel-headers-musl`  

On Debian:  
`sudo apt install musl kernel-headers-musl`  

## Installation
The `./setup.sh` is an automated script.  
The processes what it does:
- Download the Linux Kernel
- Download the BusyBox
- Compile the Kernel
- Compiel the BusyBox
- Create the filesystem.  

## Using
With the `./run.sh` you can run the created iso with [Qemu](https://www.qemu.org/).  
