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
  user_data = base64encode(file("/templates/user_data.sh"))

  tags = var.mandatory_tags
}


# Create an ssh key for Splunk HF instances and put it in Secrets Manager
resource "tls_private_key" "splunk_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "splunk_key"
  public_key = tls_private_key.splunk_ssh_key.public_key_openssh
  tags       = var.tags
}

resource "aws_secretsmanager_secret" "splunk_key" {
  name                    = "splunk_key"
  description             = "splunk ssh key"
  kms_key_id              = var.kms_firehose_key
  recovery_window_in_days = 7
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "splunk_key" {
  secret_id     = aws_secretsmanager_secret.splunk_key.id
  secret_string = tls_private_key.splunk_ssh_key.private_key_pem
}

resource "random_password" "splunk_password" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "splunk_password" {
  name                    = "splunk_password"
  description             = "splunk app password"
  kms_key_id              = var.kms_firehose_key
  recovery_window_in_days = 7
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "splunk_password" {
  secret_id     = aws_secretsmanager_secret.splunk_password.id
  secret_string = random_password.splunk_password.result
}
# EC2 instance-related Block

resource "aws_iam_role" "splunk_instance_profile_role" {
  name = "SplunkInstanceProfileRole"
  path = "/"
  tags = var.tags

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
            "Effect": "Allow",
            "Action": [
                "kms:ListKeys",
                "kms:ListAliases",
                "kms:ListKeyPolicies"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt",
                "kms:Encrypt",
                "kms:DescribeKey",
                "kms:ReEncrypt*",
                "kms:GetKeyPolicy",
                "kms:GetKeyRotationStatus"

            ],
            "Resource": [
                "${var.kms_firehose_key_arn}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecrets"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": "arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:splunk*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel",
                "ssm:DescribeAssociation",
                "ssm:GetDeployablePatchSnapshotForInstance",
                "ssm:GetDocument",
                "ssm:DescribeDocument",
                "ssm:GetManifest",
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:ListAssociations",
                "ssm:ListInstanceAssociations",
                "ssm:PutInventory",
                "ssm:PutComplianceItems",
                "ssm:PutConfigurePackageResult",
                "ssm:UpdateAssociationStatus",
                "ssm:UpdateInstanceAssociationStatus",
                "ssm:UpdateInstanceInformation"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetEncryptionConfiguration"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "ec2:DescribeVolumes",
                "ec2:DescribeTags",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams",
                "logs:DescribeLogGroups",
                "logs:CreateLogStream",
                "logs:CreateLogGroup"
            ],
            "Resource": "*"
        }
  ]
}
EOF
}

