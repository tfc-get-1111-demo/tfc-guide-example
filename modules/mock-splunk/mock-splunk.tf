data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "mock_splunk" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = var.instance_size
  iam_instance_profile = aws_iam_instance_profile.splunk_instance_profile.id
  
  network_interface {
    network_interface_id = aws_network_interface.mock_splunk.id
    device_index         = 0
  }

  user_data     = file("${path.module}/templates/user-data.sh")

  tags          = merge({
      "Name" = "${var.mock_splunk}"
    },
    var.mandatory_tags)
  }

resource "aws_network_interface" "mock_splunk" {
  subnet_id   = var.subnet_id
  #private_ips = ["10.11.12.10"]

  tags = merge({
      "Name" = "primary_network_interface"
    },
    var.mandatory_tags)
  }

resource "aws_eip" "mock_splunk" {
  instance = aws_instance.mock_splunk.id
  vpc      = true
}
