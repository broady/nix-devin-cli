{
  description = "Devin CLI — packaged for Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      manifest = builtins.fromJSON (builtins.readFile ./manifest.json);
      version = manifest.version;

      supportedSystems = builtins.attrNames manifest.platforms;
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          platform = manifest.platforms.${system};

          devin = pkgs.stdenvNoCC.mkDerivation {
            pname = "devin";
            inherit version;

            src = pkgs.fetchurl {
              url = platform.url;
              hash = platform.hash;
            };

            sourceRoot = ".";

            nativeBuildInputs = nixpkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
              pkgs.autoPatchelfHook
            ];

            unpackPhase = ''
              tar xzf $src
            '';

            installPhase = ''
              mkdir -p $out/bin
              install -m755 bin/devin $out/bin/devin

              if [ -d share/man ]; then
                mkdir -p $out/share
                cp -r share/man $out/share/
              fi
            '';

            dontStrip = true;

            meta = {
              description = "Devin CLI — AI software engineering agent";
              homepage = "https://devin.ai";
              platforms = supportedSystems;
              mainProgram = "devin";
            };
          };
        in
        {
          inherit devin;
          default = devin;
        }
      );
    };
}
