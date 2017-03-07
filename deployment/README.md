# Amazon Web Services Deployment

Amazon Web Services deployment is driven by [Terraform](https://terraform.io/) and the [AWS Command Line Interface (CLI)](http://aws.amazon.com/cli/).

## Table of Contents

* [AWS Credentials](#aws-credentials)
* [Terraform](#terraform)
* [AWS Batch](#aws-batch)

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
vagrant@vagrant-ubuntu-trusty-64:~$ export GIT_COMMIT="<short-commit-to-deploy>"
vagrant@vagrant-ubuntu-trusty-64:~$ export AWS_PROFILE="pfb"
vagrant@vagrant-ubuntu-trusty-64:~$ export PFB_AWS_ECR_ENDPOINT="<aws-account-id>.dkr.ecr.us-east-1.amazonaws.com"
vagrant@vagrant-ubuntu-trusty-64:~$ ./scripts/cibuild && ./scripts/cipublish
```

Next, use the `infra` wrapper script to lookup the remote state of the infrastructure and assemble a plan for work to be done:

```bash
vagrant@vagrant-ubuntu-trusty-64:~$ export PFB_SETTINGS_BUCKET="staging-pfb-config-us-east-1"
vagrant@vagrant-ubuntu-trusty-64:~$ ./scripts/infra plan
```

Once the plan has been assembled, and you agree with the changes, apply it:

```bash
vagrant@vagrant-ubuntu-trusty-64:~$ ./scripts/infra apply
```
This will attempt to apply the plan assembled in the previous step using Amazon's APIs. In order to change specific attributes of the infrastructure, inspect the contents of the environment's configuration file in Amazon S3.

## AWS Batch

Parts of the AWS Batch stack must be created manually. This includes:
- The Managed Compute Environment
- The appropriate Job Queues for each Compute Environment

Once these are created, the automated deployment handles creation of the latest revision of the appropriate Job Definitions via `./scripts/infra`

### Creating a Batch Compute Environment

Login to the AWS Console and navigate to [AWS Batch: Compute Environments](https://console.aws.amazon.com/batch/home?region=us-east-1#/compute-environments)

Click the 'Create Environment' button, then edit the new form with the inputs below:
- Compute environment type: 'managed'
- Compute environment name: '<environment>-pfb-analysis-<on-demand|spot>-compute-environment'
- Service role: AWSBatchServiceRole
- Instance role: StagingContainerInstanceRole
- EC2 key pair: your choice
- Enable compute environment: [x]
- Provisioning model:
  - staging: 'on-demand' -- better fits fewer, should always be available for developers
  - production: 'spot' -- better fits larger jobs with less stringent completion requirements
- Allowed instance types:
  - staging: 'm3.xlarge'
  - production: 'm3.2xlarge'
- Minimum vCPUs: 0
- Desired vCPUs: 0
- Maximum vCPUs: 256 (default is fine)
- VPC ID: Choose the VPC that matches to the environment you're launching in
  - e.g. VPC 'pfbStaging' for the staging environment
- Subnets: Select all of the private subnets for the VPC you chose
- Security groups: 'default'
- EC2 tags:
  - Key: 'environment', Value: '<staging|production>'
Click 'Create' and wait for the compute environment to provision.

Next, go to 'Job queues' -> 'Create queue' then edit the form with the inputs below:
- Queue name: '<environment>-pfb-analysis-job-queue'
- Priority: leave blank
- Enable job queue: [x]
- Select a compute environment: Choose the name of the environment you just created
Lastly, click create.

Congratulations, the necessary resources for your environment are ready!

