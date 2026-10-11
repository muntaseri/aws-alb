# Option A – AWS Application Load Balancer



# Architecture Design

Architectural Overview
The architecture is deployed inside a custom Amazon VPC spanning two distinct Availability Zones. Public-facing traffic enters through an Application Load Balancer (ALB) residing in public subnets across both AZs. The ALB distributes incoming requests to two backend Amazon EC2 web server instances, each placed in a separate Availability Zone and protected by dedicated security groups.
Network & Infrastructure Specifications


VPC: Custom VPC (10.0.0.0/16) configured with an Internet Gateway (IGW).
Subnets:
Public Subnet 1: 10.0.1.0/24 (Availability Zone: us-east-1a)
Public Subnet 2: 10.0.2.0/24 (Availability Zone: us-east-1b)
Security Groups:
ALB Security Group (sg-alb): Allows inbound HTTP (TCP 80) and HTTPS (TCP 443) from anywhere (0.0.0.0/0).
EC2 / Target Security Group (sg-ec2): Allows inbound HTTP (TCP 80) strictly from the ALB Security Group (sg-alb), blocking direct user access.
Component Roles
Internet Gateway (IGW): Enables internet connectivity to and from the VPC.
Application Load Balancer (ALB): Acts as the single entry point, distributing client requests across target instances.
Target Group: Routes requests to registered EC2 instances and performs active health monitoring.
EC2 Instances: Compute nodes running the web server application within isolated AZ subnets.