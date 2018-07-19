#!/usr/bin/env bash

# Pull the Docker "hello-world" image
docker pull hello-world

# Pull the Apache webserver version 2.4
docker pull httpd:2.4

# Run the "hello-world" image
docker run hello-world

# Find command options for inspecting Docker's current processes (containers)
docker ps --help

# List all containers, included the exited/stopped ones
docker ps --all

# Run the Apache webserver (ctrl+c to exit)
docker run httpd:2.4

# Run the Apache webserver in daemonized mode
docker run -d httpd:2.4

# Inspect all running containers
docker ps

# Send an HTTP request to the host
curl localhost

# Stop the Apache webserver
docker stop 7102713e6f4d

# Run the Apache webserver daemonized and with port 80 exposed on the host
docker run -d -p 80:80 --name apache httpd:2.4

# Send an HTTP request to the host again
curl localhost

# Stop the Apache webserver by it's name
docker stop apache

# Start the Apache webserver
docker start apache

# Send an HTTP request to the host again
curl localhost

# Kill the Apache webserver
docker kill apache

# Remove the container
docker rm apache

# Create an HTML file in the home directory
echo "<h1>XS4ALL</h1>" >> index.html

# Run the Apache webserver again but with a mounted volume
docker run -dit --name apache -p 80:80 -v $(pwd)/index.html:/usr/local/apache2/htdocs/index.html httpd:2.4

# Send an HTTP request to the host
curl localhost

# Update the HTML file
echo "<p>Welkom bij de Docker workshop</p>" >> index.html

# Send an HTTP request to the host
curl localhost

# Kill and remove the container
docker kill apache && docker rm apache

# Run the Apache webserver again after we removed it
docker run -dit --name apache -p 80:80 -v $(pwd)/index.html:/usr/local/apache2/htdocs/index.html httpd:2.4

# Enter the Apache container
docker exec -it apache sh

# Append to the index.html file from within the container (exit by typing 'exit' afterwards
echo "<p>Another one!</p>" >> /usr/local/apache2/htdocs/index.html

# Clone the Docker Workshop repository from Github
git clone https://github.com/TijmenWierenga/docker-workshop.git demo
cd demo
git checkout feature/dockerfile
cd app

# Build the xs4all/counter image
docker build -t xs4all/counter:dev .

# Run the image
docker run --rm xs4all/counter:dev

# Run the image with a mounted volume
docker run --rm -v $(pwd)/app.php:/var/www/html/app.php xs4all/counter:dev

# Install our Composer vendor dependencies
docker run -it --rm -v $(pwd):/app -u $(id -u):$(id- g) composer install

# Run the image with both local and vendor dependencies mounted
docker run --rm -v $(pwd)/app.php:/var/www/html/app.php -v $(pwd)/vendor:/var/www/html/vendor xs4all/counter:dev

# TODO: Update command to update the Dockerfile

# Build the image with all dependencies
docker build -t xs4all/counter:dev .

# And run the new image
docker run --rm xs4all/counter:dev

# Let's remove the vendor folder to prove that it now is dependency free
rm -R vendor

# And build again with the improved Dockerfile
docker build -f Dockerfile-multistage -t xs4all/counter:dev .

# And runnnnnn it:
docker run --rm xs4all/counter:dev

# Create a new network
docker network create counter_private

# Pull Redis as a database
docker pull redis:4.0

# Start the Redis container and attach it to the network
docker run -d --rm --name redis --network counter_private redis:4.0

# Inspect the network
docker network inspect counter_private

# Inspect the network's attached containers
docker network inspect counter_private --format '{{json .Containers }}' | jq

# Switch to the networking branch to update the source code to use Redis as a database
git checkout feature/networking

# Rebuild our app with the updated source code
docker build -f Dockerfile-multistage -t xs4all/counter:dev .

# And run our application and attach it to the network
docker run --rm --network counter_private xs4all/counter:dev

# Now run everything we've done from a simple docker-compose template
docker-compose up

# And bring it down
docker-compose down
