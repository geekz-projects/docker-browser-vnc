#!/bin/bash

# Function to display running containers and get user input
display_containers() {
  echo "Running Docker containers:"
  docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}"  # Display containers in a table format

  # Check if any containers are running
  if [[ $(docker ps -q | wc -l) -eq 0 ]]; then
    echo "No Docker containers are currently running."
    return 1 # Indicate no containers
  fi

  echo "Enter the container name or ID to stop (or 'all' to stop all):"
  read -p "Your choice: " choice
  return 0
}

# Function to stop and remove a container
stop_remove_container() {
  container_id=""
  if [[ "$choice" == "all" ]]; then
    container_id=$(docker ps -aq)  # Get all container IDs
    if [[ -n "$container_id" ]]; then # Check if any containers are running
      docker stop "$container_id"
      docker rm "$container_id"
      echo "All Docker containers stopped and removed."
    else
      echo "No docker containers to stop."
    fi
  else
    # Check if the input is a valid container ID or name
    if docker ps -q --filter "id=$choice" > /dev/null 2>&1 || docker ps -q --filter "name=$choice" > /dev/null 2>&1; then
      container_id="$choice"
    else
      echo "Invalid container name or ID."
      return 1
    fi

    docker stop "$container_id"
    docker rm "$container_id"
    echo "Container '$choice' stopped and removed."
  fi
  return 0
}


# Function to stop SSH tunnel (this is more complex and depends on how you started it)
stop_ssh_tunnel() {
  # Option 1: If you know the PID of the ssh process: (This is the most reliable if you know the PID)
  # Example:  SSH_PID=$(pgrep -f "ssh -R 0:0:5900 nglocalhost.com")  # Use pgrep to find the PID
  # if [[ -n "$SSH_PID" ]]; then
  #    kill "$SSH_PID"
  #    echo "SSH tunnel stopped (using PID)."
  # else
  #  echo "Could not find SSH process.  Tunnel may not be running or may have stopped already."
  # fi

  # Option 2: If you don't have the PID, you can try to kill ssh processes based on the command: (Less reliable)
  pkill -f "ssh -R 0:0:5900 nglocalhost.com"  # Kill matching ssh commands
  echo "Attempted to stop SSH tunnel (using pkill). This is less reliable."

  # Option 3: If you used a screen or tmux session to start SSH, you need to kill that session.
  # Example (tmux): tmux kill-session -t your_session_name
  # Example (screen): screen -X quit

}

# Main script execution
display_containers
if [[ $? -eq 0 ]]; then # Check if there were running containers
  stop_remove_container
fi

stop_ssh_tunnel # Always attempt to stop the tunnel

echo "Script finished."
