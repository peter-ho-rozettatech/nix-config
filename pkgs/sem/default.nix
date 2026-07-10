{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage {
  pname = "sem";
  version = "0.20.0-unstable-2026-07-10";

  src = fetchFromGitHub {
    owner = "Ataraxy-Labs";
    repo = "sem";
    rev = "cf87e50ac251cdf8788982e6f549a6c561b07a38";
    hash = "sha256-0r7qRzMkTguePm3MLsIW8DSkErNbHEvUNmumBIq2JbQ=";
  };

  sourceRoot = "source/crates";

  cargoHash = "sha256-ctJsmTH55VDuofezBRbg8FLmr6c714FuBbyQY0jLlPs=";

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
