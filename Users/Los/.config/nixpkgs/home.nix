{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "$USER";
  home.homeDirectory = "/home/$USER";
  home.sessionPath = [ "/home/$USER/mnt/OutHouse/los/bin" ];
  home.sessionVariables = {
    EDITOR = "vim";
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
   home.stateVersion = "21.11";
  # To install, Run:
  # nix-channel --add https://github.com/nix-community/home-manager/archive/release-21.11.tar.gz home-manager
  # niz-channel --update

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Git
  programs.git = let
    Git = (import ./home_loco.nix).Git;
  in {
    enable = true;
    userName = Git.userName;
    userEmail = Git.userEmail;
  };

  home.packages = with pkgs; [
    direnv
    #gparted
    #extundelete # undelete file
    #testdisk # undelete file
    appimage-run # run AppImage files
    maim # Screenshots
    pavucontrol
    pamixer # pulse audio mixer
    picom # needed for transparent bg
    thunderbird
    xfce.thunar
    gnome.nautilus
    geany
    screenfetch
    neofetch
    tmux
    fzf
    zoom-us
    skype
    unzip
    #Web Dev
    google-chrome
    jetbrains.phpstorm
    jetbrains.datagrip
    #docker
    php 
    php80Packages.composer
    postman
    filezilla
    vscode
  ];
}
