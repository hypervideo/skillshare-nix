{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  pname = "skillshare";
  version = "0.25.4";

  sources = {
    "x86_64-darwin" = fetchurl {
      url = "https://github.com/runkids/skillshare/releases/download/v${version}/skillshare_${version}_darwin_amd64.tar.gz";
      hash = "sha256-Vu26E3DgbF9DOKBAJGWY18HwmXSqnWlG11n/8VfbRDI=";
    };

    "aarch64-darwin" = fetchurl {
      url = "https://github.com/runkids/skillshare/releases/download/v${version}/skillshare_${version}_darwin_arm64.tar.gz";
      hash = "sha256-yVSzd5cGpM/clWHZi8NTGF54nxTnf2YdvWjy9uVexNg=";
    };

    "x86_64-linux" = fetchurl {
      url = "https://github.com/runkids/skillshare/releases/download/v${version}/skillshare_${version}_linux_amd64.tar.gz";
      hash = "sha256-wrD6fyqWVVIPBs6XhCVD338R4I962+UGRhRYyqdcfUQ=";
    };

    "aarch64-linux" = fetchurl {
      url = "https://github.com/runkids/skillshare/releases/download/v${version}/skillshare_${version}_linux_arm64.tar.gz";
      hash = "sha256-HHJJydElGeZaMSBwYJ9Lj7lvH0tNPMeNUr/a61TgU/s=";
    };
  };

  src =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "${pname}: unsupported system ${stdenvNoCC.hostPlatform.system}");
in

stdenvNoCC.mkDerivation {
  inherit pname version src;

  sourceRoot = ".";

  unpackPhase = ''
    runHook preUnpack
    tar -xzf "$src"
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 skillshare "$out/bin/skillshare"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Sync skills, agents, rules, commands, and prompts across AI CLI tools";
    homepage = "https://skillshare.runkids.cc";
    license = licenses.mit;
    mainProgram = "skillshare";
    platforms = builtins.attrNames sources;
  };
}
