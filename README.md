### SFDC Change Data Capture on ECS

Based on AWS Fargate, Docker application written in Rust which connects to Salesforce to fetch Change Data Capture data.

## How To

1- Create a repo in ECR (`sfdc_realtime`) and a cluster (`sfdc-realtime`)

2- Create VPC with:

  a- Public Subnet, with a route table 0.0.0.0/0 to an internet gateway
  b- Security Group with NO inbound rules (the app doesn't need any inbound communication), only outbound rules wide open

3- Rename `task-definition.default.json` to `task-definition.json` and replace the placeholders `AWS_ACCOUNT_ID` and set the Salesforce Environment variables

4- Replace the first few lines of the `Makefile` with your own variables, and at least `AWS_ACCOUNT_ID`, `SUBNET_ID`, `SECURITY_GROUP_ID`. The subnet and security group ID can be retrieved in the step 2- above.

5- Run commands

  a- `make login`  (every few hours as your AWS session will expire automatically)
  b- `make init`   (once)
  c- `make update` (code change)

6- Manual Run

```
  docker run --rm -it \
		-e USERNAME='salesforce@username.com' \
		-e PASSWORD='password_and_security_token' \
		-e INSTANCE_URL='https://login.salesforce.com' \
		-e SUBSCRIPTION='/data/AccountChangeEvent' \
		sfdc_realtime
```