#!/usr/bin/env bash
set -Eeuo pipefail

DOTFILES_REPO="git@github.com:Vinaduro/dotfiles.git"
BW_SSH_SOCK="${HOME}/.bitwarden-ssh-agent.sock"
PUBKEY_PATH="${HOME}/.ssh/github-vinaduro.pub"
SSH_CONFIG_PATH="${HOME}/.ssh/config"
EXPECTED_GITHUB_USER="Vinaduro"

log() {
  printf '[clone-helper] %s\n' "$*"
}

fail() {
  printf '[clone-helper] ERROR: %s\n' "$*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"
}

main() {
  need_cmd yadm
  need_cmd ssh

  export SSH_AUTH_SOCK="${BW_SSH_SOCK}"

  log "Using SSH_AUTH_SOCK=${SSH_AUTH_SOCK}"

  if [ ! -S "${SSH_AUTH_SOCK}" ]; then
    fail "Bitwarden SSH agent socket not found. Open Bitwarden desktop, sign in, unlock the vault, and enable Settings -> Enable SSH agent."
  fi

  install -d -m 700 "${HOME}/.ssh"

  if [ -f "${SSH_CONFIG_PATH}" ]; then
    cp -av "${SSH_CONFIG_PATH}" "${SSH_CONFIG_PATH}.pre-dotfiles-clone.bak.$(date +%F-%H%M%S)"
  fi

  cat > "${PUBKEY_PATH}" <<'KEYEOF'
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC3tvrDE6pp378Z0ZDYjnwnv2mjjsbC8cw8Yv8O5Pl6UEBcBXlX+RwiwbR36YF8Icf0spRorwKo7ENXJ80chV9iYc3EYJW1ho5vzv5d2+sNtwGGn4QNSuqoaU9fQ4KBAYY+Ojd+hZzbXaVPHjMr6fE1N1RBKkhG2zh4CIqFo1Y13gmOyg5i74o+9+shrlFWP8CRykxbF5mb4j2z5i2gYnKdDlwpEAUrOTburqqLNgu0TTQhc+ziBLv2x7LAydPKZcWWUXhh5srxflQdTEqe093Lh7yUp0uXJhuOoHvOCsx2ErDHoRb+poDaDTdaxpz9oXV0ELHnC1Ae6ZxyZW1y3xVQb4YsDsW4WdYRVcfk+SNjKPqjtmlDci6Rr+j/JmnCB/fvChKp/mNko0FejrPSJPI8i0SSBDiNKh8JTbdjFrdL7+kw6PcD7cKrluvwxk7WtwYM1O7dz7V9KaMU+q2SfMBy7O2UzpsHwrpSGk958/XYRWlxglCRHW7nJPwyFNBZO88= vinad@muon
KEYEOF
  chmod 644 "${PUBKEY_PATH}"

  cat > "${SSH_CONFIG_PATH}" <<EOFCONF
Host github.com
    User git
    IdentityAgent ${BW_SSH_SOCK}
    IdentityFile ${PUBKEY_PATH}
    IdentitiesOnly yes
EOFCONF
  chmod 600 "${SSH_CONFIG_PATH}"

  log "Testing GitHub SSH identity"
  SSH_TEST_OUTPUT="$(ssh -T git@github.com 2>&1 || true)"
  printf '%s\n' "${SSH_TEST_OUTPUT}"

  if ! grep -Fq "Hi ${EXPECTED_GITHUB_USER}!" <<<"${SSH_TEST_OUTPUT}"; then
    fail "GitHub SSH authentication did not match ${EXPECTED_GITHUB_USER}. Refusing to clone."
  fi

  log "Cloning dotfiles repo with yadm"
  yadm clone "${DOTFILES_REPO}"

  log "Done. Next suggested commands:"
  log "  BOOTSTRAP_APPLY=0 ~/.config/yadm/bootstrap"
  log "  BOOTSTRAP_APPLY=1 ~/.config/yadm/bootstrap"
}

main "$@"
