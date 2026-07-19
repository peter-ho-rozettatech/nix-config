{
  lib,
  pkgs,
  uv2nix,
  pyproject-nix,
  pyproject-build-systems,
}:
let
  # Tracks main (no stable release pinning). Bump `rev`, `version` date and
  # `hash` together when following upstream.
  version = "0.33.0-unstable-2026-07-19";

  src = pkgs.fetchFromGitHub {
    owner = "repowise-dev";
    repo = "repowise";
    rev = "6713ece5d3c6081d9b2c7d2e2ec49b0daf49442a";
    hash = "sha256-7EjVVedi7YQHoA+nZmdbPzPoLxvCn+WscO2nf3mqZLI=";
  };

  # Ingest the uv workspace (pyproject.toml + uv.lock) from the fetched source.
  workspace = uv2nix.lib.workspace.loadWorkspace {
    workspaceRoot = src;
  };

  # Prefer prebuilt wheels so the ~200 dependencies (incl. scipy, numpy, pyarrow,
  # lancedb, tree-sitter grammars) don't have to be built from source.
  pyprojectOverlay = workspace.mkPyprojectOverlay {
    sourcePreference = "wheel";
  };

  # Runtime-only fixes for packages that misbehave under uv2nix. Kept minimal;
  # add per-package overrides here if a future dependency bumps need one.
  pyprojectOverrides = _final: _prev: { };

  pythonSet =
    (pkgs.callPackage pyproject-nix.build.packages {
      python = pkgs.python312;
    }).overrideScope
      (
        lib.composeManyExtensions [
          pyproject-build-systems.overlays.wheel
          pyprojectOverlay
          pyprojectOverrides
        ]
      );

  # Self-contained virtualenv holding repowise and its runtime dependencies.
  # `deps.default` selects only the main dependencies (no dev/postgres/graph-extra groups).
  venv = pythonSet.mkVirtualEnv "repowise-env" workspace.deps.default;
in
# Expose only the `repowise` CLI on PATH instead of the whole virtualenv
# (which would otherwise also shadow python/pip/etc.).
pkgs.runCommand "repowise-${version}"
  {
    nativeBuildInputs = [ pkgs.makeWrapper ];
    passthru = {
      inherit pythonSet workspace venv;
    };
    meta = with lib; {
      description = "Codebase intelligence for AI and humans: dependency graph, git analytics, code health, and an MCP server";
      homepage = "https://github.com/repowise-dev/repowise";
      license = licenses.agpl3Only;
      mainProgram = "repowise";
      platforms = platforms.unix;
    };
  }
  ''
    mkdir -p $out/bin
    makeWrapper ${lib.getExe' venv "repowise"} $out/bin/repowise
  ''
