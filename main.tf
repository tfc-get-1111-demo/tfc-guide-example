# data "aws_ami" "ubuntu" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["099720109477"] # Canonical
# }

resource "aws_instance" "mock_splunk" {
  ami           = var.instance_ami
  instance_type = var.instance_size
  
  network_interface {
    network_interface_id = aws_network_interface.mock_splunk.id
    device_index         = 0
  }

  user_data     = file("${path.module}/templates/user-data.sh")

  tags          = merge({
      "Name" = "${var.mock_splunk}"
    },
    var.mandatory_tags)
  }}

resource "aws_network_interface" "mock_splunk" {
  subnet_id   = var.subnet_id
  private_ips = ["172.16.0.10"]

  tags = merge({
      "Name" = "primary_network_interface"
    },
    var.mandatory_tags)
  }

resource "aws_iam_role" "splunk_instance_profile_role" {
  name = "SplunkInstanceProfileRole"
  path = "/"
  tags = var.mandatory_tags

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "splunk_instance_profile" {
  name = "SplunkInstanceProfile"
  role = aws_iam_role.splunk_instance_profile_role.name
}

resource "aws_iam_role_policy" "splunk_instance_profile_policy" {
  name = "SplunkInstanceProfilePolicy"
  role = aws_iam_role.splunk_instance_profile_role.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

