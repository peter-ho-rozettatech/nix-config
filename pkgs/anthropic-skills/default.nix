{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "anthropic-skills";
  version = "0-unstable-2026-07-22";

  src = fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "1f630fdf9259cec4a14913127dfd7c3b69ef72eb";
    sha256 = "sha256-XPXKd05IEiyTPlAPkowfJUal1UfRlxEHo+GgszgHQCI=";
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
