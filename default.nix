let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };

  poetry2nix = import
    (pkgs.applyPatches {
      name = "poetry2nix-patched";
      src = sources.poetry2nix;
      patches = [
        ./poetry2nix-remove-problematic-overrides.diff
      ];
    })
    {
      inherit pkgs;
      inherit (pkgs) poetry;
    };
in
(poetry2nix.mkPoetryApplication {
  src = sources.karonte;

  # don't build or install; we just want the dependencies
  buildPhase = ":";
  installPhase = ":";

  pyproject = ./pyproject.toml;
  poetrylock = ./poetry.lock;

  # necessary to fix "UnicodeDecodeError: 'ascii' codec can't decode byte 0xc3
  # in position 1: ordinal not in range(128)" when bootstrapping pip
  __isBootstrap = true;
  python = pkgs.python2;

  overrides = poetry2nix.overrides.withDefaults (self: super: {
    # z3-solver = super.z3-solver.overridePythonAttrs ({ ... }: {
    #   # https://github.com/Z3Prover/z3/issues/1688
    #   # https://github.com/Z3Prover/z3/commit/2d5dd802386d78117d5ed9ddcbf8bc22ab3cb461
    #   postPatch = ''
    # sed 's@unsigned \* values() const { return m_permutation; }@unsigned * values() const { return m_permutation.c_ptr(); }@' \
    #   -i core/src/util/lp/permutation_matrix.h
    #   '';
    # });

    # claripy = super.claripy.overridePythonAttrs ({ ... }: {
    #   postPatch = ''
    #     # substituteInPlace claripy/backends/backend_z3.py --replace "/opt/python/lib" "${pkgs.z3.lib}/z3/lib"
    #     # substituteInPlace claripy/backends/backend_z3.py --replace 'raise ClaripyZ3Error("Unable to find %s", z3_library_file)' 'z3.init("${pkgs.z3.lib}/lib/libz3.so")'
    #   '';
    # });

    cle = super.cle.overridePythonAttrs ({ ... }: {
      postPatch = ''
        substituteInPlace cle/backends/idabin.py --replace "except ImportError:" "except:"
      '';
    });

    angr = super.angr.overridePythonAttrs ({ ... }: {
      nativeBuildInputs = with pkgs; [
        pkg-config
      ];

      buildInputs = with pkgs; [
        glib
      ];
    });

    archinfo = super.archinfo.overridePythonAttrs ({ ... }: {
      postPatch = ''
        sed '193s/_pyvex is not None/False/' -i archinfo/arch.py
      '';
    });
  });
}).dependencyEnv
