{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  pname = "skillshare";
  version = "0.31.0";

  sources = {
    "x86_64-darwin" = fetchurl {
      url = "https://github.com/runkids/skillshare/releases/download/v${version}/skillshare_${version}_darwin_amd64.tar.gz";
      hash = "sha256-oxYRoEtq6VRaR+mSrynz180oFgtsv6eTLwpnz0id9nc=";
    };

    "aarch64-darwin" = fetchurl {
      url = "https://github.com/runkids/skillshare/releases/download/v${version}/skillshare_${version}_darwin_arm64.tar.gz";
      hash = "sha256-vpjCh/dhP91kLF9GL2LjuBtzqTU+o1CLtZN8F13RjI0=";
    };

    "x86_64-linux" = fetchurl {
      url = "https://github.com/runkids/skillshare/releases/download/v${version}/skillshare_${version}_linux_amd64.tar.gz";
      hash = "sha256-opQ9Xf7uwLYmpxxxDS/B27+sVWOG/bjPS4svRIXoN8A=";
    };

    "aarch64-linux" = fetchurl {
      url = "https://github.com/runkids/skillshare/releases/download/v${version}/skillshare_${version}_linux_arm64.tar.gz";
      hash = "sha256-k4uz4gA5C1Xl+ZbuYp35yGC8iY6rcF/VIlPb94/r6FI=";
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
