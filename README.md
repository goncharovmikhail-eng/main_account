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
- `-u [name_user]` — if the specified user does not exist, the script creates the user without setting a password.
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

## Script for Migrating Virtual Machines to Yandex Cloud
This script allows you to perform one of three VM migration options in Yandex Cloud:

1. **Move a VM between folders** (`move_instance`)
2. **Import via snapshot** (`import_snapshot`)
3. **Import via image** (`import_image`)

## Requirements
- Installed and configured [Yandex Cloud CLI](https://cloud.yandex.com/en/docs/cli/quickstart)
- Sufficient access rights:
  - `compute.editor` role in both folders
  - `vps.editor` role to move the VM

### Usage
If you haven't used main_account.sh:
```bash
sudo mv mv_vm_yc.sh /usr/local/bin/mv_vm_yc
mv_vm_yc
```
If you used it then `mv_vm_yc` is already available.

## d — Utility for running Docker containers in interactive mode && p — the same utility for Podman
d and p are convenient CLI scripts for quickly running, saving, or removing containers.
Useful for isolation, testing images, and working with temporary environments.

🔧 Installation
Copy the script d.sh to a system path and make it executable:
```bash
sudo cp d.sh /usr/local/bin/d
sudo chmod +x /usr/local/bin/d
```
Now the d command is available from anywhere in the terminal.
Usage:
```bash
d [-d] [-k] [-n <name>] <docker-image>
```
| Flag        | Description                                               |
| ----------- | --------------------------------------------------------- |
| `-d`        | Run disposable container: container is removed after exit |
| `-k`        | Keep the container running after exit                     |
| `-n <name>` | Specify container name (default: `box`)                   |
The order of flags and arguments does not matter.

🧠 Default behavior
If neither -d nor -k is specified:
The container state is saved as a snapshot image (docker commit)
After exit, the container is stopped (docker stop)

💡 Examples
Run a disposable Ubuntu container:
```bash
d -d ubuntu
```
Run and save state with container stopped after exit:
```bash
d ubuntu
```
Run container named devbox, keep it running after exit:

```bash
d -k -n devbox ubuntu
```

🛠️ Dependencies
- bash
- docker (without sudo or configured via Docker group)

**If you want, I can help translate or extend for the p Podman script as well!**
