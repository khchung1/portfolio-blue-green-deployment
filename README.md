# Blue-Green-deployment
This project demonstrates blue/green deployment using Terraform for cloud infrastructure provisioning. 
- Blue-Green deployment is a release strategy that minimizes downtime and risk during application updates. It involves maintaining two identical production environments ("Blue" and "Green"). 
- A blue environment is the current application version and green environment is the new version.
- Application Load Balancer is used to direct traffic in a way the green environment is gradually released to clients. This reduces deployment risk by simplfying rollback process if deployment fails.
- Once testing has been completed on the green environment, live application traffic is directed to the green environment and the blue environment is deprecated.

# Architecture Diagram
![alt text](image.png)

Above architecture diagram illustrates Blue-Green deployment in an AWS environment. The diagram consist of the following key components:

1. Internet Gateway:  
   The entry point for traffic from the internet into Virtual Private Cloud (VPC)

2. Application Load Balancer (ALB):
   ALB acts as a traffic management which distributes incoming requests between two Auto Scaling Groups based on weightage set. The ALB is located in public subnet such that it can receive traffic from the internet

3. Auto Scaling Group (ASG):
   There are two ASGs hosting Blue (current) and Green (new) environment. The current traffic weightage is set 70% to Blue, 30% to Green. The ASGs will scale the EC2s horizontally based on traffic volume.

4. Elastic Cloud Compute (EC2):
   The instance that runs the application. For this case the application is a static website page shows the name of the environment (Blue or Green)

In a nutshell, Clients send requests to the application. The requests enter the VPC through the Internet Gateway. The ALB receives the requests and distribute them according to the weightage and direct to the EC2s. Users will receive either Blue or Green website depending on the traffic directed.

# Terraform Code
For organizing resources and improve code readability, the code are split into multiple terraform (.tf) files: 

1. backend.tf     
2. provider.tf
3. main.tf 
4. blue.tf
5. green.tf
6. variables.tf

| Filename | Purpose |
|----------|----------|
|backend.tf | Stores a snapshot of the current state of the deployed resources, including the configuration and dependencies. This allows Terraform to track changes and prevent accidental drifts between your desired infrastructure configuration and the actual deployed resources.|
|provider.tf| Informs Terraform which terraform and AWS version to use|
|main.tf | The code configuration for Application Load Balancer and Web Application Firewall