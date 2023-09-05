# Ethereum Network

This is a Terraform project designed to deploy, configure, and manage an Ethereum private network on cloud platforms. 


## Features

-   🚀 **Rapid Deployment**: Set up your Ethereum private network with just a few commands.
-   🔒 **Security**: Best practices are integrated into the Terraform scripts, ensuring a secured Ethereum setup.
-   ☁️ **Cloud Agnostic**: While initially focused on specific cloud platforms, the design aims to support multi-cloud deployments in future iterations.

-   📊 **Monitoring & Logging**: Integrated solutions for monitoring the health and performance of your Ethereum nodes.

## Prerequisites
-   [Terraform](https://www.terraform.io/downloads.html) v1.0+
-   Cloud Provider CLI tools (e.g., AWS CLI, GCP CLI)
-   Basic knowledge of Ethereum and Terraform
-   SSH Private key, (instructions in the bottom)
-   Install Geth [go-ethereum](https://geth.ethereum.org/downloads)

## Quick Start

1.  **Clone the Repository**

`git clone https://github.com/valentevidal/ethereum-network.git
cd ethereum-network` 

2.  **Initialize Terraform**

`terraform init` 

3.  **Configure Cloud Credentials**

Update `provider.tf` with the appropriate credentials for your cloud provider.

4.  **Apply Configuration**


`terraform apply` 

This command will show you a plan and ask for confirmation. Type `yes` to proceed.

5.  **Access Ethereum Node**

After the deployment, Terraform will output the IP addresses of the Ethereum nodes. Use these addresses to interact with your private network.


## MetaMask
  


To test the network on MetaMask you can by filling in the MetaMask fields as follows



**Network name**: This can be anything

**New RPC URL**: This will be the IP that Terraform displays at the end
example: https://13.40.223.81:8545

**Chain ID**: This will be 4224, this can be found in the genesis.json as well

**Currency symbol**: This can also be anything, I normally add ETH

**Block explorer URL**: This is optional and be left empty


You can import your ethereum account to Metamask you can do this via de import feature and by importing the private key. To get the private key you can use the keythereum to extract it. 




## AWS EC2 Private Key Generation

1.  **AWS Console**:
    -   Login to the AWS Management Console.
    -   Navigate to **EC2** > **Key Pairs**.
2.  **Create Key Pair**:
    -   Click "Create key pair".
    -   Name it (e.g., `ethereum-network`) and select the `PEM` format.
    -   Download the `.pem` file.
3.  **Terraform Setup**:
    -   Save the `.pem` file, for example: `C:\\Users\\XYZ\\Documents\\ethereum-network\\ethereum-network.pem`.
    -   Update `variables.tf` if saved in a different location.

**Note**: Keep the private key secure.