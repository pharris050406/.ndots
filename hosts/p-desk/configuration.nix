{config, lib, pkgs, ...}:{
	imports = [
		./hardware-configuration.nix
	];

	networking.hostName = "p-desk";
	system.stateVersion="26.05";
	
	environment.systemPackages = with pkgs;[
		# desktop-specific system packages go here	
	];
	programs.steam.enable=true;
}
