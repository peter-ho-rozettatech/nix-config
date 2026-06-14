{
  lib,
  stdenv,
  cacert,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpm_10,
  pnpmConfigHook,
  nodejs,
  makeWrapper,
  runCommand,
}:
let
  pnpmCaBundle = runCommand "react-doctor-pnpm-ca-bundle" { } ''
    cat ${cacert}/etc/ssl/certs/ca-bundle.crt ${../../certs/aikido-l4-mitm-ca.localhost.pem} > $out
  '';
in
stdenv.mkDerivation (finalAttrs: {
  pname = "react-doctor";
  version = "2.2.2-unstable-2026-06-25";

  src = fetchFromGitHub {
    owner = "millionco";
    repo = "react-doctor";
    rev = "849580c7e2ba9c0b55244f9bdecd5a133e76b0e1";
    hash = "sha256-YGx8JowV5jR9u6QLj1xTZxVBnaDNElH3pDEeayMbDDg=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm_10
    makeWrapper
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-ZTIBVOkNj18+3aL9U4dj8d8AqPAzmYXOuqW2Lk27Rbc=";
    NODE_EXTRA_CA_CERTS = "${pnpmCaBundle}";
    npm_config_cafile = "${pnpmCaBundle}";
    pnpm_config_cafile = "${pnpmCaBundle}";
    SSL_CERT_FILE = "${pnpmCaBundle}";
  };

  buildPhase = ''
    runHook preBuild

    pnpm --dir packages/oxlint-plugin-react-doctor run build
    pnpm --dir packages/core run build
    pnpm --dir packages/api run build
    pnpm --dir packages/react-doctor run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    workspace="$out/lib/node_modules/react-doctor-workspace"
    mkdir -p "$workspace"

    cp -r LICENSE node_modules package.json packages pnpm-workspace.yaml "$workspace/"

    makeWrapper ${nodejs}/bin/node "$out/bin/react-doctor" \
      --add-flags "$workspace/packages/react-doctor/bin/react-doctor.js"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Diagnose and fix React codebases for security, performance, correctness, accessibility, bundle-size, and architecture issues";
    homepage = "https://github.com/millionco/react-doctor";
    license = licenses.mit;
    mainProgram = "react-doctor";
    maintainers = [ ];
  };
})
