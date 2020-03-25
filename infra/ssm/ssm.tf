resource "aws_ssm_maintenance_window" "window" {
  name = "${var.stack_name}-maintenance-window"
  schedule = "cron(0 0 2 ? * * *)"
  duration = 2
  cutoff = 1
}

resource "aws_ssm_maintenance_window_target" "target" {
  name = "${var.stack_name}-maintenance-window-target"
  description = "Created by Terraform"
  window_id = "${aws_ssm_maintenance_window.window.id}"
  resource_type = "INSTANCE"

  targets {
    key = "tag:Patch Group"
    values = ["windows"]
  }
}

resource "aws_ssm_patch_group" "patchgroup" {
  # Default Patch Baseline for Windows Provided by AWS
  baseline_id = "arn:aws:ssm:ap-southeast-2:547428446776:patchbaseline/pb-03df220ec156a717d"
  patch_group = "windows"
}


resource "aws_ssm_maintenance_window_task" "task" {
  window_id = "${aws_ssm_maintenance_window.window.id}"
  task_type = "RUN_COMMAND"
  task_arn = "AWS-RunPatchBaseline"
  priority = 1
  service_role_arn = "${aws_iam_role.maintenance_role.arn}"
  max_concurrency = "1"
  max_errors = "1"

  targets {
    key = "WindowTargetIds"
    values = [
      "${aws_ssm_maintenance_window_target.target.id}"]
  }

  task_invocation_parameters {
    run_command_parameters {
      parameter {
        name = "Operation"
        values = ["Install"]
      }
    }
  }
}

resource "aws_ssm_association" "gather_inventory" {
  name = "AWS-GatherSoftwareInventory"
  schedule_expression = "cron(0 0 0/8 ? * * *)"

  targets {
    key = "tag:Patch Group"
    values = ["windows"]
  }
}

resource "aws_ssm_association" "scan_patch_baseline" {
  name = "AWS-RunPatchBaseline"
  schedule_expression = "cron(0 0 0/2 ? * * *)"

  targets {
    key = "tag:Patch Group"
    values = ["windows"]
  }

  parameters={
    Operation:  "Scan"
  }
}
