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
		nixosConfigurations."p-desk" = nixpkgs.lib.nixosSystem{
			system="x86_64-linux";
			modules=[
				./common.nix
				./hosts/p-desk/configuration.nix
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

		nixosConfigurations."p-top" = nixpkgs.lib.nixosSystem{
			system="x86_64-linux";
			modules=[
				./common.nix
				./hosts/p-top/configuration.nix

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
