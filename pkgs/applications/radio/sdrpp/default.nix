{ stdenv, lib, fetchFromGitHub, cmake, pkg-config
, libX11, glfw, glew, fftwFloat, volk, AppKit, zstd
# Sources
, airspy_source ? false, airspy
, airspyhf_source ? false, airspyhf
, bladerf_source ? false, libbladeRF
, file_source ? true
, hackrf_source ? false, hackrf
, limesdr_source ? false, limesuite
, sddc_source ? false
, rtl_sdr_source ? true, rtl-sdr, libusb1
, rtl_tcp_source ? true
, sdrplay_source ? false, sdrplay
, soapy_source ? true, soapysdr
, spyserver_source ? false
, plutosdr_source ? false, libiio, libad9361
# Sinks
, audio_sink ? true, rtaudio
, portaudio_sink ? false, portaudio
, network_sink ? true
# Decoders
, falcon9_decoder ? false
, m17_decoder ? true, codec2
, meteor_demodulator ? true
, radio ? true
, weather_sat_decoder ? false
# Misc
, discord_presence ? false
, frequency_manager ? true
, recorder ? true
, rigctl_server ? true
}:

stdenv.mkDerivation rec {
  pname = "sdrpp";
  version = "nightly";

  src = fetchFromGitHub {
    owner = "AlexandreRouma";
    repo = "SDRPlusPlus";
    rev = "b89fdba433cf6aa0dab424a06974a0b45abf6c4a";
    hash = "sha256-4sJhODH46ueb2bt8RGxVBmbTbsmZ9ARuPkZ13oaSgYY=";
  };

  patches = [ ./runtime-prefix.patch ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "/usr/share" "share" \
      --replace "set(CMAKE_INSTALL_PREFIX" "#set(CMAKE_INSTALL_PREFIX"
    substituteInPlace decoder_modules/m17_decoder/src/m17dsp.h \
      --replace "codec2.h" "codec2/codec2.h"
  '';

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ glfw glew fftwFloat volk zstd ]
    ++ lib.optional stdenv.isDarwin AppKit
    ++ lib.optional stdenv.isLinux libX11
    ++ lib.optional airspy_source airspy
    ++ lib.optional airspyhf_source airspyhf
    ++ lib.optional bladerf_source libbladeRF
    ++ lib.optional hackrf_source hackrf
    ++ lib.optional limesdr_source limesuite
    ++ lib.optionals rtl_sdr_source [ rtl-sdr libusb1 ]
    ++ lib.optional sdrplay_source sdrplay
    ++ lib.optional soapy_source soapysdr
    ++ lib.optionals plutosdr_source [ libiio libad9361 ]
    ++ lib.optional audio_sink rtaudio
    ++ lib.optional portaudio_sink portaudio
    ++ lib.optional m17_decoder codec2;

  cmakeFlags = lib.mapAttrsToList (k: v: "-D${k}=${if v then "ON" else "OFF"}") {
    OPT_BUILD_AIRSPY_SOURCE = airspy_source;
    OPT_BUILD_AIRSPYHF_SOURCE = airspyhf_source;
    OPT_BUILD_BLADERF_SOURCE = bladerf_source;
    OPT_BUILD_FILE_SOURCE = file_source;
    OPT_BUILD_HACKRF_SOURCE = hackrf_source;
    OPT_BUILD_LIMESDR_SOURCE = limesdr_source;
    OPT_BUILD_SDDC_SOURCE = sddc_source;
    OPT_BUILD_RTL_SDR_SOURCE = rtl_sdr_source;
    OPT_BUILD_RTL_TCP_SOURCE = rtl_tcp_source;
    OPT_BUILD_SDRPLAY_SOURCE = sdrplay_source;
    OPT_BUILD_SOAPY_SOURCE = soapy_source;
    OPT_BUILD_SPYSERVER_SOURCE = spyserver_source;
    OPT_BUILD_PLUTOSDR_SOURCE = plutosdr_source;
    OPT_BUILD_AUDIO_SINK = audio_sink;
    OPT_BUILD_PORTAUDIO_SINK = portaudio_sink;
    OPT_BUILD_NETWORK_SINK = network_sink;
    OPT_BUILD_NEW_PORTAUDIO_SINK = portaudio_sink;
    OPT_BUILD_FALCON9_DECODER = falcon9_decoder;
    OPT_BUILD_M17_DECODER = m17_decoder;
    OPT_BUILD_METEOR_DEMODULATOR = meteor_demodulator;
    OPT_BUILD_RADIO = radio;
    OPT_BUILD_WEATHER_SAT_DECODER = weather_sat_decoder;
    OPT_BUILD_DISCORD_PRESENCE = discord_presence;
    OPT_BUILD_FREQUENCY_MANAGER = frequency_manager;
    OPT_BUILD_RECORDER = recorder;
    OPT_BUILD_RIGCTL_SERVER = rigctl_server;
  };

  env.NIX_CFLAGS_COMPILE = "-fpermissive";

  hardeningDisable = lib.optional stdenv.cc.isClang "format";

  meta = with lib; {
    description = "Cross-Platform SDR Software";
    homepage = "https://github.com/AlexandreRouma/SDRPlusPlus";
    license = licenses.gpl3Only;
    platforms = platforms.unix;
    maintainers = with maintainers; [ sikmir ];
  };
}
