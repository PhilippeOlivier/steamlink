# NixOS installation

With `lsblk` validate that the value of `DEVICE` in `installation/install.sh` is the correct one. Also, with `ifconfig` make sure that the network interface is correct in `installation/install.sh`.

Fetch the Bash script to partition and format the disk:

```bash
$ curl -sLo install.sh raw.githubusercontent.com/PhilippeOlivier/homelab/main/installation/install.sh
```

Launch the script. When the script finishes, reboot.

```bash
$ bash install.sh
```

Login locally or using SSH (192.168.0.82).

Clone my personal configuration (normally, replace `hardware-configuration.nix` in it with the new one) and get rid of `/etc/nixos`:

```bash
$ git clone https://github.com/PhilippeOlivier/nixos.git
$ mv nixos nixos2
$ mv nixos2/steamlink nixos
$ sudo rm -rf /etc/nixos
```

Copy the backup `.nixos-extra` directory to `~/.nixos-extra`.

Rebuild:

```bash
$ sudo nixos-rebuild switch --flake /home/steamlink/nixos
```
