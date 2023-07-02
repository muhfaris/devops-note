# MongoDB Cluster Deployment Script

This script is used to deploy a MongoDB cluster with support for high availability and replication. It allows you to create a primary node and optionally add secondary nodes to the cluster.

## Prerequisites

- Docker installed on your system

- Change default config `user` and `pwd` in the `init.js` file.

## Usage

1. Download the `deploy_mongodb.sh` script from this repository.

2. Make the script executable:

   ```bash
   chmod +x deploy_mongodb.sh
   ```

3. Run the script with the following command-line arguments:

   ```
   ./deploy_mongodb.sh -n <network> [-p <primary>] [-s <secondary>]
   ```

- -n, --network: Docker network name for the MongoDB cluster.
- -p, --primary: Name for the MongoDB primary container (optional).
- -s, --secondary: Name prefix for the MongoDB secondary containers (optional).

Note: If you only want to create secondary nodes without a primary node, omit the -p or --primary argument.

4. The script will perform the following steps:

- Check if the specified Docker network exists. If not, it creates the network.
- If a primary node is provided, it checks if the primary node container exists. If not, it creates the primary node container.
- Configures the Replica Set for the primary node.
- (Optional) Enables authentication for the MongoDB cluster.
- If secondary node names are provided, it checks if the secondary node containers exist. If not, it creates the secondary node containers and adds them to the Replica Set.

5. Monitor the script's output to ensure that the MongoDB cluster deployment completes successfully.

## Example Usage

- To create a MongoDB cluster with the network name "mongo-cluster," primary node named "mongo1," and secondary nodes named "mongo2" and "mongo3," run the following command:

```bash
./deploy_mongodb.sh -n mongo-cluster -p mongo1 -s mongo

```

- To create only a primary node without any secondary nodes, run the following command:

```bash
./deploy_mongodb.sh -n mongo-cluster -p mongo1
```

## Customization

- Authentication: By default, the script enables authentication for the MongoDB cluster. You can modify the script to customize the authentication settings as per your requirements.

- Replica Set Configuration: The script uses the Replica Set name "rs0" and assigns member IDs to the primary and secondary nodes accordingly. If you want to use a different Replica Set name or modify the member IDs, you can adjust the script accordingly.

- Other MongoDB Docker options: The script uses default options for running the MongoDB Docker containers. If you need to customize additional MongoDB container options such as ports or volume mounts, you can modify the script accordingly.
