{ config, lib, pkgs, ... }:{
	# Automatic updating
	system.autoUpgrade = {
		enable = true;
		dates = "weekly";
		flake = "/home/p/.ndots";
	};

	# Automatically cleanup old builds
	nix.gc.automatic = true;
	nix.gc.dates = "daily";
	nix.gc.options = "--delete-older-than 7d";
	nix.settings.auto-optimise-store = true;

	# Use the systemd-boot EFI boot loader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;
	nixpkgs.config.allowUnfree = true;
	# networking.hostName = "pnix"; # Define your hostname.


	networking.networkmanager.enable = true;

	time.timeZone = "America/Los_Angeles";
	services.openssh.enable = true;
	services.flatpak.enable = true;
	services.mullvad-vpn.enable = true;
	services.resolved.enable = true;	
	systemd.services.mullvad-daemon = {
	postStart = let
		mullvadBin = "${config.services.mullvad-vpn.package}/bin/mullvad";
		in ''
		while ! ${mullvadBin} status >/dev/null 2>&1; do
			sleep 0.5
		done
		
		${mullvadBin} relay set location us lax || true
		${mullvadBin} set default --block-ads --block-trackers --block-malware || true
		${mullvadBin} relay set multihop off || true
		${mullvadBin} tunnel set daita off || true
		${mullvadBin} lan set allow || true
		'';
	};

	services.pipewire = {
		enable = true;
		pulse.enable = true;
	};
	
	users.users.p = {
		isNormalUser = true;
		extraGroups = [ "wheel" ];  # Enable ‘sudo’ for the user.
		packages = with pkgs; [
			tree
			];
	};

	programs.firefox.enable = true;
	programs.steam.enable = true;
	environment.systemPackages = with pkgs; [
 	 # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
		wget
		zip
		unzip
		git 
		neovim
	  ];

	programs.git ={
		enable = true;
		config ={
			safe ={
			directory = "${config.users.users.p.home}/.ndots";
			};
		};
	};
	
	programs.sway={
		enable=true;
		wrapperFeatures.gtk=true;
	};	

	fonts.packages=with pkgs;[
		nerd-fonts.jetbrains-mono
	];

	nix.settings.experimental-features=["nix-command" "flakes"];

	system.stateVersion = "26.05"; # Did you read the comment? # maybe...

}
