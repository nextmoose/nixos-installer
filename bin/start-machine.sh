#!/bin/sh

sudo VBoxManage storageattach nixos --storagectl "SATA Controller" --port 0 --device 0 --type dvddrive --medium build/installation/result/iso/nixos-18.03.133245.d16a7abceb7-x86_64-linux.iso &&
    sudo VBoxManage startvm nixos
