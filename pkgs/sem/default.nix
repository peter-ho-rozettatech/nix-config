{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage {
  pname = "sem";
  version = "0.20.0-unstable-2026-07-08";

  src = fetchFromGitHub {
    owner = "Ataraxy-Labs";
    repo = "sem";
    rev = "96e72cc9b120537e10f2df3d661cde0217946dae";
    hash = "sha256-uoQWT0lr63x+QB+YBqTmZSmZKs9t0palJ4yZagcMbv8=";
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
