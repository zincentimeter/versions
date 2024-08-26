# `versions`: Specify software versions in Nix, elegantly and efficiently

`versions` is a Nix Flake project **planned** to provide simple and
friendly interface for specifying software versions in NixOS,
home-manager, etc.

## Motivation

There are many existing projects and workarounds perform similar
functionalities, mainly fall into two categories described below,

1. Override the new package.

   You can always simply override an existing package to use information
   of an earlier package. Nevertheless it is not elegant to put such a
   big attrset in your package list and sometimes they just fails to
   compile. Let alone that we cannot utilize NixOS's cache at all.

   Although it ...
   - comes with no dependency or extra module required and thus
     simplistic and good for fundamentalism,
   but it ...
   - is unable to use NixOS's build cache, and,
   - may fail compiling, as the toolchain changes.

2. Use an older `nixpkgs`.
   - [`nix_version_search_cli`](https://github.com/jeff-hykin/nix_version_search_cli)
     is a CLI tool for finding/using versions of nix packages,
     it generates a `nix-shell` command or nix expression that can be put
     in your configurations.
   - [`DevBox`](https://www.jetify.com/devbox/docs/installing_devbox/)
     is a CLI tool to create shell environments with the functionality of
     specifying versions of programs. It cannot be integrated into Nix or Nix Flake
     and must be used in a stand-alone fashion.
   - [`Nix Package Versions`](https://github.com/lazamar/nix-package-versions)
     is a Web app providing searching of existing nixpkgs and useful Nix snippets
     generated to apply in your configuration.
   
   Given so many utilities allowing us to load an older nixpkgs, a manual
   copy-and-paste operation must be done by yourself. Your Nix files will be left
   with many meaningless nixpkgs input with its clueless commit number.

## Targets

So, why not give these shit task to a module? A module that can...
- just take your specified version and the package name or the derivative itself,
- query the locally/remotely cached database to find out the specified nixpkgs
  commit,
- download the corresponding nixpkgs commit and utilize the NixOS prebuilt cache.

Basically, `versions` is planned to allow you to write such configuration ...
```nix
{ lib, ... }
# ...
{
  environment.systemPackages = with pkgs; [
    wget
    (lib.version "0.9.0" neovim)
  ]
  # ...
  programs.git.package = lib.version "2.44.0" git
}
```
<details>
<summary>instead of something painful.</summary>
  
```nix
{ lib, ... }
# ...
let
pkgs = import (builtins.fetchGit {
  name = "neovim-old-revision";
  url = "https://github.com/NixOS/nixpkgs/";
  ref = "refs/heads/nixpkgs-unstable";
  rev = "8cad3dbe48029cb9def5cdb2409a6c80d3acfe2e";
}) {};
neovim_0_9_0 = pkgs.neovim;
in
{
  environment.systemPackages = with pkgs; [
    wget
    neovim_0_9_0
  ]
  # ...
  programs.git.package = (import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/0c19708cf035f50d28eb4b2b8e7a79d4dc52f6bb.tar.gz";
  })).git
}
```
  
</details>

Currently, `versions` is planned to simply give an abbreviation
of these painful expression. But it looks forward to further
improvements like introducing git-based nixpkgs repo to speed
up the introducing of nixpkgs, also preventing the
["1000 instances of nixpkgs" problem.](https://zimbatm.com/notes/1000-instances-of-nixpkgs)
