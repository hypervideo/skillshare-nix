{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  pname = "skillshare";
  version = "0.20.9";

  sources = {
    "x86_64-darwin" = fetchurl {
      url = "https://github.com/runkids/skillshare/releases/download/v${version}/skillshare_${version}_darwin_amd64.tar.gz";
      hash = "sha256-thbJCuxnAhvJPAPkS8Iq03SDGEuhPJeHVEL6/3Qb/80=";
    };

    "aarch64-darwin" = fetchurl {
      url = "https://github.com/runkids/skillshare/releases/download/v${version}/skillshare_${version}_darwin_arm64.tar.gz";
      hash = "sha256-m0RtAXZhOjKnp8OExs+g0uhX8V6mMMqWiCr/TlxqMJM=";
    };

    "x86_64-linux" = fetchurl {
      url = "https://github.com/runkids/skillshare/releases/download/v${version}/skillshare_${version}_linux_amd64.tar.gz";
      hash = "sha256-R55LrPImNLf64wflFs2tW9VnA3ViCmNfAWAKaDZxrf0=";
    };

    "aarch64-linux" = fetchurl {
      url = "https://github.com/runkids/skillshare/releases/download/v${version}/skillshare_${version}_linux_arm64.tar.gz";
      hash = "sha256-8JiQv4rnFBxbqmOG192g0zZROD8TE4aMsgxF1icyFMs=";
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
