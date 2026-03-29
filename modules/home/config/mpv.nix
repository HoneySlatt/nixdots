{ pkgs, ... }:

{
  programs.mpv = {
    enable = true;

    config = {
      # Rendering
      vo           = "gpu-next";
      gpu-api      = "vulkan";
      gpu-context  = "waylandvk";
      hwdec        = "vaapi-copy";
      video-sync   = "display-resample";
      swapchain-depth = 1;

      # IPC socket
      input-ipc-server = "/tmp/mpvsocket";

      # Playback behavior
      save-position-on-quit = "yes";
      keep-open             = "yes";
      cursor-autohide       = 1000;

      # Color management
      target-colorspace-hint = "no";
      target-trc             = "srgb";

      # Scaling
      scale  = "ewa_lanczossharp";
      cscale = "spline36";
      dscale = "mitchell";

      linear-upscaling = "yes";
    };

    # HDR profile
    profiles = {
      hdr-content = {
        profile-cond           = ''p["video-params/sig-peak"] > 1'';
        target-colorspace-hint = "yes";
        tone-mapping           = "bt.2390";
        hdr-compute-peak       = "yes";
        target-peak            = 1015;
      };
    };

    # Keybindings
    bindings = {
      "-" = "add volume -2";
      "=" = "add volume 2";
    };
  };

  # Sync mpv config vers jellyfin-mpv-shim
  home.file.".config/jellyfin-mpv-shim/mpv.conf".text = ''
    vo=gpu-next
    gpu-api=vulkan
    gpu-context=waylandvk
    hwdec=vaapi-copy
    video-sync=display-resample
    swapchain-depth=1
    input-ipc-server=/tmp/mpvsocket
    save-position-on-quit=yes
    keep-open=yes
    cursor-autohide=1000
    target-colorspace-hint=no
    target-trc=srgb
    scale=ewa_lanczossharp
    cscale=spline36
    dscale=mitchell
    linear-upscaling=yes

    [hdr-content]
    profile-cond=p["video-params/sig-peak"] > 1
    target-colorspace-hint=yes
    tone-mapping=bt.2390
    hdr-compute-peak=yes
    target-peak=1015
  '';

  home.file.".config/jellyfin-mpv-shim/input.conf".text = ''
    - add volume -2
    = add volume 2
  '';
}
