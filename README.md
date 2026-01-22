# Terraform Minecraft Server

Infrastructure as Code (IaC) for deploying a Minecraft server on AWS using Terraform.

## Overview

This project provisions a fully functional Minecraft server on AWS EC2 with automated setup and configuration. The server is deployed in a custom VPC with proper networking, security groups, and automatic startup configuration.

## Minecraft Version

- **Minecraft Version:** 1.16.5 (Java Edition)
- **Server Type:** Vanilla Minecraft Server
- **Online Mode:** Disabled (allows non-authenticated players)

## Architecture

The infrastructure includes:

- **VPC:** Custom VPC with CIDR block 10.0.0.0/16
- **Subnet:** Public subnet (10.0.1.0/24) with internet gateway
- **EC2 Instance:** t3.small instance running Ubuntu 22.04
- **Security Groups:**
  - Port 25565 (Minecraft) - open to world
  - Port 22 (SSH) - open to world
  - All egress traffic allowed
- **SSH Key Pair:** Auto-generated 4096-bit RSA key
- **Auto-start:** Systemd service for automatic server startup

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) ~> 1.7
- AWS Account with appropriate permissions
- AWS CLI configured or environment variables set
- Basic understanding of AWS and Terraform

## Setup Instructions

### 1. Clone the Repository

```bash
git clone git@github.com:vincent-restrepo/terraform-minecraft-server.git
cd terraform-minecraft-server
```

### 2. Configure AWS Credentials

Create a `.env` file based on the provided `.env.example`:

```bash
cp .env.example .env
```

Edit the `.env` file and add your AWS credentials:

```bash
# .env
export AWS_ACCESS_KEY_ID="your_access_key_here"
export AWS_SECRET_ACCESS_KEY="your_secret_key_here"
export AWS_REGION="us-east-1"
```

**Important:** Never commit your `.env` file to version control. It's already listed in `.gitignore`.

### 3. Load Environment Variables

Before running Terraform commands, source the environment file:

```bash
source .env
```

### 4. Initialize Terraform

```bash
terraform init
```

### 5. Review the Execution Plan

```bash
terraform plan
```

### 6. Deploy the Infrastructure

```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.

### 7. Get Connection Details

After successful deployment, Terraform will output:

- **Minecraft Server IP:** The public IP address to connect to
- **Minecraft Connection:** Full connection string (IP:25565)
- **SSH Connection:** Command to SSH into the server
- **SSH Key Location:** Path to the private key file

Example output:
```
minecraft_server_ip = "54.123.45.67"
minecraft_connection = "Connect to: 54.123.45.67:25565"
ssh_connection = "ssh -i minecraft-server-key.pem ubuntu@54.123.45.67"
ssh_key_location = "minecraft-server-key.pem"
```

## Connecting to Your Minecraft Server

1. Open Minecraft Java Edition (version 1.16.5 or compatible)
2. Go to Multiplayer > Add Server
3. Enter the server IP from the Terraform output
4. Click Done and join the server

## Server Management

### SSH Access

Connect to the server using the generated SSH key:

```bash
ssh -i minecraft-server-key.pem ubuntu@<server-ip>
```

### Check Server Status

```bash
sudo systemctl status minecraft.service
```

### View Server Logs

```bash
sudo tail -f /var/log/minecraft.log
```

### Restart Server

```bash
sudo systemctl restart minecraft.service
```

### Stop Server

```bash
sudo systemctl stop minecraft.service
```

### Start Server

```bash
sudo systemctl start minecraft.service
```

## Server Configuration

The Minecraft server configuration is located at `/home/ubuntu/minecraft/server.properties` on the EC2 instance.

Default settings:
- **Max Players:** 20
- **Game Mode:** Survival
- **Difficulty:** Easy
- **View Distance:** 10 chunks
- **PVP:** Enabled
- **Online Mode:** Disabled

To modify settings, SSH into the server, edit the `server.properties` file, and restart the Minecraft service.

## Cost Considerations

Running this infrastructure will incur AWS costs:
- **t3.small EC2 instance:** ~$0.0208/hour (~$15/month if running 24/7)
- **Data transfer:** Variable based on usage
- **Elastic IP:** Free when attached to a running instance

**Tip:** Remember to destroy the infrastructure when not in use to avoid unnecessary charges.

## Cleanup

To destroy all resources and avoid ongoing costs:

```bash
terraform destroy
```

Type `yes` when prompted to confirm destruction.

**Note:** This will permanently delete your Minecraft world data unless you've backed it up.

## Backup Your World

Before destroying the infrastructure, you can backup your world:

```bash
ssh -i minecraft-server-key.pem ubuntu@<server-ip>
cd /home/ubuntu/minecraft
zip -r world-backup.zip world/
exit

# Download the backup
scp -i minecraft-server-key.pem ubuntu@<server-ip>:/home/ubuntu/minecraft/world-backup.zip ./
```

## Customization

### Change Instance Type

Edit `ec2.tf` and modify the `instance_type`:

```hcl
instance_type = "t3.medium"  # For better performance
```

### Change Minecraft Version

Edit `scripts/user_data.sh` and update the download URL to your desired version.

### Modify Memory Allocation

Edit `scripts/user_data.sh` and adjust the `-Xms` and `-Xmx` flags:

```bash
ExecStart=/usr/bin/java -Xms2048M -Xmx2048M -jar mc-server-1.16.5.jar nogui
```

### Change AWS Region

Edit `providers.tf` and update the region:

```hcl
provider "aws" {
  region = "us-west-2"
}
```

## Troubleshooting

### Server Not Starting

1. SSH into the instance
2. Check the user-data log: `cat /var/log/user-data.log`
3. Check Minecraft logs: `sudo journalctl -u minecraft.service`

### Can't Connect to Server

1. Verify security group rules allow port 25565
2. Check if the server is running: `sudo systemctl status minecraft.service`
3. Ensure you're using the correct IP address from Terraform outputs
4. Wait a few minutes after deployment for the server to fully start

### SSH Connection Issues

1. Ensure the private key has correct permissions: `chmod 400 minecraft-server-key.pem`
2. Verify the security group allows port 22
3. Check that you're using the correct public IP

## Security Considerations

- The server allows connections from anywhere (0.0.0.0/0). Consider restricting access to specific IP addresses.
- Online mode is disabled by default. Enable it in `server.properties` for better security.
- Regularly update the server software and operating system.
- Consider implementing a whitelist for trusted players.

## File Structure

```
.
├── .gitignore              # Git ignore rules
├── .env.example            # Example environment variables
├── README.md               # This file
├── data.tf                 # AMI data source
├── ec2.tf                  # EC2 instance configuration
├── networking.tf           # Networking and security groups
├── outputs.tf              # Terraform outputs
├── providers.tf            # Terraform and AWS provider config
├── scripts/
│   └── user_data.sh       # EC2 initialization script
├── ssh.tf                  # SSH key pair generation
└── vpc.tf                  # VPC configuration
```

## Contributing

Feel free to submit issues or pull requests for improvements.

## License

This project is open source and available under the MIT License.

## Acknowledgments

- Minecraft is a trademark of Mojang Studios
- Built with Terraform by HashiCorp
- Deployed on Amazon Web Services (AWS)
