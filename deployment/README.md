# Amazon Web Services Deployment

Amazon Web Services deployment is driven by [Terraform](https://terraform.io/) and the [AWS Command Line Interface (CLI)](http://aws.amazon.com/cli/).

## Table of Contents

* [AWS Credentials](#aws-credentials)
* [Terraform](#terraform)

## AWS Credentials

Using the AWS CLI, create an AWS profile named `pfb`:

```bash
$ vagrant ssh
vagrant@vagrant-ubuntu-trusty-64:~$ aws --profile pfb configure
AWS Access Key ID [****************F2DQ]:
AWS Secret Access Key [****************TLJ/]:
Default region name [us-east-1]: us-east-1
Default output format [None]:
```

You will be prompted to enter your AWS credentials, along with a default region. These credentials will be used to authenticate calls to the AWS API when using Terraform and the AWS CLI.

## Terraform

If you're deploying new application code, first set the commit to deploy, then build and push containers:
```bash
vagrant@vagrant-ubuntu-trusty-64:~$ export GIT_COMMIT="<commit-to-deploy>"
vagrant@vagrant-ubuntu-trusty-64:~$ export PFB_AWS_ECR_ENDPOINT="<aws-account-id>.dkr.ecr.us-east-1.amazonaws.com"
vagrant@vagrant-ubuntu-trusty-64:~$ ./scripts/cibuild && ./scripts/cipublish
```

Next, use the `infra` wrapper script to lookup the remote state of the infrastructure and assemble a plan for work to be done:

```bash
vagrant@vagrant-ubuntu-trusty-64:~$ export PFB_SETTINGS_BUCKET="staging-pfb-config-us-east-1"
vagrant@vagrant-ubuntu-trusty-64:~$ export AWS_PROFILE="pfb"
vagrant@vagrant-ubuntu-trusty-64:~$ ./scripts/infra plan
```

Once the plan has been assembled, and you agree with the changes, apply it:

```bash
vagrant@vagrant-ubuntu-trusty-64:~$ ./scripts/infra apply
```
This will attempt to apply the plan assembled in the previous step using Amazon's APIs. In order to change specific attributes of the infrastructure, inspect the contents of the environment's configuration file in Amazon S3.
