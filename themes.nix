{
  default = "tokyonight";

  themes = {
    tokyonight = {
      background = "#1a1b26";
      backgroundPanel = "#801a1b26";
      foreground = "#c0caf5";
      muted = "#565f89";

      accent1 = "#7dcfff";
      accent2 = "#7aa2f7"; # Window manager highlight
      accent3 = "#9ece6a";
      accent4 = "#e0af68";
      accent5 = "#ff9e64";
      accent6 = "#f7768e";
      accent7 = "#bb9af7";

      font = "JetBrainsMono Nerd Font";
      uiFontSize = 10;
      barFontSize = 13;

      barColor = "#1e1e2e";
      barOpacity = 0.85;
    };

    nord = {
      background = "#2e3440";
      backgroundPanel = "#802e3440";
      foreground = "#eceff4";
      muted = "#4c566a";

      accent1 = "#8fbcbb"; # Frost ice cyan
      accent2 = "#88c0d0"; # Frost blue
      accent3 = "#81a1c1"; # Deep frost
      accent4 = "#ebcb8b"; # Aurora yellow
      accent5 = "#d08770"; # Aurora orange
      accent6 = "#bf616a"; # Aurora red
      accent7 = "#b48ead"; # Aurora purple

      font = "JetBrainsMono Nerd Font";
      uiFontSize = 10;
      barFontSize = 13;

      barColor = "#3b4252";
      barOpacity = 0.85;
    };

    catppuccin = {
      background = "#1e1e2e";
      backgroundPanel = "#801e1e2e";
      foreground = "#cdd6f4";
      muted = "#585b70";

      accent1 = "#89dceb"; # Sky
      accent2 = "#89b4fa"; # Blue
      accent3 = "#a6e3a1"; # Green
      accent4 = "#f9e2af"; # Yellow
      accent5 = "#fab387"; # Peach
      accent6 = "#f38ba8"; # Red
      accent7 = "#cba6f7"; # Mauve

      font = "JetBrainsMono Nerd Font";
      uiFontSize = 10;
      barFontSize = 13;

      barColor = "#181825";
      barOpacity = 0.85;
    };

    gruvbox = {
      background = "#282828";
      backgroundPanel = "#80282828";
      foreground = "#ebdbb2";
      muted = "#928374";

      accent1 = "#8ec07c";
      accent2 = "#83a598";
      accent3 = "#b8bb26";
      accent4 = "#fabd2f";
      accent5 = "#fe8019";
      accent6 = "#fb4934";
      accent7 = "#d3869b";

      font = "JetBrainsMono Nerd Font";
      uiFontSize = 10;
      barFontSize = 13;

      barColor = "#3c3836";
      barOpacity = 0.85;
    };

    dracula = {
      background = "#282a36";
      backgroundPanel = "#80282a36";
      foreground = "#f8f8f2";
      muted = "#6272a4";

      accent1 = "#8be9fd"; # Cyan
      accent2 = "#bd93f9"; # Purple
      accent3 = "#50fa7b"; # Green
      accent4 = "#f1fa8c"; # Yellow
      accent5 = "#ffb86c"; # Orange
      accent6 = "#ff5555"; # Red
      accent7 = "#ff79c6"; # Pink

      font = "JetBrainsMono Nerd Font";
      uiFontSize = 10;
      barFontSize = 13;

      barColor = "#44475a";
      barOpacity = 0.85;
    };

    solarized = {
      background = "#002b36";
      backgroundPanel = "#80002b36";
      foreground = "#839496";
      muted = "#586e75";

      accent1 = "#2aa198";
      accent2 = "#268bd2";
      accent3 = "#859900";
      accent4 = "#b58900";
      accent5 = "#cb4b16";
      accent6 = "#dc322f";
      accent7 = "#d33682";

      font = "JetBrainsMono Nerd Font";
      uiFontSize = 10;
      barFontSize = 13;

      barColor = "#073642";
      barOpacity = 0.85;
    };

    tokyonight_day_hc = {
      background = "#e1e2e7";
      backgroundPanel = "#e6e1e2e7";
      foreground = "#111118";
      muted = "#6a739d";

      accent1 = "#005c7a";
      accent2 = "#1e5cc2";
      accent3 = "#436821";
      accent4 = "#825d25";
      accent5 = "#a14d00";
      accent6 = "#d11f54";
      accent7 = "#7d31df";

      font = "JetBrainsMono Nerd Font";
      uiFontSize = 10;
      barFontSize = 13;

      barColor = "#d0d5e3";
      barOpacity = 0.95;
    };

    gruvbox_light_hc = {
      background = "#fbf1c7";
      backgroundPanel = "#e6fbf1c7";
      foreground = "#1d2021";
      muted = "#7c6f64";

      accent1 = "#427b58";
      accent2 = "#076678";
      accent3 = "#79740e";
      accent4 = "#b57614";
      accent5 = "#af3a03";
      accent6 = "#9d0006";
      accent7 = "#8f3f71";

      font = "JetBrainsMono Nerd Font";
      uiFontSize = 10;
      barFontSize = 13;

      barColor = "#ebdbb2";
      barOpacity = 0.95;
    };

    aurora = {
      # Cosmic starry night with vibrant electric neons
      background = "#0b1117";
      backgroundPanel = "#cc0b1117";
      foreground = "#d9f6ff";
      muted = "#5f7b8c";

      accent1 = "#00f5d4"; # Electric turquoise
      accent2 = "#00bbf9"; # Aurora blue
      accent3 = "#38b000"; # Emerald glow
      accent4 = "#fee440"; # Star yellow
      accent5 = "#ff70a6"; # Neon pink
      accent6 = "#f15bb5"; # Magenta light
      accent7 = "#9b5de5"; # Cosmic violet

      font = "JetBrainsMono Nerd Font";
      uiFontSize = 10;
      barFontSize = 13;

      barColor = "#111b24";
      barOpacity = 0.90;
    };

    forest = {
      # Natural, earthy, deep woodland shades & mist tones
      background = "#161d18";
      backgroundPanel = "#cc161d18";
      foreground = "#e6efe7";
      muted = "#708070";

      accent1 = "#52b788"; # Pine green
      accent2 = "#74c69d"; # Sage leaf
      accent3 = "#95d5b2"; # Moss green
      accent4 = "#d8f3dc"; # Pale mint
      accent5 = "#ddb892"; # Birch bark
      accent6 = "#b08968"; # Rich timber
      accent7 = "#6b9080"; # Forest mist

      font = "JetBrainsMono Nerd Font";
      uiFontSize = 10;
      barFontSize = 13;

      barColor = "#1e2a22";
      barOpacity = 0.88;
    };

    sunset = {
      # Warm dusk horizon: oranges, deep pinks, twilight purples
      background = "#2b1f28";
      backgroundPanel = "#cc2b1f28";
      foreground = "#fff2e8";
      muted = "#aa8d8d";

      accent1 = "#f72585"; # Vibrant magenta sky
      accent2 = "#ff9f43"; # Deep twilight purple
      accent3 = "#3f37c9"; # Dusk blue
      accent4 = "#f8961e"; # Sunset orange
      accent5 = "#f9c74f"; # Golden horizon
      accent6 = "#f94144"; # Crimson sun
      accent7 = "#b5179e"; # Plum twilight

      font = "JetBrainsMono Nerd Font";
      uiFontSize = 10;
      barFontSize = 13;

      barColor = "#3a2635";
      barOpacity = 0.90;
    };

    matrix = {
      # Monochromatic digital rain — varying hues of neon, lime & cyber green
      background = "#020402";
      backgroundPanel = "#d9020402";
      foreground = "#6eff6e";
      muted = "#2f5f2f";

      accent1 = "#00ff66"; # Bright matrix green
      accent2 = "#00cc44"; # Terminal green
      accent3 = "#33ff33"; # Neon lime
      accent4 = "#00ffaa"; # Mint cyber green
      accent5 = "#88ff00"; # Yellow-green phosphor
      accent6 = "#009933"; # Deep emerald code
      accent7 = "#66ff99"; # Light phosphor code

      font = "JetBrainsMono Nerd Font";
      uiFontSize = 10;
      barFontSize = 13;

      barColor = "#071107";
      barOpacity = 0.93;
    };

    rosepine = {
      # Authentic Rosé Pine palette (Foam, Iris, Pine, Gold, Rose, Love)
      background = "#191724";
      backgroundPanel = "#cc191724";
      foreground = "#e0def4";
      muted = "#6e6a86";

      accent1 = "#9ccfd8"; # Foam
      accent2 = "#c4a7e7"; # Iris
      accent3 = "#31748f"; # Pine
      accent4 = "#f6c177"; # Gold
      accent5 = "#ebbcba"; # Rose
      accent6 = "#eb6f92"; # Love
      accent7 = "#e0def4"; # Muted text glow

      font = "JetBrainsMono Nerd Font";
      uiFontSize = 10;
      barFontSize = 13;

      barColor = "#232136";
      barOpacity = 0.88;
    };

    vaporwave = {
      # 80s Synthwave aesthetic: Laser Cyan, Hot Pink, Neon Purple
      background = "#18142a";
      backgroundPanel = "#cc18142a";
      foreground = "#f5f0ff";
      muted = "#8c83b5";

      accent1 = "#00f0ff"; # Laser cyan
      accent2 = "#ff007f"; # Hot pink
      accent3 = "#00ff9f"; # Synth mint
      accent4 = "#ffe600"; # Neon yellow
      accent5 = "#ff8800"; # Sunset orange
      accent6 = "#ff0055"; # Neon red
      accent7 = "#bd00ff"; # Electric violet

      font = "JetBrainsMono Nerd Font";
      uiFontSize = 10;
      barFontSize = 13;

      barColor = "#241c3d";
      barOpacity = 0.90;
    };

    oled = {
      # High-contrast pure neon pops on absolute OLED black
      background = "#000000";
      backgroundPanel = "#d9000000";
      foreground = "#ffffff";
      muted = "#555555";

      accent1 = "#00ffff"; # Pure cyan
      accent2 = "#007eff"; # Electric blue
      accent3 = "#00ff00"; # Pure green
      accent4 = "#ffff00"; # Pure yellow
      accent5 = "#ff7f00"; # Pure orange
      accent6 = "#ff0033"; # Pure red
      accent7 = "#e000ff"; # Pure magenta

      font = "JetBrainsMono Nerd Font";
      uiFontSize = 10;
      barFontSize = 13;

      barColor = "#080808";
      barOpacity = 0.95;
    };

    abyss = {
      # Deep ocean trench with bioluminescent plankton & jellyfish glows
      background = "#04080d";
      backgroundPanel = "#cc04080d";
      foreground = "#d4f1f9";
      muted = "#3a5a66";

      accent1 = "#00f5ff"; # Bioluminescent teal
      accent2 = "#00a8ff"; # Deep ocean cyan
      accent3 = "#00ffaa"; # Seafoam glow
      accent4 = "#7000ff"; # Abyssal violet
      accent5 = "#ff00aa"; # Jellyfish magenta
      accent6 = "#0033ff"; # Deep trench blue
      accent7 = "#00ebd6"; # Electric plankton

      font = "JetBrainsMono Nerd Font";
      uiFontSize = 10;
      barFontSize = 13;

      barColor = "#0a1218";
      barOpacity = 0.90;
    };

    wildberry = {
      # Rich fruit, wine, plum, and berry tones
      background = "#1c0f1a";
      backgroundPanel = "#cc1c0f1a";
      foreground = "#f3e3ee";
      muted = "#7a5a72";

      accent1 = "#e056fd"; # Vibrant berry
      accent2 = "#be2edd"; # Deep plum
      accent3 = "#ff7979"; # Cranberry
      accent4 = "#badc58"; # Gooseberry leaf
      accent5 = "#f0932b"; # Apricot
      accent6 = "#eb4d4b"; # Raspberry
      accent7 = "#686de0"; # Blueberry

      font = "JetBrainsMono Nerd Font";
      uiFontSize = 10;
      barFontSize = 13;

      barColor = "#2b1826";
      barOpacity = 0.90;
    };

    copperfield = {
      # Warm foundry tones: polished copper, rust, brass, and verdigris patina
      background = "#1f1712";
      backgroundPanel = "#cc1f1712";
      foreground = "#f2e4d3";
      muted = "#8a7159";

      accent1 = "#e58e26"; # Polished copper
      accent2 = "#b71540"; # Burnt brick red
      accent3 = "#38ada9"; # Verdigris patina
      accent4 = "#f6b93b"; # Brass yellow
      accent5 = "#e55039"; # Rust red
      accent6 = "#78e08f"; # Oxidized bronze
      accent7 = "#fa983a"; # Amber glow

      font = "JetBrainsMono Nerd Font";
      uiFontSize = 10;
      barFontSize = 13;

      barColor = "#2c2119";
      barOpacity = 0.90;
    };

    glacier = {
      # Crisp arctic light theme: icy blues, cold slate, and frost cyan
      background = "#eef5f7";
      backgroundPanel = "#e6eef5f7";
      foreground = "#132b33";
      muted = "#5f7d85";

      accent1 = "#00a8cc"; # Glacial cyan
      accent2 = "#27496d"; # Deep ice blue
      accent3 = "#438a5e"; # Pine teal
      accent4 = "#f0a500"; # Arctic sun amber
      accent5 = "#e8505b"; # Polar red
      accent6 = "#142850"; # Deep slate navy
      accent7 = "#80d4ff"; # Frost blue

      font = "JetBrainsMono Nerd Font";
      uiFontSize = 10;
      barFontSize = 13;

      barColor = "#dbe9ed";
      barOpacity = 0.95;
    };
  };
}
