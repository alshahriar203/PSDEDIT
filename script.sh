#!/bin/bash

run_in_new_terminal() {
    osascript -e "tell application \"Terminal\" to do script \"$1\"" > /dev/null 2>&1
}


    i=8

    DIR_NAME="PSD$i"
    # Delete PSDEDIT/PSD if it exists
        if [ -d "PSDEDIT/PSD" ]; then
            rm -rf "PSDEDIT/PSD"
        fi
    echo "Deleted PSD dir"

    # Create an empty directory PSD in PSDEDIT
    mkdir -p PSDEDIT/PSD
    echo "created PSD dir"

    # Copy files from DIR/PSD1 to PSDEDIT/PSD
    cp -r "DIR/$DIR_NAME"/* "PSDEDIT/PSD/"
    echo "copying psd files to PSD"

    # Build a Docker image named psdapp from PSDEDIT directory
    docker login
    docker build -t psdapp PSDEDIT

    # Run the psdapp in a container in detached mode
    docker run -d --name psd_container psdapp


    # Set the name of the Docker container
    CONTAINER_NAME="psd_container"

    # Loop indefinitely
    while true; do

        # Check the app/PSD directory--------
        PSD_COUNT=$(docker exec "$CONTAINER_NAME" find /app/PSD -maxdepth 1 -name "*.psd" | wc -l)
        if [ "$PSD_COUNT" -eq 0 ]; then
            # Download/save the app directory
            mkdir -p "Chunk$i"
            docker cp "$CONTAINER_NAME":/app "Chunk$i"
            
            echo "No PSD files found in app/PSD directory. Downloaded the app directory."

            # Delete Docker container and image
            docker stop "$CONTAINER_NAME"
            docker rm "$CONTAINER_NAME"
            docker rmi psdapp
            echo "Docker container $CONTAINER_NAME and image psdapp deleted."

            # Break out of the while loop
            break
        fi

        # Get the CPU usage of the Docker container
        CPU_USAGE=$(docker stats --no-stream --format "{{.CPUPerc}}" "$CONTAINER_NAME" | sed 's/%//')

        # Check if CPU usage is less than or equal to 0%
        if (( $(echo "$CPU_USAGE <= 0" | bc -l) )); then
            echo "CPU usage is 0% or less. Killing processes and restarting Job.py."
        
            # Kill all processes that match python Job.py inside the container
            docker exec "$CONTAINER_NAME" pkill -f "python Job.py"

            # Execute python Job.py inside the container in a new terminal window (run in background)
            run_in_new_terminal "docker exec $CONTAINER_NAME python Job.py"

        else
            echo "CPU usage is not 0%: $CPU_USAGE%"
        fi
        # Sleep for 30 sec before checking again
        sleep 30
    done

