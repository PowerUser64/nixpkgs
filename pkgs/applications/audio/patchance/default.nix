{ lib
, pkg-config
, stdenv
, fetchFromGitHub
, hicolor-icon-theme
, liblo
, qtbase
, qttools
, python3
, python3Packages
, wrapQtAppsHook
, which
}:

with lib;

stdenv.mkDerivation rec {
  pname = "patchance";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "Houston4444";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-HCctWtdQYirkHznNjBbgXcwONAtNVqyg+wo4Nfwd15c=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
    python3
    python3Packages.pyqt5
    python3Packages.wrapPython
    qtbase
    qttools
    which
    wrapQtAppsHook
  ];

  # buildInputs = [
  #   python3Packages.pyqt5
  # ];

  pythonPath = with python3Packages; [
    pyliblo
    pyqt5
  ];

dontWrapQtApps=true;

  makeFlags = [
    "PREFIX=$(out)"
  ];

  meta = with lib; {
    homepage = "https://github.com/Houston4444/Patchance";
    description = "Jack Patchbay GUI";
    longDescription = ''
      Patchance is one more JACK patchbay GUI for GNU/Linux systems.
      It is a direct alternative to Catia or Patchage.
    '';
    license = licenses.gpl2;
    maintainers = [  ];
    platforms = platforms.linux;
  };
}
