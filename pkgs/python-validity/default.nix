{
  lib,
  fetchFromGitHub,
  findutils,
  gobject-introspection,
  innoextract,
  python3Packages,
  wrapGAppsNoGuiHook,
}:

python3Packages.buildPythonPackage rec {
  pname = "python-validity";
  version = "0.15";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "uunicorn";
    repo = "python-validity";
    rev = "a6bbc21dce7b8b3c3cd92378a0b2579a2fb45920";
    hash = "sha256-RflX7e6nd11pSg8mh3mjZiVGNUSdox/SKXHR4W+PhMs=";
  };

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsNoGuiHook
  ];

  propagatedBuildInputs = with python3Packages; [
    cryptography
    dbus-python
    pygobject3
    pyusb
    pyyaml
  ];

  postInstall = ''
    install -D -m 644 debian/python3-validity.service \
      $out/lib/systemd/system/python3-validity.service
    substituteInPlace $out/lib/systemd/system/python3-validity.service \
      --replace /usr/lib/python-validity "$out/lib/python-validity"

    chmod +x $out/lib/python-validity/dbus-service
  '';

  dontWrapGApps = true;
  makeWrapperArgs = [
    "\${gappsWrapperArgs[@]}"
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      findutils
      innoextract
    ])
  ];

  postFixup = ''
    wrapPythonProgramsIn "$out/lib/python-validity" "$out ''${pythonPath[*]}"
  '';

  doCheck = false;

  meta = {
    description = "Validity fingerprint sensor DBus driver";
    homepage = "https://github.com/uunicorn/python-validity";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
}
