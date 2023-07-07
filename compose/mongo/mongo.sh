#!/bin/bash

# Function to display script usage
display_usage() {
    echo "Usage: $0 -n <network> [-p <primary>] [-s <secondary>]"
    echo "   -n, --network: Docker network name"
    echo "   -p, --primary: Name for the MongoDB primary container (optional)"
    echo "   -s, --secondary: Name prefix for the MongoDB secondary containers (optional)"
    echo "   -r, --primary-script: Run the primary script"
}

# Check if required arguments are provided
# if [ $# -lt 2 ]; then
#     display_usage
#     exit 1
# fi

network=""
primary=""
secondary=""
runscript=""

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -n|--network)
            network="$2"
            shift
            shift
            ;;
        -p|--primary)
            primary="$2"
            shift
            shift
            ;;
        -s|--secondary)
            secondary="$2"
            shift
            shift
            ;;
        -w|--is_swarm)
            is_swarm="$2"
            shift
            shift
            ;;
        -r|--runscript)
            runscript="$2"
            shift
            shift
            ;;
        *)
            display_usage
            exit 1
            ;;
    esac
done

# Check if network argument is provided
# if [ -z "$network" ]; then
#     display_usage
#     exit 1
# fi

# Check if network already exists
if [ -z "$(docker network ls --filter name=$network --format {{.Name}})" ]; then
    echo "Creating Docker network: $network"
    docker network create $network
else
    echo "Docker network '$network' already exists"
fi

if [ ! -z "$runscript" ]; then
    # Configure Replica Set
    docker exec -it $runscript bash ./scripts/rs-init.sh 
fi

# Start primary node if provided
if [ ! -z "$primary" ]; then
    # Start primary node
    if [ -z "$(docker ps --filter name=$primary --format {{.Names}})" ]; then
        echo "Starting MongoDB primary node: $primary"
        if [ "$is_swarm" = "true" ]; then
            docker service create --name $primary --network $network -p 27017:27017 mongo --bind_ip_all --replSet dbrs 
        else
            docker run -d --net $network --name $primary -p 27017:27017 mongo --bind_ip_all --replSet dbrs
        fi
    else
        echo "MongoDB primary node '$primary' already exists"
    fi

    # Wait for primary node to start
    sleep 20

    # Configure Replica Set
    docker exec -it $primary mongosh --eval "rs.initiate({_id: 'dbrs', members: [{_id: 0, host: '$primary:27017'}]})"

    # Enable Authentication (Optional)
    docker exec -it $primary mongosh --eval "use admin; db.createUser({user: 'admin', pwd: 'password', roles: [{role: 'root', db: 'admin'}]})"

    # Shift secondary nodes to match member ID
    shift_count=1
else
    shift_count=0
fi

# If secondary argument is provided, create secondary nodes
if [ ! -z "$secondary" ]; then
   secondary_node="${secondary}${i}"

   # Start secondary node
   if [ -z "$(docker ps --filter name=$secondary_node --format {{.Names}})" ]; then
       echo "Starting MongoDB secondary node: $secondary_node"
       if [ "$is_swarm" = "true" ]; then
           docker service create --name $secondary_node --network $network mongo --replSet dbrs
       else
           docker run -d --net $network --name $secondary_node mongo --replSet dbrs
       fi
       sleep 2
       docker exec -it pmongo mongosh --eval "rs.add('$secondary_node:27017')"
   else
       echo "MongoDB secondary node '$secondary_node' already exists"
   fi
fi
