{
  description = "A very basic flake";
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR"; 
    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nur }: 
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {
        nix-desktop = lib.nixosSystem {
          inherit system;
          modules = [ 
            ./configuration.nix
            { nixpkgs.overlays = [ nur.overlay ]; }
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.shaun = {
                imports = [ ./home.nix ];
              };
            }
          ];
        };
      };

      hmConfig = {
        shaun = home-manager.lib.homeManagerConfiguration {
          inherit system pkgs;
          username = "shaun";
          homeDirectory = "/home/shaun";
          stateVersion = "22.05";
          configuration = {
            imports = [
              ./home.nix
            ];
          };
        };
      };
    }; 
}
