{ lib, pkgs, ... }:

{
  services.searx = {
    enable = true;
    package = pkgs.searxng;
    redisCreateLocally = true;

    environmentFile = "/etc/searxng.env";

    settings = {

      general = {
        debug = false;
        instance_name = "searxng-local";
        donation_url = false;
        contact_url = false;
        privacypolicy_url = false;
        enable_metrics = false;
      };

      search = {
        safe_search = 0;
        autocomplete = "";
        default_lang = "en-US";
        ban_time_on_fail = 5;
        max_ban_time_on_fail = 120;
        formats = [ "html" "json" ];
      };

      server = {
        port = 8888;
        bind_address = "0.0.0.0";
        secret_key = "@SEARXNG_SECRET@";
        limiter = false;
        public_instance = false;
        image_proxy = false;
        method = "GET";
      };

      ui = {
        static_use_hash = true;
        default_locale = "en";
        query_in_title = true;
        infinite_scroll = true;
        center_alignment = false;
        default_theme = "simple";
        theme_args.simple_style = "dark";
        search_on_category_select = true;
        hotkeys = "vim";
      };

      outgoing = {
        request_timeout = 6.0;
        max_request_timeout = 15.0;
        pool_connections = 100;
        pool_maxsize = 20;
        enable_http2 = true;
      };

      engines = lib.mapAttrsToList (name: value: { inherit name; } // value) {
        "google".disabled = false;
        "google".weight = 2;
        "bing".disabled = false;
        "bing".weight = 1;
        "brave".disabled = false;
        "brave".weight = 1;
        "duckduckgo".disabled = false;
        "duckduckgo".weight = 1;
        "qwant".disabled = false;
        "qwant".weight = 1;
        "mojeek".disabled = false;
        "mojeek".weight = 0.5;
        "mwmbl".disabled = true;
        "mwmbl".weight = 0.4;

        "wikidata".disabled = false;
        "wikidata".weight = 1.5;
        "wikipedia".disabled = false;
        "wikipedia".weight = 1.5;
        "ddg definitions".disabled = false;
        "ddg definitions".weight = 2;
        "wikibooks".disabled = false;

        "stackoverflow".disabled = false;
        "stackoverflow".weight = 1.5;
        "github".disabled = false;
        "github".weight = 1;
        "searchcode code".disabled = false;

        "google news".disabled = false;
        "bing news".disabled = false;
      };

      enabled_plugins = [
        "Basic Calculator"
        "Hash plugin"
        "Open Access DOI rewrite"
        "Tracker URL remover"
        "Unit converter plugin"
      ];
    };
  };
}
