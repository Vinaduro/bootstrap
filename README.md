# bootstrap

Helper scripts for bringing up a fresh Linux install quickly.

Current target:
- CachyOS

Repo contents:
- cachyos-prereqs.sh
  - Installs the first required packages:
    - Bitwarden
    - git
    - yadm
    - openssh

- cachyos-yadm-clone.sh
  - Assumes Bitwarden desktop is installed, signed in, unlocked, and SSH agent is enabled
  - Creates temporary SSH config for the first GitHub clone
  - Verifies that GitHub SSH auth is using the Vinaduro account
  - Runs: yadm clone git@github.com:Vinaduro/dotfiles.git

Fresh CachyOS process:

1. Clone this bootstrap repo
   git clone git@github.com:Vinaduro/bootstrap.git
   cd bootstrap

2. Install prerequisites
   bash ./cachyos-prereqs.sh

3. Open Bitwarden desktop
   - Sign in
   - Unlock the vault
   - Go to Settings
   - Enable SSH agent

4. Clone the dotfiles repo with yadm
   bash ./cachyos-yadm-clone.sh

5. Preview the dotfiles bootstrap
   BOOTSTRAP_APPLY=0 ~/.config/yadm/bootstrap

6. Apply the dotfiles bootstrap
   BOOTSTRAP_APPLY=1 ~/.config/yadm/bootstrap

Notes:
- The first clone helper uses the Linux Bitwarden SSH agent socket:
  ~/.bitwarden-ssh-agent.sock
- The helper writes a temporary ~/.ssh/config for the first clone
- The helper refuses to continue unless GitHub SSH auth says:
  Hi Vinaduro!
- After the dotfiles are cloned, the managed SSH config from the dotfiles repo takes over

Dotfiles repo:
- git@github.com:Vinaduro/dotfiles.git
