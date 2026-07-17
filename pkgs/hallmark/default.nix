{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "hallmark";
  version = "0-unstable-2026-06-04";

  src = fetchFromGitHub {
    owner = "Nutlope";
    repo = "hallmark";
    rev = "aeb42fb354ff4efa36ab475773a082315a3af2ce";
    hash = "sha256-+yPIG1XdI6hhyOH48rd20+YlFrA9Gr416tPt1OoxfwQ=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -d $out/share/hallmark
    cp -r skills $out/share/hallmark/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Anti-AI-slop design skill for Claude Code, Cursor, and Codex";
    homepage = "https://github.com/Nutlope/hallmark";
    license = licenses.mit;
    maintainers = [ ];
  };
}
