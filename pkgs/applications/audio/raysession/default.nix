{ lib, fetchFromGitHub, buildPythonApplication, libjack2, pydbus, pyliblo, pyqt5, which, bash, qt5 }:

buildPythonApplication rec {
  pname = "raysession";
  version = "0.13.1";

  src = fetchFromGitHub {
    owner = "Houston4444";
    repo = "RaySession";
    rev = "4ad4a130e6d9b158473ff53405714c16949c2a6d";
    sha256 = "sha256-dyMtQtbtn7xPaz1ADu0LqcVkCj2g4vT7PdDlmAo33LA=";
    fetchSubmodules = true;
  };

  postPatch = ''
    # Fix installation path of xdg schemas.
    substituteInPlace Makefile --replace '$(DESTDIR)/' '$(DESTDIR)$(PREFIX)/'
    # Do not wrap an importable module with a shell script.
    chmod -x src/daemon/desktops_memory.py
  '';

  format = "other";

  nativeBuildInputs = [
    pyqt5   # pyuic5 and pyrcc5 to build resources.
    qt5.qttools # lrelease to build translations.
    which   # which to find lrelease.
    qt5.wrapQtAppsHook
  ];
  buildInputs = [ libjack2 bash ];
  propagatedBuildInputs = [ pydbus pyliblo pyqt5 ];

  dontWrapQtApps = true; # The program is a python script.

  installFlags = [ "PREFIX=$(out)" ];

  makeWrapperArgs = [
    "--prefix" "LD_LIBRARY_PATH" ":" (lib.makeLibraryPath [ libjack2 ])
  ];

  postFixup = ''
    wrapPythonProgramsIn "$out/share/raysession/src" "$out $pythonPath"
    for file in $out/bin/*; do
      wrapQtApp "$file"
    done
  '';

  meta = with lib; {
    homepage = "https://github.com/Houston4444/RaySession";
    description = "Session manager for Linux musical programs";
    license = licenses.gpl2;
    maintainers = with maintainers; [ orivej ];
    platforms = platforms.linux;
  };
}
