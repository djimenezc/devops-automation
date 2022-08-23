SELF_DIR ?= ./

TERRAFORM_BUCKET_NAME ?= david-terraform-remote-state-${AWS_DEFAULT_REGION}
TERRAFORM_LOCK_TABLE_NAME ?= terraform-locks

export KEY_NAME ?= terraform.tfstate

TERRAFORM_ADDONS_DIR ?= .terraform/addons

export TF_VAR_jenkins_role_arn ?= ${JENKINS_ROLE_ARN}
export TF_VAR_aws_region ?= ${AWS_DEFAULT_REGION}

get-current-dir:
	@echo Self_dir $(SELF_DIR)

#Terraform
aws-terraform-create-s3-backend:
	@if aws s3 ls "s3://$(TERRAFORM_BUCKET_NAME)" 2>&1 | grep -q 'NoSuchBucket'; then \
  		echo "Creating bucket $(TERRAFORM_BUCKET_NAME)"; \
		aws s3api create-bucket --bucket $(TERRAFORM_BUCKET_NAME) --region ${AWS_DEFAULT_REGION} \
			--create-bucket-configuration LocationConstraint=${AWS_DEFAULT_REGION}; \
		aws s3api put-bucket-encryption --bucket $(TERRAFORM_BUCKET_NAME) \
			--server-side-encryption-configuration \
			'{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'; \
		aws s3api put-public-access-block \
            --bucket $(TERRAFORM_BUCKET_NAME) \
            --public-access-block-configuration \
            'BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true'; \
		aws s3api get-public-access-block --bucket $(TERRAFORM_BUCKET_NAME); \
	fi
	-aws dynamodb create-table --table-name $(TERRAFORM_LOCK_TABLE_NAME) \
	--attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH \
	 --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

aws-terraform-create-s3-backend-rollback:
	aws s3api delete-bucket --bucket $(TERRAFORM_BUCKET_NAME)
	aws dynamodb delete-table --table-name $(TERRAFORM_LOCK_TABLE_NAME)

terraform-plan-action:
	$(call terraform-plan-action)

define terraform-plan-action
endef

terraform-create-workspace:
	@cd ${SELF_DIR}
	terraform workspace select ${TF_VAR_aws_region} || terraform workspace new ${TF_VAR_aws_region}

terraform-init:
	@cd ${SELF_DIR}
	@echo "Current bucket: ${TERRAFORM_BUCKET_NAME} region ${AWS_DEFAULT_REGION}"
	mkdir -p $(TERRAFORM_ADDONS_DIR)
	terraform init -backend-config=bucket=${TERRAFORM_BUCKET_NAME} -backend=true -reconfigure -backend-config=key=${KEY_NAME} -backend-config=role_arn=$(TF_VAR_jenkins_role_arn)

terraform-plan: terraform-create-workspace terraform-plan-action
	terraform plan ${EXTRA_VARS}

terraform-apply: terraform-create-workspace
	terraform apply -auto-approve ${EXTRA_VARS}
	@echo Apply operation run sucessfully

terraform-destroy: terraform-create-workspace
	terraform destroy -auto-approve ${EXTRA_VARS}
	@echo Destroy operation run sucessfully

terraform-plan-destroy: terraform-create-workspace
	terraform plan -destroy ${EXTRA_VARS}

terraform-validate:
	@cd ${SELF_DIR}
	terraform fmt -check -recursive -diff
	terraform validate

terraform-format:
	@cd ${SELF_DIR}
	terraform fmt -recursive

terraform-console:
	@terraform console

infracost-current:
	infracost breakdown --path .

infracost-baseline:
	infracost breakdown --path . --format json --out-file infracost-base.json

infracost-diff:
	infracost diff --path . --compare-to infracost-base.json
