# Terraform AWS VPC Setup

This Terraform configuration creates a basic AWS networking environment with public and private subnets, NAT, route tables, security groups, and EC2 instances.

## Files
- **main.tf**:  This contains the actual resources we are trying to create
- **tags.tf**: contains the common tags, because I want to analyze the cost
- **variables.tf**: contains the variable names with some default values
- **outputs.tf**: outputs select resource ids to the terminal for verification
- **terraform.tfvars**: overrides for the `variables.tf` file
  
## Components

- **VPC**: Creates a VPC with DNS support and hostnames enabled.
- **Internet Gateway**: Provides internet access for public subnets.
- **Subnets**:
  - **Public Subnet**: Maps public IPs and is attached to the Internet Gateway.
  - **Private Subnet**: No direct internet access; routes traffic through a NAT Gateway.
- **NAT Gateway**: Enables private subnet instances to access the internet.
- **Route Tables**:
  - **Public**: Routes `0.0.0.0/0` to the Internet Gateway.
  - **Private**: Routes `0.0.0.0/0` to the NAT Gateway.
- **Security Groups**:
  - **Public SG**: Allows SSH (22) and HTTP (80) from anywhere.
  - **Private SG**: Allows SSH access only from public SG.
- **EC2 Instances**:
  - **Public Instance**: Placed in the public subnet with a public IP.
  - **Private Instance**: Placed in the private subnet, accesses the internet via NAT.

## Variables

Most of them have default values in `variables.tf` and the rest have overrides in `terraform.tfvars`:

- `region` -overriding
- `name` - overriding
- `vpc_cidr`
- `public_subnet_cidr`
- `public_subnet_az` - overriding
- `private_subnet_cidr` - overriding
- `private_subnet_az`
- `ami` - overriding
- `instance_type_public`
- `instance_type_private`
- `key_name` - overriding
- 
> **NOTE:** The key_name is the only thing that I manually created, because I needed to save the actual RSA key inside my shell, but tf outputs only the id

## Usage

```bash
terraform init
terraform plan -out vpcplan
terraform apply "vpcplan"
