{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  bun,
  nodejs,
  writableTmpDirAsHomeHook,
  makeWrapper,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "uipro-cli";
  version = "2.10.2-unstable-2026-07-06";

  src = fetchFromGitHub {
    owner = "nextlevelbuilder";
    repo = "ui-ux-pro-max-skill";
    rev = "12b486b22e67f5d887962ef8351c1ac863bfaeb9";
    hash = "sha256-Ryn7bpIkoTui14m5rntV5n0uhsw9pZ053AhjOnSoTXg=";
  };

  sourceRoot = "${finalAttrs.src.name}/cli";

  node_modules = stdenvNoCC.mkDerivation {
    pname = "${finalAttrs.pname}-node_modules";
    inherit (finalAttrs) src version;
    sourceRoot = "${finalAttrs.src.name}/cli";

    impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
      "GIT_PROXY_COMMAND"
      "SOCKS_SERVER"
    ];

    nativeBuildInputs = [
      bun
      writableTmpDirAsHomeHook
    ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
      bun install \
          --cpu="*" \
          --frozen-lockfile \
          --ignore-scripts \
          --no-cache \
          --no-progress \
          --os="*"
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/node_modules
      cp -R ./node_modules $out
      runHook postInstall
    '';

    dontFixup = true;
    outputHash = "sha256-C32er9XYfnYrfjLgIaq/vdfpYA2QDRi22YlrQzzqhpQ=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  nativeBuildInputs = [
    bun
    nodejs
    writableTmpDirAsHomeHook
    makeWrapper
  ];

  configurePhase = ''
    runHook preConfigure
    cp -R ${finalAttrs.node_modules}/node_modules .
    patchShebangs node_modules
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    bun run build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/uipro-cli
    cp -r dist assets package.json $out/lib/node_modules/uipro-cli/

    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/uipro \
      --add-flags "$out/lib/node_modules/uipro-cli/dist/index.js"

    runHook postInstall
  '';

  meta = with lib; {
    description = "CLI to install UI/UX Pro Max skill for AI coding assistants";
    homepage = "https://github.com/nextlevelbuilder/ui-ux-pro-max-skill";
    license = licenses.mit;
    mainProgram = "uipro";
    maintainers = [ ];
    platforms = bun.meta.platforms;
  };
})
