variable "instance_id" {
  description = "The ID of the EC2 instance to monitor"
  type        = string
}

variable "aws_region" {
  description = "AWS region where resources are deployed"
  type        = string
}

variable "firehose_arn" {
  description = "ARN of the Firehose Delivery Stream"
  type        = string
}
