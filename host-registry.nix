{ lib }:
let
  rawHosts = import ./hosts.nix;

  platforms = {
    nixos = {
      required = [
        "platform"
        "system"
        "systemModule"
        "homeModule"
        "user"
      ];
      outputs.collection = "nixosConfigurations";
      activation = {
        kind = "nixos-rebuild";
        requiresSudo = true;
      };
    };

    darwin = {
      required = [
        "platform"
        "system"
        "systemModule"
        "homeModule"
        "user"
      ];
      outputs.collection = "darwinConfigurations";
      activation = {
        kind = "darwin-rebuild";
        requiresSudo = true;
      };
    };

    home-manager = {
      required = [
        "platform"
        "system"
        "homeModule"
        "user"
      ];
      outputs.collection = "homeConfigurations";
      activation = {
        kind = "home-manager";
        requiresSudo = false;
      };
    };
  };

  supportedPlatforms = builtins.attrNames platforms;

  hostError = outputName: message: throw "host registry: ${outputName}: ${message}";

  fieldList = fields: lib.concatStringsSep ", " (map (field: "`${field}`") fields);

  platformContract = outputName: platform:
    if builtins.hasAttr platform platforms then
      platforms.${platform}
    else
      hostError outputName "unsupported platform `${platform}`; expected one of ${fieldList supportedPlatforms}";

  validateHost = outputName: host:
    let
      platform =
        if builtins.hasAttr "platform" host then
          host.platform
        else
          hostError outputName "missing required field `platform`";
      contract = platformContract outputName platform;
      missing = builtins.filter (field: !(builtins.hasAttr field host)) contract.required;
    in
    if missing != [ ] then
      hostError outputName "missing required field(s): ${fieldList missing}"
    else
      contract;

  defaultHomePath = host:
    if builtins.hasAttr "homePath" host then
      host.homePath
    else if host.platform == "darwin" then
      "/Users/${host.user}"
    else
      "/home/${host.user}";

  normalizeHost = outputName: host:
    let
      contract = validateHost outputName host;
      flakeRef = ".#${outputName}";
    in
    host
    // {
      name = host.name or outputName;
      homePath = defaultHomePath host;
      outputs = {
        inherit flakeRef;
        inherit (contract.outputs) collection;
        attr = outputName;
      };
      activation = {
        inherit flakeRef;
        inherit (contract.activation) kind requiresSudo;
        flakeTarget = flakeRef;
      };
    };

  hosts = lib.mapAttrs normalizeHost rawHosts;
in
{
  inherit rawHosts hosts;

  hostsFor = platform: lib.filterAttrs (_: host: host.platform == platform) hosts;

  hostsForOutput = collection: lib.filterAttrs (_: host: host.outputs.collection == collection) hosts;

  activationTargets = lib.mapAttrs (_: host: {
    inherit (host)
      homePath
      platform
      system
      user
      ;
    inherit (host.activation)
      flakeTarget
      kind
      requiresSudo
      ;
  }) hosts;
}
