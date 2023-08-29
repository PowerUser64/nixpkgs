{ lib
, stdenv
, pkg-config
, fetchFromGitHub
, qt5
, python3Packages
, which
, libjack2
}:

stdenv.mkDerivation rec {
  pname = "patchance";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "Houston4444";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-LzhJPdRXAbqyq1e0kMCp3QbvJu2Dx6oQEy8Gon7QnMg=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
    python3Packages.python
    python3Packages.pyqt5 # for pyrcc5
    python3Packages.wrapPython
    qt5.qtbase
    qt5.qttools
    which
    qt5.wrapQtAppsHook
    libjack2
  ];

  buildInputs = [
    python3Packages.python # for $out/share/patchance/src/patchance.py shebang
    libjack2
  ];

  pythonPath = [
    python3Packages.pyqt5
    python3Packages.pyqt5_sip
    #python3Packages.pyliblo
  ];

  dontWrapQtApps = true;
  dontWrapPythonPrograms = true;

  makeFlags = [
    "PREFIX=$(out)"
  ];

  postInstall = ''
    rm $out/bin/patchance # a bash script which won't wrap properly
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
    buildPythonPath "$out $pythonPath"

    makeWrapper ${python3Packages.python.interpreter} $out/bin/patchance \
      ''${makeWrapperArgs[@]} \
      --prefix PYTHONPATH : "$PYTHONPATH" \
      --add-flags $out/share/patchance/src/patchance.py
  '';

  meta = with lib; {
    homepage = "https://github.com/Houston4444/Patchance";
    description = "Jack Patchbay GUI";
    longDescription = ''
      Patchance is one more JACK patchbay GUI for GNU/Linux systems.
      It is a direct alternative to Catia or Patchage.
    '';
    license = licenses.gpl2;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
