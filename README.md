
# Nexus Installation Script

This Bash script automates the installation and configuration of Nexus Repository Manager on Ubuntu systems. It simplifies the setup process by handling system updates, Java installation, user creation, Nexus download, and service configuration.

## Features

- Installs OpenJDK 8
- Creates a dedicated Nexus user
- Downloads and extracts the latest Nexus Repository Manager
- Configures Nexus JVM options
- Sets up a systemd service for Nexus
- Provides clear feedback during the installation process

## Prerequisites

- A clean installation of Ubuntu 20.04 or later.
- Sudo privileges.

## Usage

1. Clone this repository:

   ```bash
   git clone https://github.com/arynishere/exus-install-ubuntu.git
   cd exus-install-ubuntu
   ```

2. Make the script executable:

   ```bash
   chmod +x install_nexus.sh
   ```

3. Run the script:

   ```bash
   ./install_nexus.sh
   ```

4. After the installation completes, Nexus will be running as a systemd service. You can manage it using the following commands:

   - Start Nexus: `sudo systemctl start nexus`
   - Stop Nexus: `sudo systemctl stop nexus`
   - Enable Nexus on boot: `sudo systemctl enable nexus`
   - Check Nexus status: `sudo systemctl status nexus`

## Configuration

The script creates a configuration file for Nexus at `/opt/nexus/bin/nexus.vmoptions`. You can customize the JVM options by editing this file.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

If you have suggestions for improvements or new features, feel free to open an issue or submit a pull request.

## Acknowledgments

- [Sonatype Nexus Repository](https://www.sonatype.com/nexus-repository-oss)
- [OpenJDK](https://openjdk.java.net/)
```

