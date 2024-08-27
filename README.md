# 1oT sysadmin homework

The aim of this homework is to further develop an already working system by adding new features. It tests your ability to understand how the technology stack is integrated, while not requiring you to go through the steep learning curve.

The entire system is run by Docker Compose. Localstack emulates an AWS environment. There is a `tfrunner` container for you to work with Terraform. Terraform manages the AWS resources. Terraform is a configuration/programming language to ease complicated setups. Terraform backend is stored to an existing S3 bucket in Localstack.

--

1) Add another HTTP endpoint that serves a file from an S3 bucket. Create the S3 bucket with Terraform. You can use the [provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) directly or use `terraform/modules/terraform-aws-s3-bucket`.

2) Fill `private_subnets` variable with values given the VPC configuration above in the `terraform/local.auto.tfvars` file. Add three blocks like in `public_subnets`.

There are two options for the 3rd task, choose one. 

1) Make the Localstack depend on [Docker-in-Docker](https://hub.docker.com/_/docker) container socket instead of the Docker running on your local machine.
2) Add an API that serves text content from DynamoDB table using Lambda.

Finally, commit (git) your work to the same repository and send it back via public repo link or email. Please add some documentation in MD format to accompany the changes in code.

## Prepare the environment

Before starting the homework, first, build Docker images locally and run detached

    docker-compose up --build --detach

Then, enter the worker (runner) container

    docker exec -it tfrunner-cnt bash -l

Verify that you have the necessary tools

    terraform --version
    aws --version

Go to the bind mount folder containing project files. Note that the files are always in sync between the host and the container.

    cd /mnt/terraform

Initialize the backend state file on S3

    terraform init -upgrade \
        -backend-config=endpoint="http://localstack:4566" \
        -backend-config=access_key="myrootaccesskeyid" \
        -backend-config=secret_key="myrootsecretaccesskey" \
        -backend-config=bucket="1ot-platform-state-local" \
        -backend-config=key="tfstate.json" \
        -backend-config=region="eu-west-3" \
        -backend-config=skip_credentials_validation=true \
        -backend-config=skip_metadata_api_check=true \
        -backend-config=skip_region_validation=true \
        -backend-config=force_path_style=true

Create Terraform plan

    terraform plan -out .terraform/tf-plan.out
    
Apply the plan

    terraform apply ".terraform/tf-plan.out"

You should see an URL from Terraform console output to test the ApiGW endpoint

    curl -X GET http://localstack:4566/restapis/d6ww3oe8ml/test/_user_request_/ -vv

Run the cURL and the API will reply `Cheers from AWS Lambda!!`.

Now you can proceed to the task.

## Additional info

There are two containers running in Compose:
- Localstack emulates the AWS endpoints. When you destroy the localstack container, all AWS resources are lost.
- tfrunner is an Ubuntu container to encapsulate the work environment, so you would only need Docker to run the system.
- Terraform state file is in `1ot-platform-state-local` S3 bucket. 
- You can also use awscli on tfrunner for testing, but the homework is designed so it wouldn't be necessary.

### Helpers

    docker-compose up -d --no-deps --build localstack # to build only the localstack

    terraform show # prints the current resources (from state)
