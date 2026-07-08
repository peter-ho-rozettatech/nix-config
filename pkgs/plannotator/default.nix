{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchurl,
}:
let
  version = "browser-tests-pr957";

  hashes = {
    "x86_64-linux" = "sha256-03G3gkKjHWh7rc0ncrc1fjOVZ8h0tE56UDFtHRHSp9E=";
    "aarch64-linux" = "";
    "x86_64-darwin" = "";
    "aarch64-darwin" = "sha256-gMGOKz6VeW6FkCtOPsktj3v0nfjr/L0SGVx4T6Ui/do=";
  };

  platform =
    {
      "x86_64-linux" = "linux-x64";
      "aarch64-linux" = "linux-arm64";
      "x86_64-darwin" = "darwin-x64";
      "aarch64-darwin" = "darwin-arm64";
    }
    .${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported platform: ${stdenvNoCC.hostPlatform.system}");

  sha256 =
    hashes.${stdenvNoCC.hostPlatform.system}
      or (throw "No hash for ${stdenvNoCC.hostPlatform.system} - add it to the hashes attrset");
in
stdenvNoCC.mkDerivation {
  pname = "plannotator";
  inherit version;

  src = fetchFromGitHub {
    owner = "backnotprop";
    repo = "plannotator";
    rev = "070d9a5f6d679ecb575fbffd5d53615302bc1eb1";
    sha256 = "0s52n5sp7088zs7yh4g4am48q6l8iim6iivgx1al3aqs95zsl4ab";
  };

  binary = fetchurl {
    url = "https://github.com/backnotprop/plannotator/releases/download/v${version}/plannotator-${platform}";
    inherit sha256;
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -d $out/share/plannotator
    cp -r . $out/share/plannotator/

    install -Dm755 $binary $out/bin/plannotator

    runHook postInstall
  '';

  meta = with lib; {
    description = "Visual plan review tool for AI coding agents";
    homepage = "https://github.com/backnotprop/plannotator";
    license = with licenses; [
      asl20
      mit
    ];
    maintainers = [ ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
