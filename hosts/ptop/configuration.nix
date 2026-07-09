{config, lib, pkgs, ...}:{
	imports = [
		./hardware-configuration.nix
	];

	networking.hostName = "ptop";
	system.stateVersion="26.05";
	
	environment.systemPackages = with pkgs;[
		# desktop-specific system packages go here	
	];
}
