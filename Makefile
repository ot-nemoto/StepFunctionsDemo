deploy_bucket_stack_name = step-functions-demo-bucket-stack
sam_stack_name = step-functions-demo-stack
make = make --no-print-directory
email = step-functions-demo@example.com

create-deploy-bucket-stack:
ifneq ($(shell aws cloudformation describe-stacks \
  --query 'Stacks[?StackName==`${deploy_bucket_stack_name}`].StackName' \
  --output text 2>/dev/null), ${deploy_bucket_stack_name})
	aws cloudformation create-stack --stack-name $(deploy_bucket_stack_name) --template-body file://bucket-template.yaml
	aws cloudformation wait stack-create-complete --stack-name $(deploy_bucket_stack_name)
endif

deploy: create-deploy-bucket-stack
	$(eval bucket := $(shell aws cloudformation describe-stacks \
	  --stack-name ${deploy_bucket_stack_name} \
	  --query 'Stacks[].Outputs[?OutputKey==`S3Bucket`].OutputValue' \
	  --output text))
	sam package --s3-bucket $(bucket) --output-template-file packaged.yml
	sam deploy --template-file packaged.yml --stack-name $(sam_stack_name) --capabilities CAPABILITY_IAM --parameter-overrides NotificationEmail=${email}

undeploy:
	aws cloudformation delete-stack --stack-name $(sam_stack_name)
	aws cloudformation wait stack-delete-complete --stack-name $(sam_stack_name)

remove-deploy-bucket-packages:
ifeq ($(shell aws cloudformation describe-stacks \
  --query 'Stacks[?StackName==`${deploy_bucket_stack_name}`].StackName' \
  --output text 2>/dev/null), ${deploy_bucket_stack_name})
	$(eval bucket := $(shell aws cloudformation describe-stacks\
	  --stack-name ${deploy_bucket_stack_name}\
	  --query 'Stacks[].Outputs[?OutputKey==`S3Bucket`].OutputValue'\
	  --output text))
	aws s3 rm s3://$(bucket) --recursive
endif

delete-deploy-bucket-stack: remove-deploy-bucket-packages
	aws cloudformation delete-stack --stack-name $(deploy_bucket_stack_name)
	aws cloudformation wait stack-delete-complete --stack-name $(deploy_bucket_stack_name)

delete:
	@$(make) undeploy
	@$(make) delete-deploy-bucket-stack
