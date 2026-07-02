{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "anthropic-skills";
  version = "0-unstable-2026-07-01";

  src = fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "9d2f1ae187231d8199c64b5b762e1bdf2244733d";
    sha256 = "sha256-U7Nt1xrFOSOEm4vuWmy4pVsEyvv+Hj4sv8yXOofmwAw=";
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
