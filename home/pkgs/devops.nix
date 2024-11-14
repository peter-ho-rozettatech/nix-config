{ pkgs, ... }:
{
  home.packages = with pkgs; [
    awscli2
    terraform
    terragrunt
    terraform-docs
    terraform-compliance
  ];
}
