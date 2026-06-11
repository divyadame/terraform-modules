# working with datasources
# create drift and modify state file
# corrupt state file


sudo systemctl status amazon-ssm-agent
sudo systemctl status sshd

sudo systemctl stop sshd
ssh: connect to host 13.203.25.214 port 22: Connection refused

ways to connect troubleshoot ec2
aws ssm if you enrolled and it's ping status shows online systems manager fleet manager.

How to do register to ssm ?
aws ssm start-session --target i-09141615d237742c1
It won't work if you won't register your EC2 with ssm
Use ec2instance profile role wrap an IAM role having ec2 as prinicple and aws ssm to grant access to manager ec2.

++++++++++++++++++++++++++++++++++++++======
divya@LAPTOP-IV8CO1SO:~$ aws ssm start-session --target i-09141615d237742c1 --region ap-south-1

aws: [ERROR]: An error occurred (TargetNotConnected) when calling the StartSession operation: i-09141615d237742c1 is not connected.
+++++++++++++++++++++++++++++++++++++++++++++++++=

aws ssm describe-instance-information --region ap-south-1 --filters "Key=InstanceIds,Values=i-09141615d237742c1"
{
    "InstanceInformationList": []
}
if it shows ping online then it is registered.

You can use serial console to connect ec2 but it requires username/password.

you can use ec2-instance-connect but it use sshd shoule be running and ec2 should have route to internet and allow inbound port on 22 and sshd should be running.

 aws ec2-instance-connect ssh --instance-id i-09141615d237742c1 --region ap-south-1
ssh: connect to host 13.203.25.214 port 22: Connection refused

the other way if your ec2 in private subnet create ec2 instance endpoint which should be in same subnet as your ec2 and allow inbound traffic on 22 and 
also ec2 sg must allow traffic from EC2 Instance Connect Endpoint (EICE) on port 22 so you can create sg for eice that allows port22 traffic and give eice sg as inbound to ec2 sg
this also relays on ssh so if this not working then you can't able to connect

aws ec2-instance-connect ssh --instance-id i-09141615d237742c1 --connection-type eice --region ap-south-1

aws: [ERROR]: Websocket Closure Reason: Unable to connect to target
Connection closed by UNKNOWN port 65535

Why it fails when sshd is stoppedThe Tunnel Works: Your AWS CLI command successfully talks to the EICE gateway over a WebSocket.The Handshake Drops: The EICE gateway attempts to forward your connection request over the private network to your EC2 instance on Port 22.The Refusal: Because sshd is down, the instance's operating system instantly rejects or ignores the traffic. The EICE gateway realizes nothing is answering on port 22, shuts down the tunnel, and throws the Unable to connect to target / Connection closed by UNKNOWN port 65535 error on your laptop.

```
[ Your Laptop ] (divya@LAPTOP-IV8CO1SO)
       │
       ▼ (1) Authenticates via AWS IAM Credentials
   =====================================================================================
   ║ AWS CLOUD REGION (ap-south-1)                                                     ║
   ║                                                                                   ║
   ║  [ AWS IAM Service ]                                                              ║
   ║         │ (2) Checks permissions & pushes 60-second temporary SSH Public Key      ║
   ║         ▼                                                                         ║
   ║  ===============================================================================  ║
   ║  ║ VIRTUAL PRIVATE CLOUD (VPC)                                                 ║  ║
   ║  ║                                                                             ║  ║
   ║  ║  [ Public Internet or AWS API Endpoint ]                                    ║  ║
   ║  ║         │                                                                   ║  ║
   ║  ║         ▼ (3) Establishes Secure WebSocket Tunnel                           ║  ║
   ║  ║  ┌────────────────────────────────────────────────────────────────────────┐  ║  ║
   ║  ║  │ SUBNET (data.aws_subnets.this.ids[0])                                  │  ║  ║
   ║  ║  │                                                                        │  ║  ║
   ║  ║  │  [ EICE Gateway Network Interface ]                                    │  ║  ║
   ║  ║  │         │  (Attached Security Group: `eice_sg`)                        │  ║  ║
   ║  ║  │         │                                                              │  ║  ║
   ║  ║  │         ▼ (4) Evaluates Outbound Egress Rule (Allows Port 22 out)      │  ║  ║
   ║  ║  │       =======                                                          │  ║  ║
   ║  ║  │                                                                        │  ║  ║
   ║  ║  │         │ (5) Routes over Internal AWS Private Network                 │  ║  ║
   ║  ║  │         └───────────────────┐                                          │  ║  ║
   ║  ║  │                             ▼                                          │  ║  ║
   ║  ║  │                     [ Target EC2 Instance ] (i-09141615d237742c1)      │  ║  ║
   ║  ║  │                            ▲                                           │  ║  ║
   ║  ║  │                            │ (6) Evaluates Inbound Ingress Rule        │  ║  ║
   ║  ║  │                            │     (Allows Port 22 from `eice_sg` ID)    │  ║  ║
   ║  ║  │                            │                                           │  ║  ║
   ║  ║  │                      [ OS LEVEL / FIREWALL LAYER ]                     │  ║  ║
   ║  ║  │                            │                                           │  ║  ║
   ║  ║  │                            ▼ (7) Checks local metadata for token       │  ║  ║
   ║  ║  │                       [ sshd daemon ] (Must be listening on Port 22)   │  ║  ║
   ║  ║  │                                                                        │  ║  ║
   ║  ║  └────────────────────────────────────────────────────────────────────────┘  ║  ║
   ║  ===============================================================================  ║
   =====================================================================================
```
