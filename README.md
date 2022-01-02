### OpenDrop Nix Service


Disclaimer: used by me for my own use cases, YMMV

Currently, the opendrop server seems to work quite unstable (even worse than Apple's implementation lol)

However, I managed to successfully transfer photos using it.



Anyway, usage in your configuration.nix:
```nix
{ config, pkgs, lib, ... }:
with lib;
let
  # opendrop
  owl = pkgs.callPackage ./owl/default.nix { };
  opendrop = pkgs.callPackage ./opendrop/default.nix { };
  opendropDataDir = "/some/dir";
  opendropName = "OpendropNixos";
  owlNetworkInterfaceName = "wlp0d1w1";
  
in
{
  imports =
    [
      ./services/code-server.nix
      ./services/opendrop-server.nix
    ];
  
  services = {
    opendrop-server = {
      enable = true;
      openFirewall = true;
      user = user;
      name = opendropName;
      dataDir = opendropDataDir;
      package = opendrop;
      owlPackage = owl;
      owlVerbose = true;
      networkInterface = owlNetworkInterfaceName;
    };
  };
}
```

License: MIT