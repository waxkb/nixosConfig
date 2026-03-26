{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";
  programs.git = {
    settings = {
      user = {
        name = "waxkb";
        email = "maxwellr2028@gmail.com";
      };
      init.defaultBranch = "main";
    };
    enable = true;
  };
  # 1. Create the template file so the agent knows HOW to write the key
  home.file.".ssh/github_infisical.tmpl".text = ''
    {{- with secret "PrivateMainsshKey" -}}
    {{ .Value }}
    {{- end -}}
  '';

  # 2. Tell NixOS to run the Infisical Agent as a background service
  systemd.user.services.infisical-agent = {
    Unit = {
      Description = "Infisical Agent for SSH Keys";
      After = [ "network.target" ];
    };
    Service = {
      # Replace 'YOUR_PROJECT_ID' with the ID from your Infisical dashboard URL
      ExecStart = "${pkgs.infisical}/bin/infisical agent --env=dev --path=/ssh-keys --template-path=${config.home.homeDirectory}/.ssh/github_infisical.tmpl --output-path=${config.home.homeDirectory}/.ssh/github_infisical";
      Restart = "always";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # 3. Tell Git to use this specific key for GitHub
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        identityFile = "~/.ssh/github_infisical";
      };
    };
  };
}
