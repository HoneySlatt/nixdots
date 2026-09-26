{ pkgs, ... }:

{
  programs.mpv = {
    enable = true;

    config = {
      vo              = "gpu-next";
      gpu-api         = "vulkan";
      gpu-context     = "waylandvk";
      hwdec           = "vaapi-copy";
      video-sync      = "display-resample";
      swapchain-depth = 1;

      save-position-on-quit = "yes";
      keep-open             = "yes";
      cursor-autohide       = 1000;

      # Required when using a custom OSC script
      osc = "no";

      # Keep mpv output SDR; HDR sources are tone-mapped instead of triggering HDR.
      target-colorspace-hint      = "no"; # pas de gestion des couleurs sous niri
      target-trc                  = "srgb";
      target-prim                 = "bt.709";
      tone-mapping                = "bt.2446a";
      hdr-compute-peak            = "yes";
      gamut-mapping-mode          = "perceptual";

      scale               = "ewa_lanczossharp";
      cscale              = "spline36";
      dscale              = "mitchell";
      scale-antiring      = 0.6;
      cscale-antiring     = 0.6;
      dscale-antiring     = 0.6;
      sigmoid-upscaling   = "yes";
      correct-downscaling = "yes";
      linear-downscaling  = "yes";
      linear-upscaling    = "yes";
      dither              = "fruit";
      dither-depth        = "auto";
      deband              = "yes";
      deband-iterations   = 1;
      deband-threshold    = 32;
      deband-range        = 16;
      deband-grain        = 24;
    };

    bindings = {
      "-" = "add volume -2";
      "=" = "add volume 2";
    };

    scripts = with pkgs.mpvScripts; [
      modernz
      thumbfast
    ];

    scriptOpts = {
      modernz = {
        layout          = "modern-compact";
        icon_theme      = "fluent";
        icon_style      = "mixed";
        scalewindowed   = "0.5";
        scalefullscreen = "0.5";

        # Monochrome theme (white/grey)
        osc_color                  = "#000000";
        seekbarfg_color            = "#FFFFFF";
        seekbarbg_color            = "#666666";
        seek_handle_color          = "#FFFFFF";
        seek_handle_border_color   = "#FFFFFF";
        title_color                = "#FFFFFF";
        time_color                 = "#FFFFFF";
        side_buttons_color         = "#FFFFFF";
        middle_buttons_color       = "#FFFFFF";
        playpause_color            = "#FFFFFF";
        hover_effect_color         = "#FFFFFF";
        nibble_color               = "#FFFFFF";
        nibble_current_color       = "#FFFFFF";
        window_title_color         = "#FFFFFF";
        window_controls_color      = "#FFFFFF";
        cache_info_color           = "#FFFFFF";
        chapter_title_color        = "#FFFFFF";
        seekbar_cache_color        = "#555555";
        thumbnail_box_outline      = "#888888";
        volumebar_match_seek_color = true;
        osc_fade_strength          = 100;
      };
      thumbfast = {
        network = "yes";
        hwdec   = "yes";
      };
    };
  };

  # Scripts loaded directly by libmpv (used by jellyfin-mpv-shim)
  home.file.".config/mpv/scripts/modernz.lua".source =
    "${pkgs.mpvScripts.modernz}/share/mpv/scripts/modernz.lua";

  home.file.".config/mpv/scripts/thumbfast.lua".source =
    "${pkgs.mpvScripts.thumbfast}/share/mpv/scripts/thumbfast.lua";

  home.file.".config/mpv/fonts" = {
    source    = "${pkgs.mpvScripts.modernz}/share/fonts";
    recursive = true;
  };

  home.file.".config/jellyfin-mpv-shim/mpv.conf".text = ''
    vo=gpu-next
    gpu-api=vulkan
    gpu-context=waylandvk
    hwdec=vaapi-copy
    video-sync=display-resample
    swapchain-depth=1
    save-position-on-quit=yes
    keep-open=yes
    cursor-autohide=1000
    osc=no
    target-colorspace-hint=no
    target-trc=srgb
    target-prim=bt.709
    tone-mapping=bt.2446a
    hdr-compute-peak=yes
    gamut-mapping-mode=perceptual
    scale=ewa_lanczossharp
    cscale=spline36
    dscale=mitchell
    scale-antiring=0.6
    cscale-antiring=0.6
    dscale-antiring=0.6
    sigmoid-upscaling=yes
    correct-downscaling=yes
    linear-downscaling=yes
    linear-upscaling=yes
    dither=fruit
    dither-depth=auto
    deband=yes
    deband-iterations=1
    deband-threshold=32
    deband-range=16
    deband-grain=24
  '';

  home.file.".config/jellyfin-mpv-shim/input.conf".text = ''
    - add volume -2
    = add volume 2
  '';

  home.file.".config/jellyfin-mpv-shim/scripts/modernz.lua".source =
    "${pkgs.mpvScripts.modernz}/share/mpv/scripts/modernz.lua";

  # thumbfast n'est PAS placé ici : jellyfin-mpv-shim charge déjà sa propre
  # copie en interne pour le trickplay dès que "thumbnail_enable" est actif.
  # Le dupliquer ici faisait charger thumbfast deux fois et dessiner deux
  # aperçus de vignette superposés.

  home.file.".config/jellyfin-mpv-shim/fonts" = {
    source    = "${pkgs.mpvScripts.modernz}/share/fonts";
    recursive = true;
  };

  home.file.".config/jellyfin-mpv-shim/script-opts/modernz.conf".text = ''
    layout=modern-compact
    icon_theme=fluent
    icon_style=mixed
    scalewindowed=0.5
    scalefullscreen=0.5
    osc_color=#000000
    seekbarfg_color=#FFFFFF
    seekbarbg_color=#666666
    seek_handle_color=#FFFFFF
    seek_handle_border_color=#FFFFFF
    title_color=#FFFFFF
    time_color=#FFFFFF
    side_buttons_color=#FFFFFF
    middle_buttons_color=#FFFFFF
    playpause_color=#FFFFFF
    hover_effect_color=#FFFFFF
    nibble_color=#FFFFFF
    nibble_current_color=#FFFFFF
    window_title_color=#FFFFFF
    window_controls_color=#FFFFFF
    cache_info_color=#FFFFFF
    chapter_title_color=#FFFFFF
    seekbar_cache_color=#555555
    thumbnail_box_outline=#888888
    volumebar_match_seek_color=yes
    osc_fade_strength=100
  '';

  home.file.".config/jellyfin-mpv-shim/script-opts/thumbfast.conf".text = ''
    network=yes
    hwdec=yes
  '';
}
