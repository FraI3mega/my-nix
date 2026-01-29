# My Pgks REpo


## Usage

### Setting Up

1. Fork this repository.
2. Begin adding packages to the `pkgs/by-name` directory. Follow the same
   approach as adding packages in `nixpkgs`. Similar to [RFC140], packages added
   in this directory will be automatically discovered.
   - Create a new directory for each package.
   - Inside each directory, create a `package.nix` file.
3. Optionally, you can add packages directly to the `pkgs/` directory and
   manually update the bindings in the `imports/pkgs-all.nix` file.

