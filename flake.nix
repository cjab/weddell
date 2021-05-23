{
  description = "An Elixir client for Google Pub/Sub";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, utils, ... }:
  let
    name = "weddell";
  in
  utils.lib.eachDefaultSystem
    (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlay = [];
        };
        buildInputs = with pkgs; [
          elixir
          rebar3
        ];
        nativeBuildInputs = with pkgs; [];
        buildEnvVars = {};
      in rec {
        #packages.${name} =
        ## `nix build`
        #defaultPackage = packages.${name};
        ## `nix run`
        #apps.${name} = utils.lib.mkApp {
        #  inherit name;
        #  drv = packages.${name};
        #};
        #defaultApp = apps.${name};
        # `nix develop`
        devShell = pkgs.mkShell
          {
            inherit nativeBuildInputs;
            buildInputs =  with pkgs; [
              direnv
              google-cloud-sdk jre
            ] ++ buildInputs;
          } // buildEnvVars;
      }
    );
}
