with (import <nixpkgs> {});
dvtm.overrideAttrs (oldAttrs: rec {
  src = ./.;
})
