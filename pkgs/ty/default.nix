{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  # nativeBuildInputs
  installShellFiles,
  buildPackages,
  # versionCheckHook,
  python3Packages,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ty";
  version = "unstable-2025-07-08";

  src = fetchFromGitHub {
    owner = "astral-sh";
    repo = "ty";
    rev = "232a5d6895e84c952d6b83495e0a1b6923a544f1";
    fetchSubmodules = true;
    sha256 = "17gb39vp02arl2wpj199dbr3rfrv7iwrn9dlpfdqq15bf75zg6lp";
  };

  cargoRoot = "ruff";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  cargoBuildFlags = [ "--package=ty" ];

  useFetchCargoVendor = true;
  cargoHash = "sha256-+FQPqZaqu9YGv3W5i0HZkFMHM84DKf0dLGm5f3zdIy0=";

  nativeBuildInputs = [ installShellFiles ];

  # `ty`'s tests use `insta-cmd`, which depends on the structure of the `target/` directory,
  # and also fails to find the environment variable `$CARGO_BIN_EXE_ty`, which leads to tests failing.
  # Instead, we specify the path ourselves and forgo the lookup.
  # As the patches occur solely in test code, they have no effect on the packaged `ty` binary itself.
  #
  # `stdenv.hostPlatform.rust.cargoShortTarget` is taken from `cargoSetupHook`'s `installPhase`,
  # which constructs a path as below to reference the built binary.
  preCheck = ''
    export CARGO_BIN_EXE_ty="$PWD"/target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/ty
  '';

  cargoTestFlags = [
    "--package=ty" # CLI and file-watching
    "--package=ty_python_semantic" # core type checking tests
    "--package=ty_test" # test framework tests
  ];

  # nativeInstallCheckInputs = [ versionCheckHook ];
  # versionCheckProgramArg = "--version";
  doInstallCheck = true;

  postInstall = lib.optionalString (stdenv.hostPlatform.emulatorAvailable buildPackages) (
    let
      emulator = stdenv.hostPlatform.emulator buildPackages;
    in
    ''
      installShellCompletion --cmd ty \
        --bash <(${emulator} $out/bin/ty generate-shell-completion bash) \
        --fish <(${emulator} $out/bin/ty generate-shell-completion fish) \
        --zsh <(${emulator} $out/bin/ty generate-shell-completion zsh)
    ''
  );

  passthru = {
    tests.ty-python = python3Packages.ty;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Extremely fast Python type checker and language server, written in Rust";
    homepage = "https://github.com/astral-sh/ty";
    changelog = "https://github.com/astral-sh/ty/blob/main/CHANGELOG.md";
    license = [ lib.licenses.mit ];
    mainProgram = "ty";
    maintainers = [ lib.maintainers.bengsparks ];
  };
})
