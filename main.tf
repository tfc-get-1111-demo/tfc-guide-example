module "hashi-demo" {
  source          = "./modules/mock-splunk"
  region          = var.region_primary
  mock_splunk     = var.mock_splunk
  instance_size   = var.instance_size
  subnet_id       = module.hashi-demo-vpc.public_subnets[0]
  mandatory_tags  = var.mandatory_tags
  providers = {
    aws = aws
  }
}

module "hashi-demo-secondary" {
  source          = "./modules/mock-splunk"
  region          = var.region_secondary
  mock_splunk     = var.mock_splunk
  instance_size   = var.instance_size
  subnet_id       = module.hashi-demo-vpc-secondary.public_subnets[0]
  mandatory_tags  = var.mandatory_tags
  providers = {
    aws = aws.secondary
  }
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

resource "aws_iam_policy_attachment" "ssm_managed" {
  name       = "ssm-managed"
  roles      = [aws_iam_role.splunk_instance_profile_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
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
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
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
        "kms:Decrypt"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
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
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2messages:AcknowledgeMessage",
        "ec2messages:DeleteMessage",
        "ec2messages:FailMessage",
        "ec2messages:GetEndpoint",
        "ec2messages:GetMessages",
        "ec2messages:SendReply"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
