{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage {
  pname = "sem";
  version = "0.21.0-unstable-2026-07-18";

  src = fetchFromGitHub {
    owner = "Ataraxy-Labs";
    repo = "sem";
    rev = "11675d121d834104cf62d47b1968b8caa337be08";
    hash = "sha256-wiu3OY2iAj45+vwNGiCoOOhAlLA+xJdoGX/+KRAhmjQ=";
  };

  sourceRoot = "source/crates";

  cargoHash = "sha256-0B947V49LLT3oZDXtYJFarDvZrynrE3PV9X4pTqc7z4=";

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
