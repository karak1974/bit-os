#!/bin/bash
rm $(find . | grep BitOS | grep img)
rm bzImage
rm -rf src initrd 
