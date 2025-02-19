#!/bin/bash

# Function to display the menu and get user input
display_menu() {
  echo "Choose a browser:"
  echo "1. Firefox"
  echo "2. Chrome"
  echo "3. Debian Browser"
  echo "4. TOR Browser"
  read -p "Enter your choice (1-4): " choice

  # Validate user input
  if [[ ! "$choice" =~ ^[1-4]$ ]]; then
    echo "Invalid choice. Please enter a number between 1 and 4."
    display_menu  # Redisplay menu
    return 1 # Indicate error
  fi
  return 0 # Indicate success
}

# Function to start the selected Docker container
start_container() {
  case "$choice" in
    1)
      docker run -d --name=firefox -p 5900:5900 --shm-size 2g geekz1/firefox-vnc
      ;;
    2)
      docker run -d -p 5900:5900 siomiz/chrome
      ;;
    3)
      docker run -d -p 5900:5900 -p 6080:6080 --name vnc-browser -e VNC_PASSWORD="123456" mrcolorrain/vnc-browser:debian
      ;;
    4)
      docker run -d -p 5900:5900 geekz1/tor-vnc
      ;;
  esac

  # Check if the container started successfully.  Exit if it failed.
  if [[ $? -ne 0 ]]; then
      echo "Failed to start Docker container."
      exit 1
  fi
  echo "Docker container started."

}

# Function to establish the SSH tunnel
establish_tunnel() {

    # Get the container name based on the user's choice.  Useful for stopping later.
    container_name=""
    case "$choice" in
      1) container_name="firefox";;
      2) container_name="";; # Chrome doesn't have a name in the original command
      3) container_name="vnc-browser";;
      4) container_name="";; # Tor doesn't have a name in the original command
    esac

  ssh -R 0:0:5900 nglocalhost.com
  # Check the exit status of ssh, too.
  if [[ $? -ne 0 ]]; then
    echo "SSH tunnel failed."
    # If the tunnel fails, stop the container (if it has a name).
    if [[ -n "$container_name" ]]; then
        docker stop "$container_name"
        docker rm "$container_name"
    fi
    exit 1
  fi

}
# Function to check for updates
check_for_updates() {
  local remote_version=$(curl -s "https://raw.githubusercontent.com/geekz-projects/docker-browser-vnc/main/version.txt") # Get version from remote file
  local local_version=$(grep "version=" version.txt | cut -d '=' -f 2) # Get version from local file

  if [[ -z "$local_version" ]]; then
      echo "Error: version.txt file not found or invalid format."
      return 1
  fi

  if [[ -z "$remote_version" ]]; then
      echo "Error: Could not retrieve remote version."
      return 1
  fi

  if [[ "$local_version" != "$remote_version" ]]; then
    echo "A new version is available: $remote_version"
    read -p "Do you want to update? (y/n): " update_choice
    if [[ "$update_choice" == "y" ]]; then
      echo "Updating..."
      git pull origin main  # Or git pull if 'origin' is your remote name
      if [[ $? -ne 0 ]]; then
        echo "Update failed."
        return 1
      fi
      echo "Update complete. Please restart the script."
      return 2 # Indicate update and restart needed
    fi
  fi
  return 0
}


# Main script execution
# 1. Check for updates FIRST
check_for_updates
update_status=$?
if [[ "$update_status" -eq 1 ]]; then # Error
    exit 1
elif [[ "$update_status" -eq 2 ]]; then # Updated
    exit 0 # Exit cleanly since restart is needed
fi


display_menu
if [[ $? -eq 0 ]]; then
  start_container
  if [[ $? -eq 0 ]]; then
    establish_tunnel
  fi
fi

echo "Script finished."
