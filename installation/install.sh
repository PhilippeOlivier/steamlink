#!/usr/bin/env -S bash -e

set -e

DEVICE="/dev/sda"
BOOT_LABEL="BOOT"
ROOT_LABEL="ROOT"
BOOT_PARTITION="/dev/disk/by-partlabel/${BOOT_LABEL}"
ROOT_PARTITION="/dev/disk/by-partlabel/${ROOT_LABEL}"
POOL="tank"

# Delete the filesystem
sudo wipefs -af $DEVICE

# Delete the partition table
sudo sgdisk -Zo $DEVICE

# Partition the device
sudo parted -s -a optimal $DEVICE \
     mklabel gpt \
     mkpart $BOOT_LABEL fat32 0% 1GiB \
     set 1 esp on \
     mkpart $ROOT_LABEL 1GiB 100%

# Inform the kernel of changes
sudo partprobe $DEVICE

# Boot partition
sudo mkfs.vfat -i 20240215 $BOOT_PARTITION

# ZFS pool
sudo zpool create \
     -O acltype=posixacl \
     -o ashift=12 \
     -o autotrim=on \
     -O compression=lz4 \
     -O mountpoint=none \
     -O xattr=sa \
     $POOL $ROOT_PARTITION

# ZFS datasets
sudo zfs create -o mountpoint=legacy -o com.sun:auto-snapshot=false ${POOL}/root
sudo zfs create -o mountpoint=legacy -o com.sun:auto-snapshot=false ${POOL}/nix
sudo zfs create -o mountpoint=legacy -o com.sun:auto-snapshot=false ${POOL}/var
sudo zfs create -o mountpoint=legacy -o com.sun:auto-snapshot=true ${POOL}/home

# Mount
sudo mount -t zfs ${POOL}/root /mnt

sudo mkdir -p /mnt/boot
sudo mount $BOOT_PARTITION /mnt/boot

sudo mkdir -p /mnt/nix
sudo mount -t zfs ${POOL}/nix /mnt/nix

sudo mkdir -p /mnt/var
sudo mount -t zfs ${POOL}/var /mnt/var

sudo mkdir -p /mnt/home
sudo mount -t zfs ${POOL}/home /mnt/home
# sudo chown -R homelab:users /mnt/home/homelab

# Generate basic configuration, including `hardware-configuration.nix`
sudo nixos-generate-config --root /mnt

# Add `networking.hostId` for ZFS (note: change this value for other machines)
sudo sed -i '/.*boot.extraModulePackages.*/a networking.hostId = "00001111";' /mnt/etc/nixos/hardware-configuration.nix

# Replace the default `configuration.nix` with my shim
cat > configuration.nix <<EOF
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Boot
  boot.loader = {
    systemd-boot = {
      enable = true;
    };
    efi.canTouchEfiVariables = true;
  };

  # Networking
  networking = {
    hostName = "steamlink";
    useDHCP = false;
    interfaces = {
      eno1 = {
        useDHCP = true;
        ipv4.addresses = [
          {
            address = "192.168.100.83";
            prefixLength = 24;
          }
        ];
      };
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = true;
    };
  };

  # Users
  users.mutableUsers = false;

  users.users.root = {
    isSystemUser = true;
    password = "asdf";
  };
  
  users.users.steamlink = {
    isNormalUser = true;
    password = "asdf";
    description = "steamlink";
    home = "/home/steamlink";
    extraGroups = [
      "wheel"
    ];
  };

  # ZFS
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  # Misc
  system.stateVersion = "24.05";
  environment.systemPackages = [
    pkgs.git
  ];
}
EOF

sudo mv configuration.nix /mnt/etc/nixos/configuration.nix

# Install NixOS
sudo nixos-install --root /mnt --no-root-password

echo "Complete. Reboot and follow the last README instructions."
