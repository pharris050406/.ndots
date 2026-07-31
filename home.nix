{config, pkgs, lib, inputs, ...}:
let
    themesData = import ./themes.nix;
    theme = themesData.themes.${themesData.default};
    themeSwitch = import ./theme-switch.nix { inherit pkgs lib themesData; };
in
{
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
		quickshell
		alsa-utils	
		yt-dlp
		spotdl
		vesktop
		obs-studio
		libreoffice
		mako
		swaybg
		wmenu
		themeSwitch
				    
		vlc
		acpi
		# nvim stuff
		nixd
		lua-language-server
		texlab
		clang-tools 
		bash-language-server
		
		#languages
		(julia.withPackages [
		    "LanguageServer"
		    "SymbolServer"
		])
		# proprietary garbage

	];

	programs.bash={
		enable=true;
		enableCompletion = true;
		shellAliases = {
			vi = "nvim";
			vim = "nvim";
			yz = "yazi";
			nrs = "sudo nixos-rebuild switch --flake ~/.ndots";
			ncd = "cd ${config.home.homeDirectory}/.ndots";
		};
		initExtra = ''
		    bb() {
		      ~/.config/bash/scripts/bluetooth_ctl.sh "$@"
		    }

		    _bb_complete() {
		      local cur=''${COMP_WORDS[COMP_CWORD]}
		      local prev=''${COMP_WORDS[COMP_CWORD-1]}

		      if [[ $COMP_CWORD -eq 1 ]]; then
			COMPREPLY=($(compgen -W "-s -c -d -r -l --scan --connect --disconnect --remove --list" -- "$cur"))
			return
		      fi

		      if [[ "$prev" == "-c" || "$prev" == "-d" || "$prev" == "-r" || \
			    "$prev" == "--connect" || "$prev" == "--disconnect" || "$prev" == "--remove" ]]; then
			local IFS=$'\n'
			while IFS= read -r name; do
			  COMPREPLY+=("$name")
			done < <(cat "$HOME/.btctl_devices" 2>/dev/null | cut -d' ' -f2- | sort -u | grep -i "^$cur")
			return
		      fi
		    }

		    complete -o filenames -F _bb_complete bb
		  '';
		profileExtra=''
		   if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
			exec sway --unsupported-gpu
		   fi
		'';
		};
	home.sessionPath = [
		"${config.home.homeDirectory}/.ndots/config/bash/scripts"
	];
	home.sessionVariables = {
	    THM_BG = lib.removePrefix "#" theme.bg;
	    THM_FG = lib.removePrefix "#" theme.fg;
	    THM_BLUE = lib.removePrefix "#" theme.blue;

	    THM_FONT = theme.font;
	    THM_FONT_SIZE = toString theme.uiFontSize;
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


xdg.configFile."sway/config" = {
        source = config.lib.file.mkOutOfStoreSymlink "/home/p/.ndots/config/sway/config";
    };
    xdg.configFile."sway/config.d" = {
        source = config.lib.file.mkOutOfStoreSymlink "/home/p/.ndots/config/sway/config.d";
        recursive = true;
    };
    xdg.configFile."sway/scripts" = {
        source = config.lib.file.mkOutOfStoreSymlink "/home/p/.ndots/config/sway/scripts";
        recursive = true;
    };

    xdg.configFile."quickshell" = {
	source = config.lib.file.mkOutOfStoreSymlink "/home/p/.ndots/config/quickshell";
	recursive = true;
    };
	xdg.configFile."rmpc/config.ron".source = config.lib.file.mkOutOfStoreSymlink "/home/p/.ndots/config/rmpc/config.ron";

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

	# Applies the declared default theme the first time this config is activated
	# on a machine (so a fresh install always has a working theme). If you've
	# already picked a theme with `theme-switch`, later rebuilds leave it alone.
	home.activation.applyDefaultTheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
		STATE_FILE="$HOME/.local/state/ndots-theme"
		if [ ! -f "$STATE_FILE" ]; then
			$DRY_RUN_CMD ${themeSwitch}/bin/theme-switch ${themesData.default}
		fi
	'';
}
