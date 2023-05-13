{ lib, stdenv, fetchFromGitea }:

stdenv.mkDerivation rec {
  pname = "game-devices-udev";
  version = "0.21";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "fabiscafe";
    repo = pname;
    rev = version;
    hash = lib.fakeHash;
  };

  installPhase = ''
    runHook preInstall
    substituteInPlace * \
      --replace 'MODE=' "OWNER=\"${pname}\", MODE="
    mkdir -p $out/etc/udev/rules.d
    cp *.rules $out/etc/udev/rules.d/
    runHook postInstall
  '';

  meta = with lib; {
    description = ''
      udev rules for game devices (controllers, vr headsets, etc.)
      from many manufacturers, including Nintendo, Sony, Valve,
      Logitech, Razer, and 8bitdo.
    '';
    longDescription = ''
      Includes udev rules for game devices from the following manufacturers:

      - 8bitdo
      - ASTRO Gaming
      - Alpha Imaging Technology Corp.
      - Betop
      - HTC
      - Hori
      - Logitech
      - Mad Catz
      - Microsoft
      - NVIDIA
      - Nancon
      - Nintendo
      - PDP
      - Personal Communication Systems, Inc.
      - PowerA
      - Razer
      - Sony
      - Valve
      - Zeroplus Technology Corporation

      See project readme for a list of supported devices.
    '';
    license = licenses.mit;
    maintainers = with maintainers; [ PowerUser64 ];
    platforms = platforms.linux;
    homepage = "https://codeberg.org/fabiscafe/game-devices-udev";
  };
}
