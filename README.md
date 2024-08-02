# Fork notes

Note:
The IaC CI/CD above is a fork of an [AWS sample repository](https://github.com/aws-samples/aws-codepipeline-terraform-cicd-samples) which needed some fixing. The following changes were made:

- The variable _create_new_role_ set to true: so that a role or CodePipeline is created automatically by default.
- The variable [_create_new_repo_] set to false: the original code uses CodeCommit which is [no longer accepting new customers](https://aws.amazon.com/blogs/devops/how-to-migrate-your-aws-codecommit-repository-to-another-git-provider/).
  examples/terraform.tfvars
- Disabled S3 replication to reduce unnecessary deployment for this lab
- Connections to external sources have been renamed - permissions had to be adjusted/ (https://docs.aws.amazon.com/dtconsole/latest/userguide/rename.html)
- Manually update pending connection (https://docs.aws.amazon.com/dtconsole/latest/userguide/connections-update.html)

<br /><br />

_---- End of changes to original README ----_
<br /><br />

# AWS CodePipeline CI/CD example

Terraform is an infrastructure-as-code (IaC) tool that helps you create, update, and version your infrastructure in a secure and repeatable manner.

The scope of this pattern is to provide a guide and ready to use terraform configurations to setup validation pipelines with end-to-end tests based on AWS CodePipeline, AWS CodeBuild, AWS CodeCommit and Terraform.

The created pipeline uses the best practices for infrastructure validation and has the below stages

- validate - This stage focuses on terraform IaC validation tools and commands such as terraform validate, terraform format, tfsec, tflint and checkov
- plan - This stage creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure.
- apply - This stage uses the plan created above to provision the infrastructure in the test account.
- destroy - This stage destroys the infrastructure created in the above stage.
  Running these four stages ensures the integrity of the terraform configurations.

## Directory Structure

```shell
|-- CODE_OF_CONDUCT.md
|-- CONTRIBUTING.md
|-- LICENSE
|-- README.md
|-- data.tf
|-- examples
|   `-- terraform.tfvars
|-- locals.tf
|-- main.tf
|-- modules
|   |-- codebuild
|   |   |-- README.md
|   |   |-- main.tf
|   |   |-- outputs.tf
|   |   `-- variables.tf
|   |-- codecommit
|   |   |-- README.md
|   |   |-- data.tf
|   |   |-- main.tf
|   |   |-- outputs.tf
|   |   `-- variables.tf
|   |-- codepipeline
|   |   |-- README.md
|   |   |-- main.tf
|   |   |-- outputs.tf
|   |   `-- variables.tf
|   |-- iam-role
|   |   |-- README.md
|   |   |-- data.tf
|   |   |-- main.tf
|   |   |-- outputs.tf
|   |   `-- variables.tf
|   |-- kms
|   |   |-- README.md
|   |   |-- main.tf
|   |   |-- outputs.tf
|   |   `-- variables.tf
|   `-- s3
|       |-- README.md
|       |-- main.tf
|       |-- outputs.tf
|       `-- variables.tf
|-- templates
|   |-- buildspec_apply.yml
|   |-- buildspec_destroy.yml
|   |-- buildspec_plan.yml
|   |-- buildspec_validate.yml
|   `-- scripts
|       `-- tf_ssp_validation.sh
`-- variables.tf

```

## Installation

#### Step 1: Clone this repository.

```shell
git@github.com:aws-samples/aws-codepipeline-terraform-cicd-samples.git
```

Note: If you don't have git installed, [install git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).

#### Step 2: Update the variables in `examples/terraform.tfvars` based on your requirement. Make sure you ae updating the variables project_name, environment, source_repo_name, source_repo_branch, create_new_repo, stage_input and build_projects.

- If you are planning to use an existing terraform CodeCommit repository, then update the variable create_new_repo as false and provide the name of your existing repo under the variable source_repo_name
- If you are planning to create new terraform CodeCommit repository, then update the variable create_new_repo as true and provide the name of your new repo under the variable source_repo_name

#### Step 3: Update remote backend configuration as required

#### Step 4: Configure the AWS Command Line Interface (AWS CLI) where this IaC is being executed. For more information, see [Configuring the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).

#### Step 5: Initialize the directory. Run terraform init

#### Step 6: Start a Terraform run using the command terraform apply

Note: Sample terraform.tfvars are available in the examples directory. You may use the below command if you need to provide this sample tfvars as an input to the apply command.

```shell
terraform apply -var-file=./examples/terraform.tfvars
```

## Pre-Requisites

#### Step 1: You would get source_repo_clone_url_http as an output of the installation step. Clone the repository to your local.

git clone <source_repo_clone_url_http>

#### Step 2: Clone this repository.

```shell
git@github.com:aws-samples/aws-eks-accelerator-for-terraform.git
```

Note: If you don't have git installed, [install git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).

#### Step 3: Copy the templates folder to the AWS CodeCommit sourcecode repository which contains the terraform code to be deployed.

```shell
cd examples/ci-cd/aws-codepipeline
cp -r templates $YOUR_CODECOMMIT_REPO_ROOT
```

#### Step 4: Update the variables in the template files with appropriate values and push the same.

#### Step 5: Trigger the pipeline created in the Installation step.

**Note1**: The IAM Role used by the newly created pipeline is very restrictive and follows the Principle of least privilege. Please update the IAM Policy with the required permissions.
Alternatively, use the _**create_new_role = false**_ option to use an existing IAM role and specify the role name using the variable _**codepipeline_iam_role_name**_

**Note2**: If the **create_new_repo** flag is set to **true**, a new blank repository will be created with the name assigned to the variable **_source_repo_name_**. Since this repository will not be containing the templates folder specified in Step 3 nor any code files, the initial run of the pipeline will be marked as failed in the _Download-Source_ stage itself.

**Note3**: If the **create_new_repo** flag is set to **false** to use an existing repository, ensure the pre-requisite steps specified in step 3 have been done on the target repository.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version   |
| ------------------------------------------------------------------------ | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | \>= 1.0.0 |

## Providers

| Name                                             | Version    |
| ------------------------------------------------ | ---------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | \>= 4.20.1 |

## Modules

| Name                                                                                                                                               | Source                 | Version |
| -------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------- | ------- |
| <a name="module_codebuild_terraform"></a> [codebuild_terraform](#module_codebuild_terraform)                                                       | ./modules/codebuild    | n/a     |
| <a name="module_codecommit_infrastructure_source_repo"></a> [codecommit_infrastructure_source_repo](#module_codecommit_infrastructure_source_repo) | ./modules/codecommit   | n/a     |
| <a name="module_codepipeline_iam_role"></a> [codepipeline_iam_role](#module_codepipeline_iam_role)                                                 | ./modules/iam-role     | n/a     |
| <a name="module_codepipeline_kms"></a> [codepipeline_kms](#module_codepipeline_kms)                                                                | ./modules/kms          | n/a     |
| <a name="module_codepipeline_terraform"></a> [codepipeline_terraform](#module_codepipeline_terraform)                                              | ./modules/codepipeline | n/a     |
| <a name="module_s3_artifacts_bucket"></a> [s3_artifacts_bucket](#module_s3_artifacts_bucket)                                                       | ./modules/s3           | n/a     |

## Resources

| Name                                                                                                                          | Type        |
| ----------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                   | data source |

## Inputs

| Name                                                                                                                                       | Description                                                                                 | Type             | Default                                            | Required |
| ------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------- | ---------------- | -------------------------------------------------- | :------: |
| <a name="input_build_project_source"></a> [build_project_source](#input_build_project_source)                                              | aws/codebuild/standard:4.0                                                                  | `string`         | `"CODEPIPELINE"`                                   |    no    |
| <a name="input_build_projects"></a> [build_projects](#input_build_projects)                                                                | Tags to be attached to the CodePipeline                                                     | `list(string)`   | n/a                                                |   yes    |
| <a name="input_builder_compute_type"></a> [builder_compute_type](#input_builder_compute_type)                                              | Relative path to the Apply and Destroy build spec file                                      | `string`         | `"BUILD_GENERAL1_SMALL"`                           |    no    |
| <a name="input_builder_image"></a> [builder_image](#input_builder_image)                                                                   | Docker Image to be used by codebuild                                                        | `string`         | `"aws/codebuild/amazonlinux2-x86_64-standard:3.0"` |    no    |
| <a name="input_builder_image_pull_credentials_type"></a> [builder_image_pull_credentials_type](#input_builder_image_pull_credentials_type) | Image pull credentials type used by codebuild project                                       | `string`         | `"CODEBUILD"`                                      |    no    |
| <a name="input_builder_type"></a> [builder_type](#input_builder_type)                                                                      | Type of codebuild run environment                                                           | `string`         | `"LINUX_CONTAINER"`                                |    no    |
| <a name="input_codepipeline_iam_role_name"></a> [codepipeline_iam_role_name](#input_codepipeline_iam_role_name)                            | Name of the IAM role to be used by the Codepipeline                                         | `string`         | `"codepipeline-role"`                              |    no    |
| <a name="input_create_new_repo"></a> [create_new_repo](#input_create_new_repo)                                                             | Whether to create a new repository. Values are true or false. Defaulted to true always.     | `bool`           | `true`                                             |    no    |
| <a name="input_create_new_role"></a> [create_new_role](#input_create_new_role)                                                             | Whether to create a new IAM Role. Values are true or false. Defaulted to true always.       | `bool`           | `true`                                             |    no    |
| <a name="input_environment"></a> [environment](#input_environment)                                                                         | Environment in which the script is run. Eg: dev, prod, etc                                  | `string`         | n/a                                                |   yes    |
| <a name="input_project_name"></a> [project_name](#input_project_name)                                                                      | Unique name for this project                                                                | `string`         | n/a                                                |   yes    |
| <a name="input_repo_approvers_arn"></a> [repo_approvers_arn](#input_repo_approvers_arn)                                                    | ARN or ARN pattern for the IAM User/Role/Group that can be used for approving Pull Requests | `string`         | n/a                                                |   yes    |
| <a name="input_source_repo_branch"></a> [source_repo_branch](#input_source_repo_branch)                                                    | Default branch in the Source repo for which CodePipeline needs to be configured             | `string`         | n/a                                                |   yes    |
| <a name="input_source_repo_name"></a> [source_repo_name](#input_source_repo_name)                                                          | Source repo name of the CodeCommit repository                                               | `string`         | n/a                                                |   yes    |
| <a name="input_stage_input"></a> [stage_input](#input_stage_input)                                                                         | Tags to be attached to the CodePipeline                                                     | `list(map(any))` | n/a                                                |   yes    |

## Outputs

| Name                                                                                   | Description                                      |
| -------------------------------------------------------------------------------------- | ------------------------------------------------ |
| <a name="output_codebuild_arn"></a> [codebuild_arn](#output_codebuild_arn)             | The ARN of the Codebuild Project                 |
| <a name="output_codebuild_name"></a> [codebuild_name](#output_codebuild_name)          | The Name of the Codebuild Project                |
| <a name="output_codecommit_arn"></a> [codecommit_arn](#output_codecommit_arn)          | The ARN of the Codecommit repository             |
| <a name="output_codecommit_name"></a> [codecommit_name](#output_codecommit_name)       | The name of the Codecommit repository            |
| <a name="output_codecommit_url"></a> [codecommit_url](#output_codecommit_url)          | The Clone URL of the Codecommit repository       |
| <a name="output_codepipeline_arn"></a> [codepipeline_arn](#output_codepipeline_arn)    | The ARN of the CodePipeline                      |
| <a name="output_codepipeline_name"></a> [codepipeline_name](#output_codepipeline_name) | The Name of the CodePipeline                     |
| <a name="output_iam_arn"></a> [iam_arn](#output_iam_arn)                               | The ARN of the IAM Role used by the CodePipeline |
| <a name="output_kms_arn"></a> [kms_arn](#output_kms_arn)                               | The ARN of the KMS key used in the codepipeline  |
| <a name="output_s3_arn"></a> [s3_arn](#output_s3_arn)                                  | The ARN of the S3 Bucket                         |
| <a name="output_s3_bucket_name"></a> [s3_bucket_name](#output_s3_bucket_name)          | The Name of the S3 Bucket                        |

<!-- END_TF_DOCS -->

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.
