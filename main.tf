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
  user_data     = file("/templates/user_data.sh")

  tags          = var.mandatory_tags
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

data "aws_iam_policy" "ReadOnlyAccess" {
  arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy" "splunk_instance_profile_policy" {
  name       = "SplunkInstanceProfilePolicy"
  role       = aws_iam_role.splunk_instance_profile_role.name
  policy_arn = "${data.aws_iam_policy.ReadOnlyAccess.arn}"
}

