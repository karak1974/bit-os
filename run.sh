#!/bin/bash
qemu-system-x86_64 -kernel bzImage -initrd $(find . | grep BitOS | grep img) -nographic -append 'console=ttyS0'

