# Amazon Web Services Deployment

Amazon Web Services deployment is driven by [Terraform](https://terraform.io/) and the [AWS Command Line Interface (CLI)](http://aws.amazon.com/cli/).

**NOTE**: Before deploying an AWS stack for the first time, ensure you've created the necessary resources detailed in the [AWS Batch](#aws-batch) section of this README.

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
vagrant@vagrant-ubuntu-trusty-64:~$ export ENVIRONMENT="staging|production"
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
- Compute environment type: `unmanaged`
- Compute environment name: `<environment>-pfb-analysis-unmanaged-compute-environment`
- Service role: AWSBatchServiceRole
- Instance role: StagingContainerInstanceRole
- EC2 key pair: your choice
- Enable compute environment: [x]
Click 'Create' and wait for the compute environment to provision.

Next, go to 'Job queues' -> 'Create queue' then edit the form with the inputs below:
- Queue name: `<environment>-pfb-analysis-job-queue`
- Priority: 1
- Enable job queue: [x]
- Select a compute environment: Choose the name of the environment you just created
Click create. The job queue should be ready pretty much immediately.

Click 'Create queue' again and follow the same steps to create a second queue named `<environment>-pfb-tilemaker-job-queue`.

Once the unmanaged compute environment has a 'VALID' status, navigate to [EC2 Container Service](https://console.aws.amazon.com/ecs/home?region=us-east-1) and copy the full name of the newly created ECS Cluster into the `batch_ecs_cluster_name` tfvar for the appropriate environment.

Congratulations, the necessary resources for your environment are ready. The ECS instance configuration and autoscaling group attached to the compute environment are managed by Terraform.
