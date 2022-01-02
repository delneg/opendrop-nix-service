{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.services.opendrop-server;
in
{
  options.services.opendrop-server = {
    enable = mkEnableOption "Enable this to start opendrop Aidrop server";

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Open firewall ports for opendrop
      '';
    };

    dataDir = mkOption {
      type = types.str;
      description = "Working directory (where the files are stored)";
      example = "/tmp";
    };

    name = mkOption {
      type = types.str;
      description = "Computer name (displayed in sharing pane)";
      default = "OpendropServer";
    };

    user = mkOption {
      type = types.str;
      description = "The user under which the server runs.";
      example = "user";
    };

    networkInterface = mkOption {
      type = types.str;
      description = "Which Wi-Fi interface to use";
      example = "wlx00259ce04ceb";
    };

    awdlInterface = mkOption {
      type = types.str;
      description = "Which AWDL interface to use";
      default = "awdl0";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.opendrop;
      defaultText = literalExpression "pkgs.opendrop";
      description = ''
        The opendrop package to use.
      '';
    };
    owlPackage = mkOption {
      type = types.package;
      default = pkgs.owl;
      defaultText = literalExpression "pkgs.owl";
      description = ''
        The owl (Apple Wireless Direct Link - AWDL) package to use.
      '';
    };

    owlVerbose = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If owl is verbose or not
      '';
    };
  };

  config = mkIf cfg.enable {

      systemd.services.owl-server = {
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          WorkingDirectory = "${cfg.dataDir}";
          # Run the pre-start script with full permissions (the "!" prefix) so it
          # can switch the device to monitor mode
          ExecStartPre = let
            preStartScript = pkgs.writeScript "owl-run-prestart" ''
              #!${pkgs.bash}/bin/bash
              ${pkgs.nettools}/bin/ifconfig ${cfg.networkInterface} down
              ${pkgs.wirelesstools}/bin/iwconfig ${cfg.networkInterface} mode monitor
           '';
          in
            "!${preStartScript}";

          ExecStart = ''
            ${cfg.owlPackage}/bin/owl \
              -i ${cfg.networkInterface} -N ${if cfg.owlVerbose then "-v" else ""}
          '';
          Restart = "on-failure";
        };
      };

      systemd.services.opendrop-server = {
        description = "Apple AirDrop Server ";
        after = [ "owl-server.service" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          User = cfg.user;
          Group = "users";
          WorkingDirectory = "${cfg.dataDir}";

          ExecStart = ''
            ${cfg.package}/bin/opendrop \
              receive --name ${cfg.name} --interface ${cfg.awdlInterface}
          '';
          Restart = "on-failure";
        };
      };

      networking.firewall = mkIf cfg.openFirewall {
        allowedTCPPorts = [ 8771 5353 ];
        allowedUDPPorts = [ 8771 5353 ];
      };
    };
}