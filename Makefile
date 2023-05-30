IMAGE_NAME=sfdc_realtime
CLUSTER=sfdc-realtime
SERVICE=sfdc-realtime
ACCOUNT_ID=369147653852
REGION=eu-central-1
SUBNET_ID=subnet-0ceec7e4020dfbc17
SECURITY_GROUP_ID=sg-008d1fe1e762a8f8c

login:
	aws ecr get-login-password --region $(REGION) | docker login --username AWS --password-stdin $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com

init:
	docker build -t $(IMAGE_NAME) .
	docker tag $(IMAGE_NAME):latest $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/$(IMAGE_NAME):latest
	docker push $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/$(IMAGE_NAME):latest
	aws logs create-log-group --log-group-name /ecs/$(SERVICE)
	aws ecs register-task-definition --cli-input-json file://task-definition.json
	aws ecs create-service \
		--cluster $(CLUSTER) \
		--task-definition $(SERVICE) \
		--desired-count 1 \
		--deployment-configuration "maximumPercent=200,minimumHealthyPercent=100,deploymentCircuitBreaker={enable=true,rollback=true}" \
		--launch-type FARGATE \
		--network-configuration "awsvpcConfiguration={subnets=['$(SUBNET_ID)'],securityGroups=['$(SECURITY_GROUP_ID)'],assignPublicIp=ENABLED}" \
		--service-name $(SERVICE)

update:
	docker build -t $(IMAGE_NAME) .
	docker tag $(IMAGE_NAME):latest $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/$(IMAGE_NAME):latest
	docker push $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/$(IMAGE_NAME):latest
	$(eval TASK_DEFINITION_OUTPUT=$(shell aws ecs register-task-definition --cli-input-json file://task-definition.json))
	$(eval TASK_DEFINITION_ARN=$(shell echo '$(TASK_DEFINITION_OUTPUT)' | jq -r '.taskDefinition.taskDefinitionArn'))
	aws ecs update-service --cluster $(CLUSTER) --service $(SERVICE) --task-definition $(TASK_DEFINITION_ARN)



