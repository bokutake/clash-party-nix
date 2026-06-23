{ pkgs ? import <nixpkgs> { } }:

pkgs.callPackage ./clash-party.nix { }
