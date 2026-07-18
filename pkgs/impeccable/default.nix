{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  bun,
  writableTmpDirAsHomeHook,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "impeccable";
  version = "skill-v3.9.1-unstable-2026-07-17";

  src = fetchFromGitHub {
    owner = "pbakaus";
    repo = "impeccable";
    rev = "8967edc988ee146823bca3c51fcf51296e9dec18";
    hash = "sha256-d9RMVuFD4HPwwfjn3j7xSVl3NnxgkxdZB5p5ubpNuPk=";
  };

  nativeBuildInputs = [
    bun
    writableTmpDirAsHomeHook
  ];

  postPatch = ''
    substituteInPlace scripts/lib/zip.js \
        --replace-fail "import { ZipArchive } from 'archiver';" ""

    substituteInPlace scripts/build.js \
        --replace-fail "await createAllZips(DIST_DIR);" "console.log('Skipping ZIP bundle creation for Nix package');"

    substituteInPlace scripts/build.js \
        --replace-fail "await createProviderZip(openAiPluginRoot, DIST_DIR, 'openai-plugin');" "console.log('Skipping OpenAI plugin ZIP creation for Nix package');"
  '';

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    bun run build:skills

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -d $out/share/impeccable
    cp -r dist $out/share/impeccable/

    runHook postInstall
  '';

  meta = {
    description = "Cross-provider design skills and commands for LLM-powered development tools";
    homepage = "https://github.com/pbakaus/impeccable";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = bun.meta.platforms;
  };
})
