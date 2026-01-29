{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    import-tree.url = "github:vic/import-tree";
    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";
    make-shell.url = "github:nicknovitski/make-shell";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    orca-slicer-src = {
      url = "github:/OrcaSlicer/OrcaSlicer";
      flake = false;
    };
    awww.url = "git+https://codeberg.org/LGFae/awww";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    # https://flake.parts/module-arguments.html
    flake-parts.lib.mkFlake { inherit inputs; } (
      top@{
        config,
        withSystem,
        moduleWithSystem,
        ...
      }:
      {
        imports = [
          # Optional: use external flake logic, e.g.
          # inputs.foo.flakeModules.default
        ];
        flake = {
          # Put your original flake attributes here.
        };
        systems = [
          # systems for which you want to build the `perSystem` attributes
          "x86_64-linux"
          # ...
        ];
        perSystem =
          { config, pkgs, ... }:
          {
            # Recommended: move all package definitions here.
            # e.g. (assuming you have a nixpkgs input)
            # packages.foo = pkgs.callPackage ./foo/package.nix { };
            # packages.bar = pkgs.callPackage ./bar/package.nix {
            #   foo = config.packages.foo;
            # };
            # pkgsDirectory = ../pkgs/by-name;

            packages.awww = inputs.awww.packages.${pkgs.stdenv.hostPlatform.system}.awww.overrideAttrs (old: {
              buildFeatures = [
                "all-formats"
              ];
              buildInputs = old.buildInputs ++ [ pkgs.dav1d ];

            });

            packages.orca-slicer-nightly = pkgs.orca-slicer.overrideAttrs (old: {
              src = inputs.orca-slicer-src;
              # add libnoise as you already do and append a tiny patch to link imgcodecs
              buildInputs = old.buildInputs ++ [ pkgs.libnoise ];
              patches = (old.patches or [ ]) ++ [
                # Add a small patch that links opencv_imgcodecs (provides cv::imread)
                (pkgs.writeText "fix-opencv-imgcodecs.patch" ''
                  --- a/src/libslic3r/CMakeLists.txt
                  +++ b/src/libslic3r/CMakeLists.txt
                  @@ -557,8 +557,9 @@ target_link_libraries(libslic3r
                           libigl
                           libnest2d
                           miniz
                  -        opencv_core
                  -        opencv_imgproc
                  +        opencv_core
                  +        opencv_imgproc
                  +        opencv_imgcodecs
                       PRIVATE
                           ''${CMAKE_DL_LIBS}
                           ''${EXPAT_LIBRARIES}
                '')
              ];
              cmakeFlags = (old.cmakeFlags or [ ]) ++ [
                "-DUSE_SYSTEM_LIBNOISE=ON"
                "-DLIBNOISE_USE_BUNDLED=OFF"
                "-DLIBNOISE_LIBRARY_RELEASE=${pkgs.libnoise}/bin/libnoise.so"
                "-DLIBNOISE_INCLUDE_DIR=${pkgs.libnoise}/include"
              ];

              # If the derivation uses `version` in meta or in the build, override it here:
              version = "nightly";
            });
          };
      }
    );
}
