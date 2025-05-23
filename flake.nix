{
  description = "Static site generator using Deno and Lume";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            deno
            nodejs # Often needed for some Lume plugins
          ];

          shellHook = ''
            echo "Deno + Lume development environment"
            echo "Deno version: $(deno --version | head -n1)"
            echo ""
            echo "Available commands:"
            echo "  deno task serve    - Start development server"
            echo "  deno task build    - Build static site"
            echo "  nix build          - Build site with Nix"
          '';
        };

        # Build the static site
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "lume-site";
          version = "1.0.0";

          src = ./.;

          nativeBuildInputs = with pkgs; [
            deno
            nodejs
          ];

          configurePhase = ''
            export DENO_DIR="$TMPDIR/deno"
            export DENO_INSTALL_ROOT="$out"

            # Allow network access for Deno to download dependencies
            export DENO_NO_PROMPT=1
          '';

          buildPhase = ''
            runHook preBuild

            echo "Installing Lume and dependencies..."
            deno run -A https://deno.land/x/lume/install.ts

            echo "Building static site..."
            deno task build || deno run -A _config.ts

            runHook postBuild
          '';

          installPhase = ''
                      runHook preInstall

                      mkdir -p $out

                      # Copy built site (Lume typically outputs to _site by default)
                      if [ -d "_site" ]; then
                        cp -r _site/* $out/
                      elif [ -d "dist" ]; then
                        cp -r dist/* $out/
                      elif [ -d "build" ]; then
                        cp -r build/* $out/
                      else
                        echo "Warning: No output directory found. Copying all files."
                        cp -r * $out/ || true
                      fi

                      # Create a simple index.html if none exists
                      if [ ! -f "$out/index.html" ]; then
                        cat > $out/index.html << EOF
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="utf-8">
                <title>Lume Static Site</title>
            </head>
            <body>
                <h1>Welcome to your Lume site!</h1>
                <p>This site was built with Nix, Deno, and Lume.</p>
            </body>
            </html>
            EOF
                      fi

                      runHook postInstall
          '';

          # Allow network access during build for Deno
          __noChroot = true;

          meta = with pkgs.lib; {
            description = "Static site built with Lume";
            platforms = platforms.all;
          };
        };

        # Additional package for serving the site locally
        packages.serve = pkgs.writeShellScriptBin "serve-site" ''
          ${pkgs.python3}/bin/python -m http.server 8000 -d ${self'.packages.default}
        '';

        # Apps for easy access
        apps.default = {
          type = "app";
          program = "${self'.packages.serve}/bin/serve-site";
        };

        apps.build = {
          type = "app";
          program = "${pkgs.writeShellScript "build-site" ''
            cd "$PWD"
            ${pkgs.deno}/bin/deno task build
          ''}";
        };
      };

      flake = {
        # Template for bootstrapping new Lume projects
        templates.default = {
          path = ./template;
          description = "A basic Lume static site template";
        };
      };

      # Supported systems
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    };
}
