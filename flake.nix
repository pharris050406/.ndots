{
	description="NixOS";
	inputs={
		nixpkgs.url="nixpkgs/nixos-unstable";
		home-manager={
			url="github:nix-community/home-manager/master";
			inputs.nixpkgs.follows="nixpkgs";
		};
	};
	outputs={self, nixpkgs, home-manager, ...}:{
		nixosConfigurations."pdesk" = nixpkgs.lib.nixosSystem{
			system="x86_64-linux";
			modules=[
				./common.nix
				./hosts/pdesk/configuration.nix
				home-manager.nixosModules.home-manager{
					home-manager={
						useGlobalPkgs=true;
						useUserPackages=true;
						users.p = import ./home.nix;
						backupFileExtension="backup";
					};
				}
			];
		};

		nixosConfigurations."ptop" = nixpkgs.lib.nixosSystem{
			system="x86_64-linux";
			modules=[
				./common.nix
				./hosts/ptop/configuration.nix

				home-manager.nixosModules.home-manager{
					home-manager={
						useGlobalPkgs=true;
						useUserPackages=true;
						users.p = import ./home.nix;
						backupFileExtension="backup";
					};
				}
			];
		};
	};
}
