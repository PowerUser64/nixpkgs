{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, gdb
, gdb-binary ? "${lib.getExe gdb}"
, enableGefExtras ? false
, python3
, bintools-unwrapped
, file
, ps
, git
, coreutils
}:

let
  pythonDeps = with python3.pkgs; [
    keystone-engine
    unicorn
    capstone
    ropper
  ] ++ lib.optionals enableGefExtras [
    pygments
    requests
    rpyc
  ];

  pythonPath = with python3.pkgs; makePythonPath pythonDeps;

  gefVersion = "2024.06";

  gef-extras = stdenv.mkDerivation rec {
    name = "gef-extras";
    version = gefVersion;
    src = fetchFromGitHub {
      owner = "hugsy";
      repo = name;
      rev = "2025.01";
      hash = "sha256-ZBn8sOAR2togY90MzvwZNKtZDT3WmESrfI9mjOfyUM0=";
    };
    installPhase = ''
      set -x
      cp -r . $out
    '';
  };

in
stdenv.mkDerivation rec {
  pname = "gef";
  version = gefVersion;

  src = fetchFromGitHub {
    owner = "hugsy";
    repo = "gef";
    rev = version;
    sha256 = "sha256-fo8hC2T2WDcG0MQffPm2QBPR89EPiqctkUJC40PeyWg=";
  };

  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase =
    # bash
    ''
      mkdir -p $out/share/gef
      cp gef.py $out/share/gef
      makeWrapper ${gdb-binary} $out/bin/gef \
      --add-flags "-q -x $out/share/gef/gef.py" \
      --set NIX_PYTHONPATH ${pythonPath} \
      --prefix PATH : ${lib.makeBinPath [
      python3
      bintools-unwrapped # for readelf
      file
      ps
      ]} '' + lib.optionalString enableGefExtras
      # Add flags from the gef-extras installer script
      # https://github.com/hugsy/gef/blob/f9f80450dc17ffd573362b73fdff0a71044de503/scripts/gef-extras.sh#L41-L48
      # bash
      ''  --add-flags -ex --add-flags "'pi gef.config[\"context.layout\"] += \" syscall_args\"'" \
          --add-flags -ex --add-flags "'pi gef.config[\"context.layout\"] += \" libc_function_args\"'" \
          --add-flags -ex --add-flags "'gef config gef.extra_plugins_dir ${gef-extras}/scripts'" \
          --add-flags -ex --add-flags "'gef config pcustom.struct_path ${gef-extras}/structs'" \
          --add-flags -ex --add-flags "'gef config syscall-args.path ${gef-extras}/syscall-tables'" \
          --add-flags -ex --add-flags "'gef config context.libc_args True'" \
          --add-flags -ex --add-flags "'gef config context.libc_args_path \"${gef-extras}/glibc-function-args\"'"
      '';

  nativeCheckInputs = [
    gdb
    file
    ps
    git
    python3
  ] ++ pythonDeps;

  checkPhase = ''
    # Skip some tests that require network access.
    sed -i '/def test_cmd_shellcode_get(self):/i \ \ \ \ @unittest.skip(reason="not available in sandbox")' tests/runtests.py
    sed -i '/def test_cmd_shellcode_search(self):/i \ \ \ \ @unittest.skip(reason="not available in sandbox")' tests/runtests.py

    # Patch the path to /bin/ls.
    sed -i 's+/bin/ls+${coreutils}/bin/ls+g' tests/runtests.py

    # Run the tests.
    make test
  '';

  meta = with lib; {
    description = "Modern experience for GDB with advanced debugging features for exploit developers & reverse engineers";
    mainProgram = "gef";
    homepage = "https://github.com/hugsy/gef";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ freax13 ];
  };
}
