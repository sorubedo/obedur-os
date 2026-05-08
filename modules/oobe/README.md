# OOBE Module

This module provides the infrastructure for an Out-Of-Box Experience (OOBE) on first boot.

## How it works
1. Creates a dedicated `oobe` user.
2. Configures PAM and Polkit for the `oobe` user to perform administrative tasks (user creation).
3. Sets up a systemd service (`oobe.service`) that runs a specified command on TTY7.
4. The service is triggered only if `/var/.oobe-done` does not exist.

## Configuration
The module expects an `exec` property and optional `env` variables.

**Important:** This module does **not** provide the wizard application itself. The maintainer must provide an executable (e.g., at `/usr/bin/oobe-wizard`) and call it via the `exec` command or through a desktop environment's startup mechanism.

### Example
```yaml
- type: oobe
  source: local
  exec: dbus-run-session niri
  env:
    NIRI_CONFIG: /usr/share/obedur-dotfiles/niri/oobe.kdl
```

In this example, Niri would be configured to launch the actual wizard (e.g., `ghostty -e /usr/bin/oobe-wizard`).

## Polkit Rules
The `oobe` user is granted permission to run the following commands via `pkexec` without a password:
- `/usr/bin/useradd`
- `/usr/bin/chpasswd`
- `/usr/bin/touch`

The wizard script should use these to create the permanent user and mark OOBE as complete by touching `/var/.oobe-done`.
