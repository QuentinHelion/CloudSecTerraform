# CloudSecTerraform

## Run this code on a new instance 

Setup your account with **aws configure**

Edit variables.tfvars and put a new name for the S3 bucket and EC2 instance

Run terraform init && terraform apply --auto-approve

If you get an error related to policy / account already existing, run these commands :

### Get your Account ID

```aws sts get-caller-identity --query Account --output text #To get your Account ID```

### Delete User and Policy and Terraform will recreate them from scratch

```aws iam delete-user --user-name tf-kungfu-user```
```aws iam delete-policy --policy-arn arn:aws:iam::ACCOUNT_ID:policy/tf-fake-admin-policy```s
