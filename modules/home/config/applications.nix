{ pkgs, ... }:

{
  xdg.desktopEntries = {

    # ─── Desktop Apps ────────────────────────────────────────────────────────

    librewolf = {
      name       = "LibreWolf";
      exec       = "librewolf %U";
      icon       = "librewolf";
      comment    = "Browse the web";
      categories = [ "Network" "WebBrowser" ];
    };

    helium = {
      name       = "Helium";
      exec       = "helium %U";
      icon       = "helium";
      comment    = "Browse the web";
      categories = [ "Network" "WebBrowser" ];
    };

    vesktop = {
      name       = "Discord";
      exec       = "vesktop";
      icon       = "discord";
      comment    = "Discord client";
      categories = [ "Network" "InstantMessaging" ];
    };

    cider-2 = {
      name       = "Apple Music";
      exec       = "cider-2";
      icon       = "/home/honey/Pictures/Icons/applemusic.png";
      comment    = "Apple Music client";
      categories = [ "AudioVideo" "Audio" ];
    };

    mpv = {
      name       = "MPV";
      exec       = "mpv --player-operation-mode=pseudo-gui -- %U";
      icon       = "mpv";
      comment    = "Free and open source media player";
      mimeType   = [ "video/mp4" "video/mkv" "video/x-matroska" "video/webm" "video/avi" "video/x-msvideo" "video/quicktime" "video/x-flv" "audio/mpeg" "audio/flac" "audio/ogg" "audio/x-wav" ];
      noDisplay = true;
      categories = [ "AudioVideo" "Video" ];
    };

    "org.jellyfin.JellyfinDesktop" = {
      name       = "Jellyfin";
      exec       = "jellyfin-desktop";
      icon       = "org.jellyfin.JellyfinDesktop";
      comment    = "Jellyfin desktop client";
      categories = [ "AudioVideo" "Video" ];
    };

    gimp = {
      name       = "GIMP";
      exec       = "gimp %U";
      icon       = "gimp";
      comment    = "GNU Image Manipulation Program";
      mimeType   = [ "image/jpeg" "image/png" "image/gif" "image/webp" "image/bmp" "image/tiff" "image/x-xcf" ];
      categories = [ "Graphics" "2DGraphics" "RasterGraphics" ];
    };

    blender = {
      name       = "Blender";
      exec       = "blender %F";
      icon       = "blender";
      comment    = "3D creation suite";
      mimeType   = [ "application/x-blender" ];
      categories = [ "Graphics" "3DGraphics" ];
    };

    "org.inkscape.Inkscape" = {
      name       = "Inkscape";
      exec       = "inkscape %F";
      icon       = "org.inkscape.Inkscape";
      comment    = "Vector graphics editor";
      mimeType   = [ "image/svg+xml" "image/svg" "application/illustrator" ];
      categories = [ "Graphics" "VectorGraphics" ];
    };

    "org.kde.kdenlive" = {
      name       = "Kdenlive";
      exec       = "kdenlive %F";
      icon       = "kdenlive";
      comment    = "Video editor";
      categories = [ "AudioVideo" "Video" ];
    };


    "com.obsproject.Studio" = {
      name       = "OBS Studio";
      exec       = "obs";
      icon       = "com.obsproject.Studio";
      comment    = "Streaming and recording software";
      categories = [ "AudioVideo" "Video" ];
    };

    obsidian = {
      name       = "Obsidian";
      exec       = "obsidian %U";
      icon       = "obsidian";
      comment    = "Markdown knowledge base";
      categories = [ "Office" "TextEditor" ];
    };


    "tutanota-desktop" = {
      name       = "Tuta Mail";
      exec       = "tutanota-desktop --no-sandbox %U";
      icon       = "/home/honey/Pictures/Icons/tuta.png";
      comment    = "Encrypted email client";
      categories = [ "Network" "Email" ];
    };

    virt-manager = {
      name       = "Virtual Machine Manager";
      exec       = "virt-manager";
      icon       = "/home/honey/Pictures/Icons/virtualbox.png";
      comment    = "Manage virtual machines";
      categories = [ "System" "Emulator" ];
    };

    bitwarden = {
      name       = "Bitwarden";
      exec       = "bitwarden %U";
      icon       = "/home/honey/Pictures/Icons/bitwarden.png";
      comment    = "Password manager";
      categories = [ "Network" "Security" ];
    };

    startcenter = {
      name       = "LibreOffice";
      exec       = "libreoffice %U";
      icon       = "libreoffice-startcenter";
      comment    = "LibreOffice start center";
      categories = [ "Office" ];
    };

    "org.qbittorrent.qBittorrent" = {
      name       = "qBittorrent";
      exec       = "qbittorrent %U";
      icon       = "org.qbittorrent.qBittorrent";
      comment    = "BitTorrent client";
      categories = [ "Network" "FileTransfer" "P2P" ];
    };

    steam = {
      name       = "Steam";
      exec       = "steam %U";
      icon       = "steam";
      comment    = "Steam game client";
      categories = [ "Game" ];
    };

    "org.prismlauncher.PrismLauncher" = {
      name       = "Minecraft";
      exec       = "prismlauncher";
      icon       = "/home/honey/Pictures/Icons/minecrafths.png";
      comment    = "Minecraft launcher";
      categories = [ "Game" ];
    };

    xivlauncher = {
      name       = "Final Fantasy XIV Online";
      exec       = "XIVLauncher.Core";
      icon       = "/home/honey/Pictures/Icons/ffxiv.png";
      comment    = "Final Fantasy XIV launcher";
      categories = [ "Game" ];
    };

    Ryujinx = {
      name       = "Ryujinx";
      exec       = "ryujinx";
      icon       = "Ryujinx";
      comment    = "Nintendo Switch emulator";
      categories = [ "Game" "Emulator" ];
    };

    nixos-manual = {
      name       = "NixOS";
      exec       = "nixos-help";
      icon       = "nix-snowflake";
      comment    = "NixOS documentation";
      categories = [ "System" "Documentation" ];
    };

    # ─── TUI / CLI Tools ─────────────────────────────────────────────────────

    kitty = {
      name       = "Kitty";
      exec       = "kitty";
      icon       = "kitty";
      comment    = "Fast, feature-rich terminal emulator";
      categories = [ "System" "TerminalEmulator" ];
    };

    nvim = {
      name       = "Neovim";
      exec       = "kitty -e nvim %F";
      icon       = "nvim";
      comment    = "Hyperextensible Vim-based text editor";
      categories = [ "Utility" "TextEditor" ];
    };

    yazi = {
      name       = "Yazi";
      exec       = "kitty -e yazi %F";
      icon       = "/home/honey/Pictures/Icons/yazi.png";
      comment    = "Blazing fast terminal file manager";
      categories = [ "System" "FileManager" ];
    };

    # ─── Others (hidden overrides) ───────────────────────────────────────────

    btop = {
      name      = "btop++";
      exec      = "kitty -e btop";
      icon      = "btop";
      comment   = "Resource monitor";
      noDisplay = true;
      categories = [ "System" "Monitor" ];
    };

    umpv = {
      name      = "umpv";
      noDisplay = true;
      exec      = "umpv %U";
      icon      = "mpv";
      categories = [ "AudioVideo" "Video" ];
    };

    jellyfin-mpv-shim = {
      name      = "Jellyfin MPV Shim";
      exec      = "jellyfin-mpv-shim";
      icon      = "jellyfin-mpv-shim";
      terminal  = true;
      noDisplay = true;
      comment   = "Cast media from Jellyfin to mpv";
      categories = [ "AudioVideo" "Video" ];
    };

    imv = {
      name      = "imv";
      exec      = "imv %F";
      icon      = "imv";
      noDisplay = true;
      mimeType  = [ "image/jpeg" "image/png" "image/gif" "image/webp" "image/avif" "image/bmp" "image/tiff" "image/svg+xml" ];
      categories = [ "Graphics" "Viewer" ];
    };

    imv-dir = {
      name      = "imv";
      noDisplay = true;
      exec      = "imv %F";
      icon      = "imv";
      categories = [ "Graphics" "Viewer" ];
    };

    "org.pwmt.zathura" = {
      name      = "Zathura";
      exec      = "zathura %F";
      icon      = "org.pwmt.zathura";
      noDisplay = true;
      mimeType  = [ "application/pdf" "application/postscript" "image/vnd.djvu" "application/epub+zip" ];
      categories = [ "Office" "Viewer" ];
    };

    "io.github.ilya_zlobintsev.LACT" = {
      name      = "LACT";
      exec      = "lact gui";
      icon      = "io.github.ilya_zlobintsev.LACT";
      noDisplay = true;
      categories = [ "System" "Settings" ];
    };

    kvantummanager = {
      name      = "Kvantum Manager";
      exec      = "kvantummanager";
      icon      = "kvantummanager";
      noDisplay = true;
      categories = [ "Settings" ];
    };

    steam-metadata-editor = {
      name      = "Steam Metadata Editor";
      exec      = "steam-metadata-editor";
      icon      = "steam-metadata-editor";
      noDisplay = true;
      categories = [ "Game" "Utility" ];
    };

    writer = {
      name      = "LibreOffice Writer";
      exec      = "libreoffice --writer %U";
      icon      = "libreoffice-writer";
      noDisplay = true;
      categories = [ "Office" "WordProcessor" ];
    };

    calc = {
      name      = "LibreOffice Calc";
      exec      = "libreoffice --calc %U";
      icon      = "libreoffice-calc";
      noDisplay = true;
      categories = [ "Office" "Spreadsheet" ];
    };

    impress = {
      name      = "LibreOffice Impress";
      exec      = "libreoffice --impress %U";
      icon      = "libreoffice-impress";
      noDisplay = true;
      categories = [ "Office" "Presentation" ];
    };

    draw = {
      name      = "LibreOffice Draw";
      exec      = "libreoffice --draw %U";
      icon      = "libreoffice-draw";
      noDisplay = true;
      categories = [ "Office" "Graphics" ];
    };

    math = {
      name      = "LibreOffice Math";
      exec      = "libreoffice --math %U";
      icon      = "libreoffice-math";
      noDisplay = true;
      categories = [ "Office" ];
    };

    base = {
      name      = "LibreOffice Base";
      exec      = "libreoffice --base %U";
      icon      = "libreoffice-base";
      noDisplay = true;
      categories = [ "Office" "Database" ];
    };

    xsltfilter = {
      name      = "LibreOffice XSLT Filter";
      exec      = "libreoffice";
      icon      = "libreoffice-startcenter";
      noDisplay = true;
      categories = [ "Office" ];
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Images → imv
      "image/jpeg"    = "imv.desktop";
      "image/png"     = "imv.desktop";
      "image/gif"     = "imv.desktop";
      "image/webp"    = "imv.desktop";
      "image/avif"    = "imv.desktop";
      "image/bmp"     = "imv.desktop";
      "image/tiff"    = "imv.desktop";
      "image/svg+xml" = "imv.desktop";

      # Videos → mpv
      "video/mp4"        = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/webm"       = "mpv.desktop";
      "video/x-msvideo"  = "mpv.desktop";
      "video/quicktime"  = "mpv.desktop";
      "video/x-flv"      = "mpv.desktop";
      "audio/mpeg"       = "mpv.desktop";
      "audio/flac"       = "mpv.desktop";
      "audio/ogg"        = "mpv.desktop";
      "audio/x-wav"      = "mpv.desktop";

      # PDF → zathura
      "application/pdf"        = "org.pwmt.zathura.desktop";
      "application/postscript" = "org.pwmt.zathura.desktop";
      "image/vnd.djvu"         = "org.pwmt.zathura.desktop";
      "application/epub+zip"   = "org.pwmt.zathura.desktop";

      # Text / code → neovim
      "text/plain"                = "nvim.desktop";
      "text/x-shellscript"        = "nvim.desktop";
      "text/x-python"             = "nvim.desktop";
      "text/x-csrc"               = "nvim.desktop";
      "text/x-chdr"               = "nvim.desktop";
      "text/x-c++src"             = "nvim.desktop";
      "text/x-lua"                = "nvim.desktop";
      "text/x-rust"               = "nvim.desktop";
      "text/x-go"                 = "nvim.desktop";
      "text/x-java"               = "nvim.desktop";
      "text/html"                  = "helium.desktop";
      "x-scheme-handler/http"      = "helium.desktop";
      "x-scheme-handler/https"     = "helium.desktop";
      "x-scheme-handler/ftp"       = "helium.desktop";
      "x-scheme-handler/about"     = "helium.desktop";
      "x-scheme-handler/unknown"   = "helium.desktop";
      "application/xhtml+xml"      = "helium.desktop";
      "application/x-extension-htm"   = "helium.desktop";
      "application/x-extension-html"  = "helium.desktop";
      "application/x-extension-xhtml" = "helium.desktop";
      "text/css"                  = "nvim.desktop";
      "text/javascript"           = "nvim.desktop";
      "application/json"          = "nvim.desktop";
      "application/x-yaml"        = "nvim.desktop";
      "application/x-shellscript" = "nvim.desktop";
    };
  };
}
