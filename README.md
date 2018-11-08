# nixos-installer

## About

This project creates an image that can be used to install nixos on my laptop.
The project is solely focused on my need.
It may or may not work on your laptop.
If it does not work on your laptop, it would probably be a useful starting point.

## Creating an install image

The run script

1. Requests the user input and verify:
   1. a 'SYMMETRIC PASSPHRASE'
   2. a 'LUKS PASSPHRASE'
   3. a 'USER PASSWORD'
2. Uses the 'SYMMETRIC PASSPHRASE' to create an encrypted tarball of user secrets.  If your computer does not have an installed program 'secrets' that outputs secrets then the script will fail at this point.
   1. The encrypted tarball is extremely sensitive because it contains the gpg secret keys.  The script does not contain these secrets.  It transfers them from one place on my laptop to the encrypted tarball.
   2. It contains the 'LUKS PASSPHRASE' and 'USER PASSWORD'.
   3. It also contains a wifi script with SSID and password.  These values are kludgily hard coded into the project code which is sub-optimal.  (Among other things, this will probably fail for you.)
3. It creates an installation directory.
   1. Most of the installation directory is copied directly from this project.
      1. /iso.nix - defines the iso image to be created.  Notice it kludgily connects to wifi using hard coded credential.  (This project is made for my convenience not yours.)
      2. /installer - the directory that contains the 'installer' nix expression
      3. /installer/default.nix - the 'installer' nix expression
      4. /installer/src/installer.sh - the 'installer' script
      5. /installer/src/installed - this is a little bit disorganized, but it contains things that should be put onto the installed computer
   2. The only part that is not is the previously mentioned encrypted tarball.
      1. /installation/installer/src/secrets.tar.gz.gpg
4. It creates an installation iso image based on the directory.

## Using the install image
1. Copy the install image onto a usb disk or burn it onto a cd/dvd.
2. Put the usb disk or cd/dvd into your computer.
3. Turn it on / reboot it / whatever.
4. Your computer will boot into the nixos operating system
   1. It will be connected to wifi (if your wifi has the same SSID and password as mine.)
   2. It will have the previously mentioned 'installer' script.

## Using the 'installer' script.
1. Enter `installer --upstream-url ${UPSTREAM_URL} --upstream-branch ${UPSTREAM_BRANCH` where
   1. ${UPSTREAM_URL} is the url to a git repository containing nixos configuration.  I use 'https://github.com/nextmoose/nixos-configuration.git'.
   2. ${UPSTREAM_BRANCH} is a branch on the previously mentioned repository containing the nixos configuration you want to install.  I use 'level-3'.
2. The 'installer script' will prompt you for the previously mentioned 'SYMMETRIC PASSPHRASE'.  It will use this to decrypt the previously mentioned encrypted tarball.  At this point, the 'installer script' has your secrets.
3. The install script wipes your hard disk clean.  (You have been warned.)
4. The install script creates a new layout.
   1. /dev/sda1 - 200M - BOOT - This will be used to boot your laptop.
   2. /dev/sda2 - 8G - SWAP - This will be used for swap memory.
   3. /dev/sda3 - 64G - ROOT - This will be encrypted using the previously mentioned 'LUKS PASSPHRASE'.
   4. /dev/sda4 - REST OF DISK - VOLUMES - This will be an unencrypted LVM Volume Group
5. It will create a /mnt/etc/nixos file structure.
   1. /mnt/etc/nixos/installed/password.nix - a hash of the previously mentioned 'USER PASSWORD'.
   2. /mnt/etc/nixos/installed - some nixos expressions that will be available on your new system.  These will contain your unencrypted secrets (from the encrypted tarball)
   3. it will copy configuration.nix and custom from the previously mentioned ${UPSTREAM URL}, ${UPSTREAM_BRANCH} git repository into /mnt/etc/nixos/configuration.nix and /mnt/etc/nixos/custom.
6. It will run `nixos-generate` - which will complete the /mnt/etc/nixos file structure.
7. It will run `nixos-install` - which will install nixos onto your laptop.
8. Power off your computer and remove the install media.
9. Turn on your computer.  It should prompt you for the 'LUKS PASSPHRASE' which is necessary to open the previously mentioned ROOT partition.  Your previously mentioned secrets are stored in plain text on the ROOT partition.  The LUKS encryption is the only protection for your secrets.
10. Your system is now ready for use.

## About the UPSTREAM git repository
1. Your upstream git repository should have
   1. /configuration.nix
   2. /custom
2. You should assume that an /installed directory will be provided.  You should assume that the /installed directory will have some useful secrets:
   1. HASHED USER PASSWORD.  You can set the user password in the configuration.nix file without publicly announcing it by referencing a file in the /installed directory.
   2. GPG SECRET KEYS.
   3. wifi credential ... this is obviously a kludge that assumes your laptop's location ... it works for me, but probably not for you.
3. You should put your nix expressions in the /custom directory.  By putting your nix expressions in the /custom directory, we can avoid collisions with either expressions that the installer creates (in the /installed directory) or that nixos-generate creates (/hardware.nix).
