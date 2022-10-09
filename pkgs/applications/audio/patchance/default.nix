{ hicolor-icon-theme,
  python310Packages.pyqt5,
  }:

with lib;

stdenv.mkDerivation rec {
  pname = "patchance";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "Houston4444";
    repo = pname;
    rev = "v${version}";
    sha256 = "";
  };

  nativeBuildInputs = [
    python3Packages.wrapPython pkg-config which wrapQtAppsHook
  ];

  # pythonPath = with python3Packages; [
  #   rdflib pyliblo
  # ] ++ optional withFrontend pyqt5;

  buildInputs = [
    libsForQt5.qt5.qttools
  ]

  # propagatedBuildInputs = pythonPath;

  enableParallelBuilding = true;

  installFlags = [ "PREFIX=$(out)" ];

  dontWrapQtApps = true;

  /*
  postFixup = ''
    # Also sets program_PYTHONPATH and program_PATH variables
    wrapPythonPrograms
    wrapPythonProgramsIn "$out/share/carla/resources" "$out $pythonPath"

    find "$out/share/carla" -maxdepth 1 -type f -not -name "*.py" -print0 | while read -d "" f; do
      patchPythonScript "$f"
    done
    patchPythonScript "$out/share/carla/carla_settings.py"
    patchPythonScript "$out/share/carla/carla_database.py"

    for program in $out/bin/*; do
      wrapQtApp "$program" \
        --prefix PATH : "$program_PATH:${which}/bin" \
        --set PYTHONNOUSERSITE true
    done

    find "$out/share/carla/resources" -maxdepth 1 -type f -not -name "*.py" -print0 | while read -d "" f; do
      wrapQtApp "$f" \
        --prefix PATH : "$program_PATH:${which}/bin" \
        --set PYTHONNOUSERSITE true
    done
  '';
  */

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
