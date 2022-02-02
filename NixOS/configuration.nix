# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  Loco = (import ./configuration_loco.nix) { config=config; };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Mounts
  fileSystems."/" = {
    device = "/dev/disk/by-label/Try";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };
  fileSystems."/home" = {
    device = "/dev/disk/by-label/Home";
    fsType = "ext4";
  };
  fileSystems."/var/www" = {
    device = "/home/${Loco.User.Name}/Documents/htdocs";
    options = [ "bind" ];
  };
  fileSystems."OutHouse" = {
    mountPoint = "/home/${Loco.User.Name}/mnt/OutHouse";
    device = "/dev/disk/by-label/BigHome";
    fsType = "ext4";
    options = [ "nofail" "auto" ];
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.extraModulePackages = with config.boot.kernelPackages; [
    rtl8814au
  ];

  networking.hostName = Loco.HostName; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.wireless.userControlled.enable = true;
  networking.wireless.networks = let
    WiFi = Loco.WiFi;
  in {
    Los = {
      pskRaw=WiFi.Los;
    };
    "Los Dose" = {
      pskRaw=WiFi.LosDose;
    };
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  # networking.useDHCP = true;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.enp0s20f0u5.useDHCP = true;
  networking.interfaces.wlp0s20f0u4.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    displayManager = {
      setupCommands = ''
        LFT='DP-1'
        CNTR='HDMI-3'
        RGHT='HDMI-1'
        ${pkgs.xorg.xrandr}/bin/xrandr --output $CNTR --output $LFT --left-of $CNTR --output $RGHT --right-of $CNTR
      '';
      lightdm = {
        enable = true;
        background = /boot/media/images/MatrixReality.jpg;
      };
      session = [
        {
          manage = "window";
          name = "i3";
          start = ''
            ${pkgs.i3}/bin/i3 &
            waitPID=$!
            sleep 1
            aplay /boot/media/sounds/GLaDOS_02_part1_entry-1.wav
          '';
        }
      ];
      sessionCommands = ''
        aplay /boot/media/sounds/GLaDOS_00_part1_entry-7.wav
      '';
    };
    windowManager = {
      i3 = {
        enable = true;
        extraPackages = with pkgs; [
          i3status
          i3lock
        ];
      };
    };
  };


  

  # Configure keymap in X11
  services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;
  
  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${Loco.User.Name}" = {
    initialPassword = "Foo";
    isNormalUser = true;
    group = Loco.User.Group;
    createHome = true;
    extraGroups = [ "wheel" "users" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    linuxKernel.packages.linux_libre.rtl8814au
    gparted
    pciutils
    usbutils
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    alacritty
    zsh
    oh-my-zsh
    ranger
    brave
    firefox
    dmenu
    feh
  ];

  # The Server
  services.nginx = {
    enable = true;
    user = Loco.User.Name;
    group = Loco.User.Group;
    virtualHosts = Loco.VHosts;
  };
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };
  services.phpfpm.pools.mypool = let
    php =  pkgs.php.buildEnv {
      extensions = ({enabled, all}: with all; [
        curl imagick mysqli mysqlnd openssl pdo pdo_mysql session
      ]);
      extraConfig = "memory_limit=2G";
    };
  in {
    phpPackage = php;
    user = Loco.User.Name;
    group = Loco.User.Group;
    settings = {
      pm = "dynamic";
      "listen.owner" = Loco.User.Name;
      #"listen.owner" = config.services.nginx.user;
      "pm.max_children" = 5;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 1;
      "pm.max_spare_servers" = 3;
      "pm.max_requests" = 500;
    };
  };
  services.phpfpm.pools.my74pool = let
    php =  pkgs.php74.buildEnv {
      extensions = ({enabled, all}: with all; [
        curl imagick json openssl pdo pdo_mysql mysqli mysqlnd session tokenizer
      ]);
      extraConfig = "memory_limit=2G";
    };
  in {
    phpPackage = php;
    user = Loco.User.Name;
    group = Loco.User.Group;
    settings = {
      pm = "dynamic";
      "listen.owner" = Loco.User.Name;
      "pm.max_children" = 5;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 1;
      "pm.max_spare_servers" = 3;
      "pm.max_requests" = 500;
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.hosts = Loco.Hosts;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable OpenVPN
  # Download the configs: wget https://downloads.nordcdn.com/configs/archives/servers/ovpn.zip
  # networking.enableIPv6 = false; # This may be needed ad NordVPN doesn't support IPv6
  services.openvpn.servers = let
    LoginCreds = Loco.Nord;
  in {
    Nord = {
      config = '' config /root/.config/nixos/OpenVPN/Nord/ovpn_udp/us8525.nordvpn.com.udp.ovpn '';
      autoStart = false;
      authUserPass = LoginCreds;
    };
    Chile = {
      config = '' config /root/.config/nixos/OpenVPN/Nord/ovpn_udp/cl32.nordvpn.com.udp.ovpn '';
      autoStart = false;
      authUserPass = LoginCreds;
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

