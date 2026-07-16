{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "kubectl-prof";
  version = "2.2.0-unstable-2026-07-15";

  src = fetchFromGitHub {
    owner = "josepdcs";
    repo = "kubectl-prof";
    rev = "08ba8ec65bdfafd5f9e0b07a75f87e61cb5f3eae";
    hash = "sha256-NckHEhE+hAJ2fwqgZ7pmY0jIE1Lf9QalZE1UH/KDlko=";
  };

  vendorHash = "sha256-Ckt/nN66dUIDovnhDhimLyJm2aB79A87cxpYDv/bxd8=";

  subPackages = [ "cmd/cli" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/josepdcs/kubectl-prof/internal/cli/version.semver=${version}"
  ];

  postInstall = ''
    mv $out/bin/cli $out/bin/kubectl-prof
  '';

  meta = with lib; {
    description = "Kubectl plugin to profile applications on Kubernetes with minimum overhead";
    homepage = "https://github.com/josepdcs/kubectl-prof";
    license = licenses.asl20;
    maintainers = [ ];
    mainProgram = "kubectl-prof";
  };
}
