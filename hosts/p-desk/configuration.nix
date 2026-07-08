{config, lib, pkgs, ...}:{
	imports = [
		./hardware-configuration.nix
	];

	networking.hostName = "p-desk";
	system.stateVersion="26.05";
}
