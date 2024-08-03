#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

resource "aws_codestarconnections_connection" "github" {
  name          = "iac-github-connection"
  provider_type = "GitHub"
}

resource "aws_codebuild_project" "build" {
  name          = "build"
  build_timeout = 30
  service_role  = var.codepipeline_role_arn
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"
  }
  source {
    type = "CODEPIPELINE"
  }

}

resource "aws_codebuild_project" "destroy" {
  name          = "codebuilddestroy"
  build_timeout = 30
  service_role  = var.codepipeline_role_arn
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"
  }
  source {
    buildspec = "./buildspec_destroy.yml"
    type      = "CODEPIPELINE"
  }
  # source {
  #   buildspec = "./buildspec_destroy.yml"
  #   location  = var.s3_bucket_name
  #   type      = "S3"
  # }
}

resource "aws_codepipeline" "terraform_pipeline" {

  name     = "${var.project_name}-pipeline"
  role_arn = var.codepipeline_role_arn
  tags     = var.tags

  artifact_store {
    location = var.s3_bucket_name
    type     = "S3"
    encryption_key {
      id   = var.kms_key_arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceOutput"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = var.source_repo_name
        BranchName       = var.source_repo_branch
      }
    }
  }

  # dynamic "stage" {
  #   for_each = var.stages

  #   content {
  #     name = "Stage-${stage.value["name"]}"
  #     action {
  #       category         = stage.value["category"]
  #       name             = "Action-${stage.value["name"]}"
  #       owner            = stage.value["owner"]
  #       provider         = stage.value["provider"]
  #       input_artifacts  = stage.value["provider"] == "CodeBuild" ? [stage.value["input_artifacts"]] : null
  #       output_artifacts = stage.value["provider"] == "CodeBuild" ? [stage.value["output_artifacts"]] : null
  #       version          = "1"
  #       run_order        = index(var.stages, stage.value) + 2

  #       configuration = {
  #         ProjectName = stage.value["provider"] == "CodeBuild" ? "${var.project_name}-${stage.value["name"]}" : null
  #       }
  #     }
  #   }
  # }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["SourceOutput"]
      output_artifacts = ["BuildOutput"]

      configuration = {
        ProjectName = aws_codebuild_project.build.id
      }
    }
  }

  stage {
    name = "Approve"

    action {
      name     = "DeletionApproval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
    }
  }


  stage {
    name = "Destroy"

    action {
      name             = "Destroy"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["BuildOutput"]
      output_artifacts = ["DestroyOutput"]

      configuration = {
        ProjectName = aws_codebuild_project.destroy.id
      }
    }
  }

}
