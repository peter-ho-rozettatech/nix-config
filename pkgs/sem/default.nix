{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage {
  pname = "sem";
  version = "0.21.0-unstable-2026-07-10";

  src = fetchFromGitHub {
    owner = "Ataraxy-Labs";
    repo = "sem";
    rev = "cfd34b1e4d314f59eac83a56b523fa2e2de333e9";
    hash = "sha256-HgF1ZslXg8Ayi3etvfZMJgUsxivpcCCVY27qSm45oWU=";
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
