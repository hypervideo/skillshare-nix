{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  pname = "skillshare";
  version = "0.25.9";

  sources = {
    "x86_64-darwin" = fetchurl {
      url = "https://github.com/runkids/skillshare/releases/download/v${version}/skillshare_${version}_darwin_amd64.tar.gz";
      hash = "sha256-6WETAo1nF94FnhjdB8zJaeylrWWyzhtDNJBjtvCAj00=";
    };

    "aarch64-darwin" = fetchurl {
      url = "https://github.com/runkids/skillshare/releases/download/v${version}/skillshare_${version}_darwin_arm64.tar.gz";
      hash = "sha256-u/oOw4sfSEVDB93pl4IsdhZoMSCike7+mwVMfUm9wMM=";
    };

    "x86_64-linux" = fetchurl {
      url = "https://github.com/runkids/skillshare/releases/download/v${version}/skillshare_${version}_linux_amd64.tar.gz";
      hash = "sha256-N4J+2x+WWJ++001kOnjxJcQ5odPJGYqxoMT5UqSRv5U=";
    };

    "aarch64-linux" = fetchurl {
      url = "https://github.com/runkids/skillshare/releases/download/v${version}/skillshare_${version}_linux_arm64.tar.gz";
      hash = "sha256-cyHPyWFudQ6sJCb3XFUfCWwR3K3b27KDGm+32Wz1C/k=";
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
