#!/bin/bash

run_in_new_terminal() {
    osascript -e "tell application \"Terminal\" to do script \"$1\"" > /dev/null 2>&1
}


    i=2

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













#!/bin/bash

run_in_new_terminal() {
    osascript -e "tell application \"Terminal\" to do script \"$1\"" > /dev/null 2>&1
}

# Function to check if Docker daemon is running
           check_docker() {
                docker_info=$(docker info 2> /dev/null)
                if [ $? -eq 0 ]; then
                    return 0  # Docker daemon is running
                else
                    return 1  # Docker daemon is not yet running
                fi
            }

#echo "<password>"|sudo -S pkill docker
#open --background /Applications/Docker.app
#echo "starting docker"

# Wait until Docker daemon is running
#while ! check_docker; do
#    open --background /Applications/Docker.app
#    sleep 10
#done

for ((i = 3; i <= 7; i++)); do
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
            mkdir -p "app$i"
            docker cp "$CONTAINER_NAME":/app "app$i"
            
            echo "No PSD files found in app/PSD directory. Downloaded the app directory."

            # Delete Docker container and image
            docker stop "$CONTAINER_NAME"
            docker rm "$CONTAINER_NAME"
            docker rmi psdapp
            echo "Docker container $CONTAINER_NAME and image psdapp deleted."
            docker system prune -f

            #echo "<password>"|sudo -S pkill docker
            #open --background /Applications/Docker.app
            #echo "starting docker"

            #Wait until Docker daemon is running
            #while ! check_docker; do
            #    open --background /Applications/Docker.app
            #    sleep 10
            #done

            # Docker daemon has started
            #echo "Docker daemon has started."

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
done
















#!/bin/bash

# Function to check if Docker daemon is running
#           check_docker() {
#                docker_info=$(docker info 2> /dev/null)
#                if [ $? -eq 0 ]; then
#                    return 0  # Docker daemon is running
#                else
#                    return 1  # Docker daemon is not yet running
#                fi
#            }

#echo "<password>"|sudo -S pkill docker
#open --background /Applications/Docker.app
#echo "starting docker"

# Wait until Docker daemon is running
#while ! check_docker; do
#    open --background /Applications/Docker.app
#    sleep 10
#done

for ((i = 1; i <= 7; i++)); do

    if [ "$i" -eq 2 ]; then
        continue  # Skip execution for i=2
    fi

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
            mkdir -p "app$i"
            docker cp "$CONTAINER_NAME":/app "app$i"
            
            echo "No PSD files found in app/PSD directory. Downloaded the app directory."

            # Delete Docker container and image
            docker stop "$CONTAINER_NAME"
            docker rm "$CONTAINER_NAME"
            docker rmi psdapp
            echo "Docker container $CONTAINER_NAME and image psdapp deleted."
            docker system prune -f

            #echo "<password>"|sudo -S pkill docker
            #open --background /Applications/Docker.app
            #echo "starting docker"

            #Wait until Docker daemon is running
            #while ! check_docker; do
            #    open --background /Applications/Docker.app
            #    sleep 10
            #done

            # Docker daemon has started
            #echo "Docker daemon has started."

            # Break out of the while loop
            break
        fi

        # Get the CPU usage of the Docker container
        CPU_USAGE=$(docker stats --no-stream --format "{{.CPUPerc}}" "$CONTAINER_NAME" | sed 's/%//')

        # Check if CPU usage is less than or equal to 100%
        if (( $(echo "$CPU_USAGE <= 100" | bc -l) )); then
            echo "CPU usage is 100% or less. killing processes"

            echo "making TEMP directories"

            mkdir -p TEMP
            mkdir -p TEMP/PSD
            mkdir -p TEMP/GRAPHICSONLY
            mkdir -p TEMP/TXTONLY
            mkdir -p TEMP/GRAPHICSLAYERERROR
            mkdir -p TEMP/TXTLAYERERROR
            mkdir -p TEMP/GENERALERROR


            echo "saving work"

            docker cp "$CONTAINER_NAME":/app/PSD/* TEMP/PSD
            docker cp "$CONTAINER_NAME":/app/GRAPHICSONLY/* TEMP/GRAPHICSONLY
            docker cp "$CONTAINER_NAME":/app/TXTONLY/* TEMP/TXTONLY
            docker cp "$CONTAINER_NAME":/app/GRAPHICSLAYERERROR/* TEMP/GRAPHICSLAYERERROR
            docker cp "$CONTAINER_NAME":/app/TXTLAYERERROR/* TEMP/TXTLAYERERROR
            docker cp "$CONTAINER_NAME":/app/GENERALERROR/* TEMP/GENERALERROR

            # Delete Docker container and image
            docker stop "$CONTAINER_NAME"
            docker rm "$CONTAINER_NAME"
            docker rmi psdapp
            echo "Docker container $CONTAINER_NAME and image psdapp deleted."
            docker system prune -f

            # Move directories from TEMP to PSDEDIT and delete TEMP
            echo "retrieving work"
            mv TEMP/* PSDEDIT
            rm -rf TEMP

            # Build a Docker image named psdapp from PSDEDIT directory
            docker build -t psdapp PSDEDIT

            # Run the psdapp in a container in detached mode
            docker run -d --name psd_container psdapp

        else
            echo "CPU usage is above 100%: $CPU_USAGE%"
        fi
        # Sleep for 30 sec before checking again
        sleep 30
    done
done
