{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  pname = "skillshare";
  version = "0.20.20";

  sources = {
    "x86_64-darwin" = fetchurl {
      url = "https://github.com/runkids/skillshare/releases/download/v${version}/skillshare_${version}_darwin_amd64.tar.gz";
      hash = "sha256-oLhXbs2NXtJHvaqhiwrVnJPsI6rizOfcePW2aj8Hqog=";
    };

    "aarch64-darwin" = fetchurl {
      url = "https://github.com/runkids/skillshare/releases/download/v${version}/skillshare_${version}_darwin_arm64.tar.gz";
      hash = "sha256-FdzUUGHScLdWnfEaBIlROeYOOtm6k6pG3N0/wiL7M8M=";
    };

    "x86_64-linux" = fetchurl {
      url = "https://github.com/runkids/skillshare/releases/download/v${version}/skillshare_${version}_linux_amd64.tar.gz";
      hash = "sha256-IiQILCDzakgwJXhWw5NNq0foHRjVddCgKw1kSCFrLDI=";
    };

    "aarch64-linux" = fetchurl {
      url = "https://github.com/runkids/skillshare/releases/download/v${version}/skillshare_${version}_linux_arm64.tar.gz";
      hash = "sha256-A29cZeYDpo1urjMcf1sdsvWTHsClORPcUatS0t6QvoQ=";
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
