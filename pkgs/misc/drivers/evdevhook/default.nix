{ lib
, pkg-config
, libudev-zero
, cmake
, stdenv
, fetchFromGitHub
, nlohmann_json
, libevdev
, glibmm
, zlib
}:
stdenv.mkDerivation {
  name = "evdevhook";
  version = "Nov 21, 2021";
  src = fetchFromGitHub {
    owner = "v1993";
    repo = "evdevhook";
    rev = "e82287051ceb78753193a0206c1fff048fe7987f";
    sha256 = "sha256-af9B04k8+7nO3rhsYx223N+fpcVjExi9KDXF+b719/8=";
  };
  cmakeBuildType = "Release";
  nativeBuildInputs = [ pkg-config cmake libudev-zero ];
  # cmakeFlags = [ "-DCMAKE_INSTALL_PREFIX=$(out)" ];
  buildInputs = [
    nlohmann_json
    libevdev
    glibmm
    zlib
  ];
  meta = with lib; {
    description = "libevdev based DSU/cemuhook joystick server.";
    maintainer = with maintainers; [ poweruser64 ];
    platforms = platforms.linux;
    license = licenses.gpl3;
  };
}
