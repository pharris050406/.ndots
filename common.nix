{ config, lib, pkgs, ... }:{

	# Automatic updating
	system.autoUpgrade = {
		enable = true;
		dates = "daily";
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
	
	environment.systemPackages = with pkgs; [
 	 # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
		wget
		zip
		unzip
		git 
		yazi
		wl-clipboard
		ripgrep
		tree-sitter
		gcc
		gnumake
	  ];
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

	xdg.portal={
	    enable = true;
	    extraPortals = [
		pkgs.xdg-desktop-portal-wlr
		pkgs.xdg-desktop-portal-gtk
	    ];
	    config = {
		common = {
		  "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
		  default = [ "wlr" "gtk" ];
		};
	    };
	};

	programs.firefox.enable = true;
	programs.dconf.enable = true;	

	programs.nix-ld.enable = true;
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
		package = pkgs.swayfx;
	};

	fonts.packages=with pkgs;[
		nerd-fonts.jetbrains-mono
	];

	users.users.p = {
		isNormalUser = true;
		extraGroups = [ "wheel" ];  # Enable ‘sudo’ for the user.
		packages = with pkgs; [
			tree
			];
	};
	nix.settings.experimental-features=["nix-command" "flakes"];

	system.stateVersion = "26.05"; # Did you read the comment? # maybe...

}
