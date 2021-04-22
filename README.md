# karonte-nix

This repository houses a Nix expression to make it easy to run
[karonte](https://github.com/ucsb-seclab/karonte).

Kept outside of Nixpkgs due to the need to patch poetry2nix in addition to the
extremely old (and undeclared) dependencies.

For your convenience, karonte has been copied in-tree.

Example usage:

```shell
nix-shell

# * ensure you have a firmware directory wherever you run karonte.py from, which
# can be obtained from the real karonte repo: https://github.com/ucsb-seclab/karonte/#dataset
# * extract the .tgz to a firmware directory

nix-shell$ cd karonte
nix-shell$ python2 tool/karonte.py config/d-link/dir_826.json

# if you want to rerun against the same config, you'll need to remove the
# associated pickles/parser/*/*.pk file
```
