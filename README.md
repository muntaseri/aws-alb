# Option A – AWS Application Load Balancer



# Architecture Design

Architectural Overview
The architecture is deployed inside a custom Amazon VPC spanning two distinct Availability Zones. Public-facing traffic enters through an Application Load Balancer (ALB) residing in public subnets across both AZs. The ALB distributes incoming requests to two backend Amazon EC2 web server instances, each placed in a separate Availability Zone and protected by dedicated security groups.<br>


<br>
<br>
---
![Architecture Design] (./screenshots/AD.png)

---
Network & Infrastructure Specifications<br>


VPC: Custom VPC (10.0.0.0/16) configured with an Internet Gateway (IGW).<br>
Subnets:<br>
Public Subnet 1: 10.0.1.0/24 (Availability Zone: us-east-1a)<br>
Public Subnet 2: 10.0.2.0/24 (Availability Zone: us-east-1b)<br>
Security Groups:<br>
ALB Security Group (sg-alb): Allows inbound HTTP (TCP 80) and HTTPS (TCP 443) from anywhere (0.0.0.0/0).<br>
EC2 / Target Security Group (sg-ec2): Allows inbound HTTP (TCP 80) strictly from the ALB Security Group (sg-alb), blocking direct user access.<br><br>


Component Roles<br>
Internet Gateway (IGW): Enables internet connectivity to and from the VPC.<br>
Application Load Balancer (ALB): Acts as the single entry point, distributing client requests across target instances.<br>
Target Group: Routes requests to registered EC2 instances and performs active health monitoring.<br>
EC2 Instances: Compute nodes running the web server application within isolated AZ subnets.<br>





# Problem 2

Two EC2 instances are launched in separate Availability Zones (us-east-1a and us-east-1b). A bootstrap User Data script configures a lightweight Node.js/Python web server on startup.
<br>

EC2 User Data Script (user-data.sh) attached on config folder
<br>
---

