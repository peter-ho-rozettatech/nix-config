{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage {
  pname = "sem";
  version = "0.21.0-unstable-2026-07-16";

  src = fetchFromGitHub {
    owner = "Ataraxy-Labs";
    repo = "sem";
    rev = "da0959ca173e66be5ad80c8a29cef0cd6881c133";
    hash = "sha256-EraE0MHkxMHMIDLoWW/yjwODiEI2lSNmSliO+m31C0c=";
  };

  sourceRoot = "source/crates";

  cargoHash = "sha256-SXudeIEpdLNm+g7zR3jkn2DWprtv7l0Xn+FIc57Ji8s=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  cargoBuildFlags = [
    "--package"
    "sem-cli"
    "--no-default-features"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Semantic version control CLI";
    homepage = "https://github.com/Ataraxy-Labs/sem";
    license = with licenses; [
      mit
      asl20
    ];
    mainProgram = "sem";
    platforms = platforms.unix;
  };
}
