{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "anthropic-skills";
  version = "0-unstable-2026-07-17";

  src = fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "fa0fa64bdc967915dc8399e803be67759e1e62b8";
    sha256 = "sha256-QZ+zJkyLd/42rxgtJEZSUOz9R75Tse6UXW7G0nOkFS8=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -d $out/share/anthropic-skills
    cp -r . $out/share/anthropic-skills/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Anthropic skills repository";
    homepage = "https://github.com/anthropics/skills";
    license = licenses.mit;
    maintainers = [ ];
  };
}
