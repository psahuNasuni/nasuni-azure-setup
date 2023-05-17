## nasuni-azure-setup
This repo contains terraform configuration for creating the initial setup needful for NAC-ACS integration. Here, user has to provide user specific inputs as Key value pairs in a text file with terraform input format(.tfvars).

# Execute this code to create the user input vault:
- Provide the values of the keys in the vault.tfvars file
- execute the commands sequentially
-   terraform init
-   terraform apply -var-file=vault.tfvars -auto-approve
