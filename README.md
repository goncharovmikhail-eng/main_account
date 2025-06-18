## main_account.sh
`main_account.sh` is the primary script for setting up the main workstation environment.  
It updates the system, optionally runs dependent scripts, installs and upgrades Ansible, and installs Zsh.  
It also sets up paths for aliases and SSH keys, and ensures `ssh-agent` starts automatically in new shell sessions.

SSH keys are generated automatically:
- `~/.ssh/goncharov_work`
- `~/.ssh/my`
- `~/.ssh/test`

### Dependent scripts:
- `docker-install.sh` (alternative to **https://github.com/goncharovmikhail-eng/docker_worker_install**)
- `s3cmd.sh`
- `setup-ssh-keys.sh`
- `yc_install.sh`

---

## user.sh

The `user.sh` script is designed to add public SSH keys, configure the SSH service, and disable password-based login for a specified user.  
It’s especially useful for setting up a fresh machine.

### Logic:
- `-U [name_user]` — if the specified user does not exist, the script creates the user without setting a password.
- Creates the `.ssh` directory (if it doesn’t exist) and the `authorized_keys` file (if it doesn’t exist).  
  Sets permissions to 700 and assigns correct ownership to the user.
- Edits `/etc/ssh/sshd_config` to:
  - Disable password authentication
  - Enable public key authentication
  - Set the SSH port to 22  
  Then restarts the SSH service.
- Edits `visudo` policy:
  - Adds the user to the `wheel` group
  - Enables passwordless `sudo` access
- Sets SELinux to **permissive** mode.
- Updates system packages.

**Important:** Must be run as `root`. There is a check inside the script to enforce this.  
Supported OS: Debian-based and Red Hat-based systems.

## 🔐 form_for_passwords
A password manager that uses an encrypted **GPG** file.

**Problem**: Accessing credentials stored in a knowledge base was inconvenient, and storing them in plain `.txt` files was insecure.
**Solution**: A convenient form-based interface with built-in functions for interaction and password decryption, including support for GPG password caching.

For more details, see the `README.md` file inside the `form_for_passwords` directory.
