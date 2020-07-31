provider "aws" {
    region = "us-east-2"
}

resource "aws_instance" "web" {
    ami = "ami-016b213e65284e9c9"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.web_traffic.name]
    user_data = file("server-script.sh")

    tags = {
        Name = "Web server"
    }
}

resource "aws_eip" "web_ip" {
    instance = aws_instance.web.id
}

variable "ingress_ports" {
    type = list(number)
    default = [80, 443]
}

variable "egress_ports" {
    type = list(number)
    default = [80, 443]
}

resource "aws_security_group" "web_traffic" {
    name = "Allow Web Traffic"

    dynamic "ingress" {
        iterator = port
        for_each = var.ingress_ports
        content {
            from_port = port.value
            to_port = port.value
            protocol = "TCP"
            cidr_blocks = ["0.0.0.0/0"]
        }        
    }

    dynamic "egress" {
        iterator = port
        for_each = var.egress_ports
        content {
            from_port = port.value
            to_port = port.value
            protocol = "TCP"
            cidr_blocks = ["0.0.0.0/0"]
        }        
    }
}

output "PublicIP" {
    value = aws_eip.web_ip.public_ip
}