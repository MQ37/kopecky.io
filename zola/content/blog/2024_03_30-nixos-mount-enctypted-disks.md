+++
title = "NixOS - RPI mounting encrypted disks"
date = 2024-03-30
+++

Since I have moved my RPI from my old office I never actually found time to create a new setup. Previously I had my RPI in my room, but the HDDs are too noisy and it was disturbing my sleep so my RPI was just sitting on my desk unused until this weekend. I finally decided and made some time make my new RPI setup based on NixOS and move the RPI to the other room and connect wirelessly (this kinda sucks, but better than drilling holes all over the house).

Installation was quite straight forward, just downloaded official RPI 4 SD prebuild image from Hydra, flash that to the SSD and boot, nice. Then create the NixOS host config for the RPI, where I encontered few issues but resolved them by switching to unstable channel. Wireless connection on the RPI which is in metal Argon case (which I think makes it even worse) sucks, so I configured wireless config as a backup and using Wi-Fi extender over ethernet instead of RPI wireless adapter. Then I have few enctypted drives that need to be mounted when booting, this was by far the most painful thing to get working. I tried multiple approaches, using initrd, tinkered with settings, trying different paths but to no avail. Then managed to find few usedful articles that guided me in the right direction (linked at the bottom), one approach, that I am currently using, is via crypttab and the other one that seems quite interesting is using external SD card containing the keys to unlock (maybe will try that in future).

First thing is to create your decryption key store on unencrypted root FS, I created a directory `/keystore/` for that. Then create a key:
```bash
dd bs=512 count=4 if=/dev/random of=/keystore/drive.key iflag=fullblock
```

Now add the key to the LUKS encrypted drive:
```bash
cryptsetup luksAddKey /dev/sdX /keystore/drive.key
```

Get the drive UUID:
```bash
blkid
```

Then update the NixOS config to unlock and mount the drive:
```
  environment.etc."crypttab".text = ''
    data /dev/disk/by-uuid/DRIVE-UUID-HERE /keystore/drive.key
  '';

  fileSystems."/" =
    { 
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  fileSystems."/disks/data" =
    {
      depends = [ "/" ];
      device = "/dev/mapper/data";
    };
```

Note the `depends` in the `fileSystems` section, this is important, without that mount fails (or maybe even boot, not sure). My whole NixOS config is available [here](https://github.com/MQ37/nixos).


Sources:
- [https://discourse.nixos.org/t/how-to-unlock-some-luks-devices-with-a-keyfile-on-a-first-luks-device/18949/12](https://discourse.nixos.org/t/how-to-unlock-some-luks-devices-with-a-keyfile-on-a-first-luks-device/18949/12)
- [https://vincent.demeester.fr/nixos/luks-key-sdcard.html](https://vincent.demeester.fr/nixos/luks-key-sdcard.html)
- [https://nix.dev/tutorials/nixos/installing-nixos-on-a-raspberry-pi.html](https://nix.dev/tutorials/nixos/installing-nixos-on-a-raspberry-pi.html)

