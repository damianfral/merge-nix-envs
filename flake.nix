{
  description = "Nix function to combine environments.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }@inputs:

  let
    system = "x86_64-linux";
    pkgs   = import nixpkgs
    { inherit system;
      overlays = [ self.overlay ];
    };

    mergeNixEnvs = envs :
      pkgs.mkShell (
        builtins.foldl' ( a: b: {
          buildInputs                 = a.buildInputs ++ b.buildInputs;
          nativeBuildInputs           = a.nativeBuildInputs ++ b.nativeBuildInputs;
          propagatedBuildInputs       = a.propagatedBuildInputs ++ b.propagatedBuildInputs;
          propagatedNativeBuildInputs = a.propagatedNativeBuildInputs ++ b.propagatedNativeBuildInputs;
          shellHook                   = a.shellHook + "\n" + b.shellHook;
        })
        (pkgs.mkShell {})
        envs);

  in

    { overlay = final : prev : { inherit mergeNixEnvs;   }; };
}
