resource "aws_cloudwatch_event_rule" "tilegarden_warming_rule" {
    name = "WarmTilegarden${var.environment}"
    description = "Scheduled event to keep Tilegarden instances warm."
    schedule_expression = "rate(15 minutes)"
}

resource "aws_cloudwatch_event_target" "tilegarden_warming_event" {
    rule = "${aws_cloudwatch_event_rule.tilegarden_warming_rule.name}"
    target_id = "${var.tilegarden_function_name}"
    arn = "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:${var.tilegarden_function_name}"
    input = "{\"warmer\":true,\"concurrency\":20}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_tilegarden" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${var.tilegarden_function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.tilegarden_warming_rule.arn}"
}
