#!/bin/bash

# Constants
TEMPLATES_DIR="./templates"
KEYSTORE_DIR="./keystore"
PASSWORD_FILE="./password.txt"
GENESIS_TEMPLATE="$TEMPLATES_DIR/template-genesis.json"
SERVICE_TEMPLATE="$TEMPLATES_DIR/template-ethnode.service"
GENESIS_FILE="./genesis.json"
SERVICE_FILE_PATH="./ethnode.service"
ETH_SHH_KEY="./private-key.pem"

# Copy the template files to the working directory
cp $GENESIS_TEMPLATE $GENESIS_FILE
cp $SERVICE_TEMPLATE $SERVICE_FILE_PATH

echo "Generating Passwork and saving it in $PASSWORD_FILE"
ETHER_PASS=$(openssl rand -base64 12)
echo $ETHER_PASS > $PASSWORD_FILE

# Initialize a new Ethereum data directory
echo "Initialize a new Ethereum data directory"
geth --datadir ./ethereum_data init $GENESIS_FILE


# Create the main account
echo "Creating the main account"
MAIN_ADDRESS=$(geth --datadir ./ethereum_data account new --password $PASSWORD_FILE | grep "Public address of the key:" | awk '{print $NF}' | cut -c 3-)

echo "Generated Main Ethereum Address: $MAIN_ADDRESS"

# Create a test account
echo "Creating the test account"
TEST_ADDRESS=$(geth --datadir ./ethereum_data account new --password $PASSWORD_FILE | grep "Public address of the key:" | awk '{print $NF}' | cut -c 3-)
echo "Generated Test Ethereum Address: $TEST_ADDRESS"

# Update genesis.json with the new addresses
echo "Updating genesis.json with the new addresses"
sed -i "s/B4eC31aD5720F6b23C9A7b2D83Fe7A9C540b3e7F/$MAIN_ADDRESS/g" $GENESIS_FILE
sed -i "s/A3dD24fD6758E230F7b46a9B09dEa215F24c2a1E/$TEST_ADDRESS/g" $GENESIS_FILE

# Update the ethnode.service with the main address
echo "Updating the ethnode.service with the main address"
sed -i "s/B4eC31aD5720F6b23C9A7b2D83Fe7A9C540b3e7F/$MAIN_ADDRESS/g" $SERVICE_FILE_PATH

# Fill in the terraform.tfvars
echo "Filling in the terraform.tfvars"

cat <<EOL >terraform.tfvars
ssh_private_key_path = "$(realpath $ETH_SHH_KEY)"
genesis_file_path = "$(realpath $GENESIS_FILE)"
password_file_path = "$(realpath $PASSWORD_FILE)"
keystore_file_path = "$(realpath ./ethereum_data/keystore/)"
keystore_file_name = ""
service_file_path = "$(realpath $SERVICE_FILE_PATH)"
EOL

# Create the KEYSTORE_DIR if it doesn't exist
echo "Creating the KEYSTORE_DIR if it doesn't exist"
mkdir -p $KEYSTORE_DIR

# Move the keystore files from the ethereum_data directory to the KEYSTORE_DIR
echo "Moving the keystore files from the ethereum_data directory to the KEYSTORE_DIR"
mv ./ethereum_data/keystore/* $KEYSTORE_DIR/

# Fetch the actual keystore filenames
echo "Fetching the actual keystore filenames"
MAIN_KEYSTORE_FILENAME=$(ls $KEYSTORE_DIR | grep -i $MAIN_ADDRESS)
TEST_KEYSTORE_FILENAME=$(ls $KEYSTORE_DIR | grep -i $TEST_ADDRESS)


# Update the keystore_file_name in terraform.tfvars with the main address's keystore.
sed -i "s|keystore_file_name = \"\"|keystore_file_name = \"$MAIN_KEYSTORE_FILENAME\"|" terraform.tfvars

echo "All done!"

echo "******************************"
echo "Starting Terraform"
echo "******************************"

terraform init

terraform apply -var-file=terraform.tfvars -auto-approve

