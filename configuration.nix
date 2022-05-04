{ config, pkgs, ... }:

let
  user="shaun";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot = { 
    kernelPackages = pkgs.linuxPackages_latest;
    
    initrd.kernelModules = ["amdgpu"];
    
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
      timeout = 1;
    };
  };
  
  networking.hostName = "nix-desktop";
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  services ={ 
    xserver = {
      enable = true;
      videoDrivers = [ "amdgpu" ];
      layout = "gb";
      xkbVariant = "mac";
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
    
    fstrim.enable = true;
    dbus.packages = [ pkgs.dconf ];
    udev = { 
      packages = with pkgs; [
        gnome3.gnome-settings-daemon
        usb-modeswitch-data
      ];
    };
    gnome.chrome-gnome-shell.enable = true;
  };

  virtualisation.libvirtd.enable = true;

  hardware.opengl = {
    driSupport = true;
    driSupport32Bit = true;
  };

  hardware.steam-hardware.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" "input" ];
    initialPassword = "password";
  };
  
  programs = {
    steam.enable = true;
    gamemode.enable = true;
    dconf.enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
    nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    git
    vim 
    wget
    google-chrome
    gnomeExtensions.blur-my-shell
    #gnomeExtensions.appindicator
    mangohud
    vlc
    gimp-with-plugins
    virt-manager
    usb-modeswitch
    nur.repos.c0deaddict.oversteer
  ];

  # services.openssh.enable = true;

  system.stateVersion = "22.05"; # Did you read the comment?

  nix = {
    autoOptimiseStore = true;
    package = pkgs.nixFlakes;
    extraOptions = '' 
      experimental-features = nix-command flakes
      warn-dirty = false
    '';
  };

}

