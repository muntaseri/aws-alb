echo "Enter ALB DNS Name"
read ALB_DNS 
##ALB_DNS="my-alb-123456789.us-east-1.elb.amazonaws.com"
for i in {1..10}; do curl -s http://$ALB_DNS/; done
