{config, lib, pkgs, ...}:{
	imports = [
		./hardware-configuration.nix
	];

	networking.hostName = "pdesk";
	system.stateVersion="26.05";

		# 1. Allow unfree packages if you haven't globally enabled it for your system rebuilds
	nixpkgs.config.allowUnfree = true;

	# 2. Tell the system to load the NVIDIA driver
	services.xserver.videoDrivers = [ "nvidia" ];

	hardware.graphics = {
	  enable = true;
	  enable32Bit = true; # Critical for games
	};

	hardware.nvidia = {
	  modesetting.enable = true;
	  
	  # Use the open-source kernel module (Recommended for RTX 20-series and newer)
	  open = true;
	  
	  nvidiaSettings = true;
	  package = config.boot.kernelPackages.nvidiaPackages.stable;
	};
	
	environment.systemPackages = with pkgs;[
		# desktop-specific system packages go here	
		
		# proprietary bloat below
		discord-canary
	];
	environment.sessionVariables = {
	  __NV_DISABLE_EXPLICIT_SYNC = "1";
	};
	programs.steam={
	    enable = true;
	    remotePlay.openFirewall = true;
	    dedicatedServer.openFirewall = true;
	};


}
