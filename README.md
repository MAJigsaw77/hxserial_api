# hxserial_api

![](https://img.shields.io/github/repo-size/MAJigsaw77/hxserial_api) ![](https://badgen.net/github/open-issues/MAJigsaw77/hxserial_api) ![](https://badgen.net/badge/license/MIT/green)

Haxe/hxcpp @:native integration for managing serial connections and devices.

### Supported Platforms

- **Windows**
- **MacOS**
- **Linux** (*untested*)

### Installation

You can install it through `Haxelib`
```bash
haxelib install hxserial_api
```
Or through `Git`, if you want the latest updates
```bash
haxelib git hxserial_api https://github.com/MAJigsaw77/hxserial_api.git
```

### Dependencies

On ***Linux*** you need to install `libudev-dev` from your distro's package manager.

<details>
<summary>Commands list</summary>

#### Debian based distributions ([Debian](https://debian.org)):
```bash
sudo apt-get install libudev-dev
```

#### Arch based distributions ([Arch](https://archlinux.org)):
```bash
sudo pacman -S libudev
```

#### Fedora based distributions ([Fedora](https://getfedora.org)):
```bash
sudo dnf install systemd-devel
```

#### Red Hat Enterprise Linux (RHEL):
```
sudo dnf install systemd-devel
```

#### openSUSE based distributions ([openSUSE](https://www.opensuse.org)):
```bash
sudo zypper install libudev-devel
```

#### Gentoo based distributions ([Gentoo](https://gentoo.org)):
```bash
sudo emerge sys-fs/udev
```

#### Slackware based distributions ([Slackware](https://www.slackware.com)):
```bash
sudo slackpkg install eudev
```

#### Void Linux ([Void Linux](https://voidlinux.org)):
```bash
sudo xbps-install -S eudev
```

#### NixOS ([NixOS](https://nixos.org)):
```bash
nix-env -iA nixpkgs.udev
```

</details>

### Usage Example

Check out the [Samples Folder](samples/) for sample on how to use this library.

### Licensing

**hxserial_api** is made available under the **MIT License**. Check [LICENSE](./LICENSE) for more information.
