{ pkgs, ... }:
{
  home.packages = with pkgs; [
    terraform
    terragrunt
    terraform-docs
    terraform-compliance
  ];
}
