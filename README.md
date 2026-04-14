# bootstrap

Helper scripts for bringing up a fresh Linux install quickly.

Current target:
- CachyOS

Best current process for fresh CachyOS

1. Install the minimum pre-clone tools
Run this first:

    sudo pacman -Syu --needed bitwarden git yadm openssh

2. Open Bitwarden desktop
In Bitwarden:
- sign in
- unlock the vault
- go to Settings
- enable SSH agent

3. Export the Bitwarden SSH agent socket for this session

    export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"

4. Create the temporary first-clone SSH config

    install -d -m 700 ~/.ssh

    cat > ~/.ssh/github-vinaduro.pub <<'KEYEOF'
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC3tvrDE6pp378Z0ZDYjnwnv2mjjsbC8cw8Yv8O5Pl6UEBcBXlX+RwiwbR36YF8Icf0spRorwKo7ENXJ80chV9iYc3EYJW1ho5vzv5d2+sNtwGGn4QNSuqoaU9fQ4KBAYY+Ojd+hZzbXaVPHjMr6fE1N1RBKkhG2zh4CIqFo1Y13gmOyg5i74o+9+shrlFWP8CRykxbF5mb4j2z5i2gYnKdDlwpEAUrOTburqqLNgu0TTQhc+ziBLv2x7LAydPKZcWWUXhh5srxflQdTEqe093Lh7yUp0uXJhuOoHvOCsx2ErDHoRb+poDaDTdaxpz9oXV0ELHnC1Ae6ZxyZW1y3xVQb4YsDsW4WdYRVcfk+SNjKPqjtmlDci6Rr+j/JmnCB/fvChKp/mNko0FejrPSJPI8i0SSBDiNKh8JTbdjFrdL7+kw6PcD7cKrluvwxk7WtwYM1O7dz7V9KaMU+q2SfMBy7O2UzpsHwrpSGk958/XYRWlxglCRHW7nJPwyFNBZO88= vinad@muon
    KEYEOF
    chmod 644 ~/.ssh/github-vinaduro.pub

    cat > ~/.ssh/config <<EOFCONF
    Host github.com
        User git
        IdentityAgent ${HOME}/.bitwarden-ssh-agent.sock
        IdentityFile ${HOME}/.ssh/github-vinaduro.pub
        IdentitiesOnly yes
    EOFCONF
    chmod 600 ~/.ssh/config

5. Verify GitHub auth is the right account

    ssh -T git@github.com

You want it to say:

    Hi Vinaduro! You've successfully authenticated, but GitHub does not provide shell access.

6. Clone the dotfiles repo with yadm

    yadm clone git@github.com:Vinaduro/dotfiles.git

7. Preview the post-clone bootstrap

    BOOTSTRAP_APPLY=0 ~/.config/yadm/bootstrap

8. Apply the post-clone bootstrap

    BOOTSTRAP_APPLY=1 ~/.config/yadm/bootstrap

What this should get you

After step 8, the current dotfiles bootstrap is intended to install:
- git
- yadm
- openssh
- fish
- eza
- curl
- ca-certificates
- gnupg
- starship
- wezterm
- rambox

Bitwarden is installed before clone in step 1.

Notes

- pacman -Syu already refreshes package databases and upgrades packages, so there is no separate APT-style update step in this process.
- Brave is not guaranteed by the current pacman branch because it depends on an AUR helper being available.
- The first-clone SSH config is temporary and only exists to get the initial GitHub/yadm clone working cleanly.
- After the dotfiles are cloned, the managed SSH config from the dotfiles repo takes over.

Repo contents

- cachyos-prereqs.sh
- cachyos-yadm-clone.sh

Dotfiles repo

- git@github.com:Vinaduro/dotfiles.git
