# Option A – AWS Application Load Balancer



# Architecture Design

Architectural Overview
The architecture is deployed inside a custom Amazon VPC spanning two distinct Availability Zones. Public-facing traffic enters through an Application Load Balancer (ALB) residing in public subnets across both AZs. The ALB distributes incoming requests to two backend Amazon EC2 web server instances, each placed in a separate Availability Zone and protected by dedicated security groups.<br>



---
(.screenshots/ad.png)

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
Security Verification: Because the EC2 security group only allows ingress on port 80 sourced from sg-alb, attempting to access the EC2 public IP directly from a user browser or local machine will time out.
<br>
---

# Problem 3

## Configure the Load Balancer
An Internet-facing Application Load Balancer (my-alb) is provisioned across both public subnets. An HTTP listener on port 80 forwards incoming traffic to a Target Group containing both EC2 instances.
Request Verification (T2 Test Script)
Sending 10 consecutive requests via curl to the ALB DNS name(./config/check-alb.sh)


<br>
---

## Problem 4
Implement Proper Health Checks
Target Group Health Check Configuration & Justifications

* Protocol / Path (/health): A dedicated lightweight endpoint that returns a 200 OK JSON response without executing heavy computations or database calls.
* Interval (10s / default 30s): The time between health check requests. Set shorter during labs for rapid state transition validation.
* Timeout (5s): The maximum time to wait for a response from an instance before marking the check as failed.
* Healthy Threshold (2): The number of consecutive successful health checks required before an unhealthy instance is marked healthy and returned to rotation.
* Unhealthy Threshold (2): The number of consecutive failed health checks required before an instance is taken out of rotation.

Active vs. Passive Health Checks

* Active Health Checks: Proactive background probes sent by the load balancer at regular intervals (used by AWS ALB).
* Passive Health Checks: Monitoring actual client traffic and error rates to determine instance health on the fly.
* Selected Implementation: AWS ALB exclusively uses active health checks via its configured Target Group settings.


---

# Problem 5
Failure Testing and Proof of Work



Test ID	Action Taken	Expected Outcome
T1 – Health Status	Navigate to EC2 Console \rightarrow Target Groups \rightarrow Targets tab.	Both instances show status Healthy.

T2 – Load Distribution	Execute loop of 10 curl requests against the ALB DNS endpoint.	Responses alternate between Instance 1 and Instance 2.

T3 – Browser Test	Open the ALB DNS URL in a browser and hit refresh multiple times.	Page content updates dynamically between AZ-A and AZ-B instances.

T4 – AZ Failure	Stop the EC2 instance in us-east-1a (aws ec2 stop-instances ...), then send requests.	Instance marked Unhealthy in Target Group; 100% of requests route to us-east-1b with zero client errors.

T5 – Recovery	Start the us-east-1a instance again (aws ec2 start-instances ...).	Instance passes health checks, and traffic automatically resumes balancing across both nodes.

T6 – Logs / Monitoring	Inspect ALB Access Logs in Amazon S3 or CloudWatch Target metrics (RequestCount, HTTPCode_Target_2XX_Count).	Metrics and logs confirm incoming client requests reaching both registered targets.




# Problem 6

AWS ALB vs. NGINX
AWS ALB is a fully managed cloud service that offers seamless scaling, native integration with AWS IAM, security groups, and certificate management (ACM), eliminating underlying OS maintenance. However, it incurs hourly charges and creates cloud vendor lock-in. NGINX provides immense flexibility, zero licensing costs for self-hosted environments, and deep rule customization, but requires manual provisioning for high availability, patching, and scaling.
Handling Load Balancer Single Points of Failure (SPOF)
If the ALB itself failed, ingress traffic would be completely blocked. In a real production architecture, this single point of failure is mitigated by deploying the ALB across multiple Availability Zones with built-in AWS elastic scaling, and fronting it with Amazon Route 53 DNS Failover or an AWS Network Load Balancer (NLB) for multi-region or multi-tier redundancy.
Troubleshooting Challenge
A notable challenge encountered during setup was a 504 Gateway Time-out error when testing requests through the ALB. Inspection revealed that the EC2 security group (sg-ec2) was missing an inbound rule allowing HTTP traffic from the ALB security group (sg-alb). Resolving this rule allowed the ALB health checks and user traffic to successfully reach the backend web servers.
