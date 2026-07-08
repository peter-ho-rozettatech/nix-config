{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "mermaid-ascii";
  version = "1.4.0-unstable-2026-07-07";

  src = fetchFromGitHub {
    owner = "AlexanderGrooff";
    repo = "mermaid-ascii";
    rev = "823db562a4439e342541643bbd5cb7d75c930e8e";
    hash = "sha256-BAO0WnKbkHTkoZRZFtPuMiJvOcfBndeoShEym1QrFzs=";
  };

  vendorHash = "sha256-aB9sbTtlHbptM2995jizGFtSmEIg3i8zWkXz1zzbIek=";

  meta = with lib; {
    description = "Render Mermaid graphs inside your terminal";
    homepage = "https://github.com/AlexanderGrooff/mermaid-ascii";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "mermaid-ascii";
  };
}
