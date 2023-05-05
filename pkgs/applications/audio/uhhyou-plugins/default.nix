{ lib
, stdenv
, pkg-config
, fetchFromGitHub
, gtkmm3
, libX11
, libxkbcommon
, pango
, xcbutil
, xcbutilkeysyms
, cmake
, cairo
, freetype
, xcbutilcursor
}:
stdenv.mkDerivation rec {
  pname = "uhhyou-plugins";
  version = "0.54.3";
  src = fetchFromGitHub {
    owner = "ryukau";
    repo = "VSTPlugins";
    rev = "UhhyouPlugins${version}";
    fetchSubmodules = true;
    sha256 = "sha256-1ePKVcONPnXf7BXcKfqALBk3jet55uPRYFwZTo1RSyw=";
  };

  nativeBuildInputs = [
    pkg-config
    xcbutilcursor
  ];
  buildInputs = [
    cairo
    cmake
    freetype
    gtkmm3
    libX11
    libxkbcommon
    pango
    xcbutil
    xcbutilkeysyms
  ];

  meta = with lib; {
    description = ''
      Uhhyou VST3 plugins. A collection of
      synthesizer and effect audio plugins.
    '';
    longDescription = ''
      Plugin list:
        Synthesizers:
          - ClangSynthh
          - CollidingCombSynth
          - CubicPadSynth
          - EnvelopedSine
          - FDNCymbal
          - IterativeSinCluster
          - LightPadSynth
          - MaybeSnare
          - MembraneSynth
          - SyncSawSynth
          - TrapezoidSynth
          - UltraSynth
          - WaveCymbal
        Effects:
          - AccumulativeRingMod
          - BasicLimiter
          - CombDistortion
          - EsPhaser
          - FDN64Reverb
          - FeedbackPhaser
          - L4Reverb
          - LatticeReverb
          - LongPhaser
          - MiniCliffEQ
          - NarrowingDelay
          - OrdinaryPhaser
          - ParallelComb
          - ParallelDetune
          - PitchShiftDelay
          - RingModSpacer
          - SevenDelay
          - UltrasonicRingMod
    '';
    homepage = "https://ryukau.github.io/VSTPlugins";
    license = licenses.gpl3;
    maintainers = [ maintainers.poweruser64 ];
    platforms = platforms.linux ++ platforms.darwin;
    broken = stdenv.isDarwin;
  };
}
