{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "taste-skill";
  version = "0-unstable-2026-07-17";

  src = fetchFromGitHub {
    owner = "Leonxlnx";
    repo = "taste-skill";
    rev = "7c397f22d3af6f2b3f1925eb147d8e8801086151";
    hash = "sha256-PfVSHoNh1riO6AKM8X/yIFxcI7YE5BQxd5a9XOp4cxw=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -d $out/share/taste-skill
    cp -r . $out/share/taste-skill/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Anti-slop frontend skills for AI agents";
    homepage = "https://github.com/Leonxlnx/taste-skill";
    license = licenses.mit;
    maintainers = [ ];
  };
}
