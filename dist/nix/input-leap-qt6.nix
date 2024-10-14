{
  lib,
  pkgs,
  stdenv,
  cmake,

  withLibei ? true,

  avahi,
  curl,
  libICE,
  libSM,
  libX11,
  libXdmcp,
  libXext,
  libXinerama,
  libXrandr,
  libXtst,
  openssl,
  pkg-config,
  qt6,
  wrapGAppsHook3,
  gtest,
  gmock,
}:
let
  isDarwin = lib.hasSuffix "-darwin" pkgs.system;
in
stdenv.mkDerivation rec {
  pname = "input-leap";
  version = "unstable-git";

  src = lib.cleanSource ../../.;

  nativeBuildInputs = [
    pkg-config
    cmake
    wrapGAppsHook3
    qt6.wrapQtAppsHook
    qt6.qttools
  ];
  buildInputs =
    [
      curl
      qt6.qtbase
      (avahi.override { withLibdnssdCompat = true; })
      openssl
      libX11
      libXext
      libXtst
      libXinerama
      libXrandr
      libXdmcp
      libICE
      libSM
      gtest
      gmock
    ]
    ++ lib.optionals (withLibei && !isDarwin) (
      with pkgs;
      [
        libei
        libportal
        qt6.qtwayland
      ]
    );

  cmakeFlags = [
    "-DINPUTLEAP_USE_EXTERNAL_GTEST=ON"
  ] ++ lib.optional (withLibei && !isDarwin) "-DINPUTLEAP_BUILD_LIBEI=ON";

  dontWrapGApps = true;
  preFixup = ''
    qtWrapperArgs+=(
      "''${gappsWrapperArgs[@]}"
        --prefix PATH : "${lib.makeBinPath [ openssl ]}"
    )
  '';

  postFixup = ''
    substituteInPlace $out/share/applications/io.github.input_leap.InputLeap.desktop \
      --replace "Exec=input-leap" "Exec=$out/bin/input-leap"
  '';

  meta = {
    description = "Open-source KVM software";
    longDescription = ''
      Input Leap is software that mimics the functionality of a KVM switch, which historically
      would allow you to use a single keyboard and mouse to control multiple computers by
      physically turning a dial on the box to switch the machine you're controlling at any
      given moment. Input Leap does this in software, allowing you to tell it which machine
      to control by moving your mouse to the edge of the screen, or by using a keypress
      to switch focus to a different system.
    '';
    homepage = "https://github.com/input-leap/input-leap";
    license = lib.licenses.gpl2Plus;
    mainProgram = "input-leap";
    maintainers = with lib.maintainers; [
      kovirobi
      phryneas
      twey
      shymega
    ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
