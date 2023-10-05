resource "aws_lb_target_group" "frontend_http" {

  name                          = "${var.application_name}-${var.environment_name}-frontend-http"
  port                          = "5000"
  protocol                      = "HTTP"
  vpc_id                        = aws_vpc.main.id
  slow_start                    = 0
  load_balancing_algorithm_type = "round_robin"

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }

  health_check {
    enabled             = true
    port                = 5000
    interval            = 30
    protocol            = "HTTP"
    path                = "/"
    matcher             = 200
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

}

resource "aws_lb_target_group_attachment" "frontend_http" {

  for_each = aws_instance.frontend

  target_group_arn = aws_lb_target_group.frontend_http.arn
  target_id        = each.value.id
  port             = 5000

}

resource "aws_lb" "frontend" {
  name               = "${var.application_name}-${var.environment_name}"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.frontend.*.id
  security_groups    = [aws_security_group.frontend_lb.id]
}

resource "aws_lb_listener" "frontend_http" {

  load_balancer_arn = aws_lb.frontend.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_http.arn
  }
}