# Dockerized Browser Launcher and Stopper Scripts

This repository contains two bash scripts designed to simplify the process of launching and managing Docker containers for various web browsers (Firefox, Chrome, Debian Browser, and TOR Browser) and establishing an SSH tunnel for remote access.

## Scripts

* **`start`**: This script provides a menu-driven interface to select and launch a Docker container for the desired browser. It then establishes an SSH tunnel, forwarding the VNC port for remote access.
* **`stop`**: This script stops and removes the running Docker containers (either a specific container or all containers) and attempts to terminate the associated SSH tunnel.

## Usage

### Launching a Browser

1. Clone the repository: `git clone --depth=1 https://github.com/geekz-projects/docker-browser-vnc/`
2. Navigate to the directory: `cd docker-browser-vnc`
3. Make the script executable: `chmod +x start`
4. Run the script: `./start`
5. Follow the on-screen prompts to select a browser.

### Stopping a Browser/Containers

1. Make the script executable: `chmod +x stop`
3. Run the script: `./stop`
4. Follow the on-screen prompts to select the container to stop (or choose 'all').

## Prerequisites

* Docker: Ensure Docker is installed and running on your system.
* SSH: You need SSH access to `nglocalhost.com` (or your chosen SSH server).  
* `socat` (For some Docker images): Some of the Docker images used in this project might require `socat` to be installed on your host system. If you encounter errors related to port forwarding, install `socat`.

## Configuration

* **SSH Server:**  The scripts currently use `nglocalhost.com` as the SSH server. You can change this in both `start` and `stop` by modifying the `ssh` command.
* **VNC Password (Debian Browser):** The Debian Browser container uses a VNC password. This is currently hardcoded as "123456" in `start`.  It is **highly recommended** that you change this password to a strong and secure one.  You can do so by editing the `start` script.  Ideally, store this in an environment variable.
* **Docker Images:** The scripts use specific Docker images for each browser. You can modify these if you prefer different images.

## Security Considerations

* **VNC Password:**  As mentioned above, change the default VNC password immediately.  A weak VNC password can compromise your system.
* **SSH Tunnel:**  Ensure your SSH server .
* **Docker Security:** Be aware of the security implications of running Docker containers.  Only use images from trusted sources.

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues.

## License

MIT Licences
