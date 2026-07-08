{config, pkgs, lib, ...}:{

	home.username="p";
	home.homeDirectory="/home/p";
	programs.git.enable=true;
	home.stateVersion="26.05";

	home.packages=with pkgs;[
		mpc
		rmpc
		android-tools
		qbittorrent
		mpv
		ffmpeg
		
		# proprietary garbage

	];

	programs.bash={
		enable=true;
	};

	programs.btop={
		enable=true;
	};
	
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
		music = "${config.home.homeDirectory}/Music";
		download = "${config.home.homeDirectory}/Downloads";
		extraConfig={
			XDG_PLAYLISTS_DIR="${config.home.homeDirectory}/Music/Playlists";
		};
	};
	
	xdg.configFile."qBittorrent/qBittorrent.ini".text = lib.generators.toINI {} {
		Preferences = {
			"Session\\Interface" = "wg0-mullvad";
			"Session\\InterfaceName" = "wg0-mullvad";
			"Session\\InterfaceAddress" = "";
		};
	};
}
