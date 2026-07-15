{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage {
  pname = "sem";
  version = "0.21.0-unstable-2026-07-14";

  src = fetchFromGitHub {
    owner = "Ataraxy-Labs";
    repo = "sem";
    rev = "488549b4f8ed13626814520a7fedefc824cfc095";
    hash = "sha256-m9LJ2RdM4q6+JszPMR0KPaDlQOXHS81bxKJXDVN+X0s=";
  };

  sourceRoot = "source/crates";

  cargoHash = "sha256-0/nTkOrGIWDJ3b1LbcIjR4yIZ8s/e5CcbgJ4m1AfxBs=";

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
