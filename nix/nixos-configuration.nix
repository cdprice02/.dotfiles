{ pkgs, system, username, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Define user for NixOS
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  programs.fish.enable = true;

  system.stateVersion = "23.11";
}
