{
  pkgs,
  lib,
  ...
}:

let
  bashFiles = "\\.(sh|bash)$";
in
{
  packages = with pkgs; [
    betterleaks
    bubblewrap
    deadnix
    git
    just
    nixfmt
    prettier
    shfmt
    shellcheck
    statix
    taplo
  ];

  git-hooks.hooks = {
    nixfmt.enable = true;
    statix.enable = true;
    deadnix.enable = true;
    prettier = {
      enable = true;
      files = "\\.(md|json|ya?ml)$";
    };
    taplo.enable = true;
    shfmt = {
      enable = true;
      files = bashFiles;
      types = lib.mkForce [ "file" ];
      args = [
        "-ln"
        "bash"
      ];
    };
    shellcheck = {
      enable = true;
      files = bashFiles;
      types = lib.mkForce [ "file" ];
      args = [ "--shell=bash" ];
    };
    betterleaks-commit = {
      enable = true;
      name = "Betterleaks staged secrets";
      entry = "${pkgs.betterleaks}/bin/betterleaks git --pre-commit --staged --redact --no-banner .";
      stages = [ "pre-commit" ];
      pass_filenames = false;
      always_run = true;
    };
    betterleaks-push = {
      enable = true;
      name = "Betterleaks pushed history";
      entry = "${pkgs.writeShellScript "check-pushed-secrets" ''
        exec ${pkgs.betterleaks}/bin/betterleaks git --redact --no-banner --log-opts="''${PRE_COMMIT_TO_REF:?Missing pushed commit}" .
      ''}";
      stages = [ "pre-push" ];
      pass_filenames = false;
      always_run = true;
    };
  };

  enterTest = ''
    just fmt-check
    just lint
  '';
}
