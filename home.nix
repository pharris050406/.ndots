{config, pkgs, lib, ...}:{

	home.username="p";
	home.homeDirectory="/home/p";
	programs.git.enable=true;
	home.stateVersion="26.05";

	home.packages=with pkgs;[
		neovim
		mpc
		playerctl
		libnotify
		grim
		slurp
		rmpc
		android-tools
		qbittorrent
		ffmpeg
		autotiling
		waybar
		quickshell		
		alsa-utils
		
		yt-dlp
		# proprietary garbage
	];

	programs.bash={
		enable=true;
		shellAliases = {
			vi = "nvim";
			vim = "nvim";
			yz = "yazi";
			nrs = "sudo nixos-rebuild switch --flake ~/.ndots";
			src = "source ~/.ndots/config/bash/.bash_aliases";
		};
		initExtra = ''
		    if [ -f ~/.ndots/config/bash/.bash_aliases ]; then
			source ~/.ndots/config/bash/.bash_aliases
		    fi
		'';

		profileExtra=''
		   if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
			exec sway --unsupported-gpu
		   fi
		'';
	};

	programs.foot={
	    enable = true;
	    settings = {
		    main = {

			font = "JetBrainsMono Nerd Font:size=11";
			};

			colors-dark = {
	    		alpha = 0.15;

			background = "1a1b26"; 
			foreground = "c0caf5";
			};
		};
	};

	programs.mpv = {
	    enable = true;
	    scripts = [
	      pkgs.mpvScripts.mpris
	    ];
	  };
	dconf.settings = {
	    "org/gnome/desktop/interface" = {
		color-scheme = "prefer-dark";
	    };
	};

        gtk = {
	    enable = true;
	    theme = {
		name = "Adwaita-dark";
		package = pkgs.gnome-themes-extra;
	    };
	    gtk3.extraConfig = {
		gtk-application-prefer-dark-theme = 1;
	    };
	    gtk4.extraConfig = {
		gtk-application-prefer-dark-theme = 1;
	    };
	};

	programs.btop={
		enable=true;
		settings={
		    theme_background = false;
	    };
	};

	xdg.configFile."bash" = {
		source = config.lib.file.mkOutOfStoreSymlink "/home/p/.ndots/config/bash";
		recursive = true;
	};


	xdg.configFile."nvim" = {
		source = config.lib.file.mkOutOfStoreSymlink "/home/p/.ndots/config/nvim";
		recursive = true;
	};

	xdg.configFile."sway"={
	    source = config.lib.file.mkOutOfStoreSymlink "/home/p/.ndots/config/sway";
	    recursive=true;
	};

	xdg.configFile."quickshell"={
	    source = config.lib.file.mkOutOfStoreSymlink "/home/p/.ndots/config/quickshell";
	    recursive = true;
	};

	xdg.configFile."waybar"={
	    source = config.lib.file.mkOutOfStoreSymlink "/home/p/.ndots/config/waybar";
	    recursive = true;
	};
	
	xdg.configFile."rmpc"={
	    source = config.lib.file.mkOutOfStoreSymlink "/home/p/.ndots/config/rmpc";
	    recursive = true;
	};


	services.mako={
	    enable = true;  
	};

	services.mpd-mpris={
	    enable = true;
	};

	services.playerctld.enable = true;

	services.mpd={
		enable=true;
		musicDirectory="${config.home.homeDirectory}/Music";
		playlistDirectory="${config.home.homeDirectory}/Music/Playlists";
		
		extraConfig=''
			restore_paused		"yes"

			audio_output {
				type		"pipewire"
				name		"Pipewire Output"
				mixer_type	"software"
			}
		'';
	};

	xdg.userDirs={
		enable=true;
		createDirectories=true;
		pictures = "${config.home.homeDirectory}/Pictures";
		music = "${config.home.homeDirectory}/Music";
		download = "${config.home.homeDirectory}/Downloads";
		extraConfig={
			XDG_PLAYLISTS_DIR="${config.xdg.userDirs.music}/Playlists";
			XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/Screenshots";
			XDG_WALLPAPERS_DIR = "${config.xdg.userDirs.pictures}/Wallpapers";
			XDG_GAMES_DIR = "${config.home.homeDirectory}/Games";
		};
		# i don't want these folders so i just point them to home
		templates = "${config.home.homeDirectory}";
		publicShare = "${config.home.homeDirectory}";
		desktop = "${config.home.homeDirectory}";
		documents = "${config.home.homeDirectory}";
	};
	
	xdg.configFile."qBittorrent/qBittorrent.ini".text = lib.generators.toINI {} {
		Preferences = {
			"Session\\Interface" = "wg0-mullvad";
			"Session\\InterfaceName" = "wg0-mullvad";
			"Session\\InterfaceAddress" = "";
		};
	};
}
