{ lib
, stdenv
, fetchFromGitHub
, libjack2
, cmake
, pkg-config
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zinc";
  version = "2023-04-27";

  src = fetchFromGitHub {
    owner = "DISTRHO";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    sha256 = lib.fakeHash;
    fetchSubmodules = true;
  };

  patchPhase = ''
    patchShebangs ./dpf/utils/generate-ttl.sh
  '';

  nativeBuildInputs = [ pkg-config cmake ];
  buildInputs = [ libjack2 ];

  # installPhase = ''
  #   install -dD bin/ninjas2.lv2 $out/lib/lv2/ninjas2.lv2
  #   install -D bin/ninjas2-vst.so  $out/lib/vst/ninjas2-vst.so
  #   install -D bin/ninjas2 $out/bin/ninjas2
  # '';

  # makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    homepage = "https://github.com/DISTRHO/Zinc";
    description = "Utility audio plugin for getting sound out of plugin hosts into JACK";
    license = with licenses; [ isc ];
    maintainers = with maintainers; [ PowerUser64 ];
    platforms = platforms.linux;
  };
})
