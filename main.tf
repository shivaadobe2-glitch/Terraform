terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 6.0"
    }
  }
}

provider "aws" {region = var.region}

data "aws_ami" "latest_ami"{
    most_recent = true
    owners = ["159365745649"]
    filter {
      name = "name"
      values = ["Windows_Server-2025-English-Full-Base-2025.11.12*"]
    }
    filter {
      name = "virtualization-type"
      values = ["hvm"]
    } 
}

data "aws_vpc" "selected"{default = true}

data "aws_subnets" "selected_subnet" {
    filter {
      name = "vpc-id"
      values = [data.aws_vpc.selected.id]
    }
  
}

resource "aws_instance" "My-first-machine" {
    ami = data.aws_ami.latest_ami.id
    instance_type = "t3.micro"
    user_data = <<-EOF
        <powershell>
        Install-WindowsFeature -name Web-Server -IncludeManagementTools
        </powershell>
    EOF
    subnet_id = data.aws_subnets.selected_subnet.ids[0]
    tags = {
      name = "Terraform-ins001"
    }
    associate_public_ip_address = false
  
}

output "my-final-output" {value = aws_instance.My-first-machine.id}