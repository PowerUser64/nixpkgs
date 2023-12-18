{ stdenv
, lib
, fetchFromGitHub
, fetchFromGitLab
, fetchurl
, SDL2
, alsa-lib
, appstream
, appstream-glib
, bash-completion
, boost
, breeze-icons
, carla
, chromaprint
, cmake
, curl
, dbus
, dconf
, faust2lv2
, fftw
, fftwFloat
, flex
, glib
, graphviz
, gtk4
, gtksourceview5
, guile
, help2man
, jq
, json-glib
, kissfft
, libadwaita
, libaudec
, libbacktrace
, libcyaml
, libdrm
, libepoxy
, libgtop
, libjack2
, libpanel
, libpulseaudio
, libsamplerate
, libsass
, libsndfile
, libsoundio
, libxml2
, libyaml
, lilv
, lv2
, meson
, ninja
, pandoc
, pcre
, pcre2
, pkg-config
, python3
, reproc
, rtaudio
, rtmidi
, rubberband
, sassc
, serd
, sord
, sox
, soxr
, sratom
, texi2html
, vamp-plugin-sdk
, wrapGAppsHook
, xdg-utils
, xxHash
, yyjson
, zix
, zstd
}:

let
  # As of zrythm-1.0.0-beta.4.5.62, Zrythm needs clap
  # https://github.com/falktx/carla/tree/main/source/includes/clap, which is
  # only available on Carla unstable as of 2023-02-24.
  carla-unstable = carla.overrideAttrs (oldAttrs: {
    pname = "carla";
    version = "unstable-2023-12-13";

    src = fetchFromGitHub {
      owner = "falkTX";
      repo = "carla";
      rev = "68bbca2711626835157ef3a55938566f2ee3fe87";
      hash = "sha256-yfVzZV8G4AUDM8+yS1finzobpOb1PUEPgBWFhEY5nFQ=";
    };
  });
in
stdenv.mkDerivation (finalAttrs: {
  pname = "zrythm";
  version = "unstable-2023-12-17";

  src = fetchFromGitLab {
    domain = "gitlab.zrythm.org";
    owner = "zrythm";
    repo = "zrythm";
    rev = "v${finalAttrs.version}";
    hash = "sha256-s/nfwZYdpYpfQ550RWl4oU02jYYm0fJ7EABduWx8WXo=";
  };

  nativeBuildInputs = [
    cmake
    help2man
    jq
    libaudec
    libxml2
    meson
    ninja
    pandoc
    pkg-config
    python3
    python3.pkgs.sphinx
    sassc
    texi2html
    wrapGAppsHook
  ];

  buildInputs = [
    SDL2
    alsa-lib
    appstream
    appstream-glib
    bash-completion
    boost
    breeze-icons
    carla-unstable
    chromaprint
    curl
    dbus
    dconf
    faust2lv2
    fftw
    fftwFloat
    flex
    glib
    graphviz
    (gtk4.overrideAttrs (finalAttrs: previousAttrs: {
      patches = [];
      version = "4.13.3";
      src = fetchurl {
        url = "mirror://gnome/sources/gtk/4.13/gtk-4.13.3.tar.xz";
        sha256 = "sha256-TwSkPnwoc2BHPzT8J7Yp9kh1eV87x+wngd9EnF5y8xI=";
      };
      buildInputs = previousAttrs.buildInputs ++ [ libdrm ];
    }))
    gtksourceview5
    guile
    json-glib
    kissfft
    libadwaita
    libbacktrace
    libcyaml
    libepoxy
    libgtop
    libjack2
    libpanel
    libpulseaudio
    libsamplerate
    libsass
    libsndfile
    libsoundio
    libyaml
    lilv
    lv2
    pcre
    pcre2
    reproc
    rtaudio
    rtmidi
    rubberband
    serd
    sord
    sox
    soxr
    sratom
    vamp-plugin-sdk
    xdg-utils
    xxHash
    yyjson
    zix
    zstd
  ];

  # Zrythm uses meson to build, but requires cmake for dependency detection.
  dontUseCmakeConfigure = true;

  dontWrapQtApps = true;

  mesonFlags = [
    "-Db_lto=false"
    "-Dcarla=enabled"
    "-Dcarla_binaries_dir=${carla-unstable}/lib/carla"
    "-Ddebug=true"
    "-Dfftw3_threads_separate=false"
    "-Dfftw3_threads_separate_type=library"
    "-Dfftw3f_separate=false"
    "-Dlsp_dsp=disabled"
    "-Dmanpage=true"
    "-Drtaudio=enabled"
    "-Drtmidi=enabled"
    "-Dsdl=enabled"
    # "-Duser_manual=true" # needs sphinx-intl
  ];

  NIX_LDFLAGS = ''
    -lfftw3_threads -lfftw3f_threads
  '';

  GUILE_AUTO_COMPILE = 0;

  dontStrip = true;

  postPatch = ''
    substituteInPlace meson.build \
      --replace "'/usr/lib', '/usr/local/lib', '/opt/homebrew/lib'" "'${fftw}/lib'"

    chmod +x scripts/meson-post-install.sh
    patchShebangs ext/sh-manpage-completions/run.sh scripts/generic_guile_wrap.sh \
      scripts/meson-post-install.sh tools/check_have_unlimited_memlock.sh
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix GSETTINGS_SCHEMA_DIR : "$out/share/gsettings-schemas/${finalAttrs.pname}-${finalAttrs.version}/glib-2.0/schemas/"
      --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS:${breeze-icons}/share"
    )
  '';

  meta = with lib; {
    homepage = "https://www.zrythm.org";
    description = "Automated and intuitive digital audio workstation";
    maintainers = with maintainers; [ tshaynik magnetophon yuu ];
    platforms = platforms.linux;
    license = licenses.agpl3Plus;
  };
})
