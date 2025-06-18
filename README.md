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
`user.sh` is designed to add public SSH keys, configure the SSH service, and disable password-based login for a user.  
It’s especially useful for setting up a fresh machine.

### Logic:
- `-U [name_user]` — if the specified user doesn’t exist, the script creates it without a password.
- Creates the `.ssh` directory (if missing) and the `authorized_keys` file (if missing), sets proper permissions (700), and assigns ownership based on the user specified.
- Modifies `/etc/ssh/sshd_config` to:
  - Disable password authentication
  - Enable public key authentication
  - Set the SSH port to 22
  - Then restarts the SSH service.
- At the end, the script calls `visudo` to manually edit sudo privileges. This step still requires automation.

**Important:** Must be run as `root`. There is a check inside the script to enforce this.

## 🔐 form_for_passwords
A password manager that uses an encrypted **GPG** file.

**Problem**: Accessing credentials stored in a knowledge base was inconvenient, and storing them in plain `.txt` files was insecure.
**Solution**: A convenient form-based interface with built-in functions for interaction and password decryption, including support for GPG password caching.

For more details, see the `README.md` file inside the `form_for_passwords` directory.
