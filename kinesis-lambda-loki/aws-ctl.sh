#!/bin/bash
#
#

# Documentation References
# https://github.com/SmartThingsCommunity/smartapp-sdk-nodejs/blob/main/docs/index.md
# https://developer.smartthings.com/docs/sdks/smartapp-nodejs/
# https://github.com/topics/smartthings-smartapp-example
# https://developer.smartthings.com/docs/connected-services/hosting/aws-lambda/
# https://developer.smartthings.com/docs/connected-services/hosting/aws-lambda/#option-b-use-the-aws-cli
# https://www.serverless.com/framework/docs/getting-started/

# https://docs.aws.amazon.com/lambda/latest/dg/with-kinesis-example.html


AWS_ROLE_NAME="lambda-kinesis-role"
AWS_LAMBDA_FUNCTION_NAME="ConsumeKinesis"
AWS_ROLE_ARN=""
AWS_KINESIS_STREAM_NAME="lambda-stream-test1"

case $1 in
  aws-create-role)
    aws iam create-role \
        --role-name $AWS_ROLE_NAME \
        --assume-role-policy-document file://aws-trust-policy.json
    aws iam attach-role-policy \
        --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaKinesisExecutionRole \
        --role-name $AWS_ROLE_NAME
  ;;
  aws-get-role)
    aws iam get-role --role-name $AWS_ROLE_NAME
    # role ARN is required for lambda deploy
    # Get the role arn
    AWS_ROLE_ARN=$(aws iam get-role --role-name lambda-kinesis-role | jq -r '.Role.Arn')
    echo "export AWS_ROLE_ARN=$AWS_ROLE_ARN"
    # set in AWS_ROLE_ARN
    ;;
  aws-lambda-deploy)
    zip function.zip index.js
    AWS_ROLE_ARN=$(aws iam get-role --role-name lambda-kinesis-role | jq -r '.Role.Arn')
    aws lambda create-function \
      --function-name $AWS_LAMBDA_FUNCTION_NAME \
      --zip-file fileb://function.zip \
      --handler index.handler --runtime nodejs18.x \
      --role $AWS_ROLE_ARN
  ;;
  aws-lambda-update)
    zip function.zip index.js
    AWS_ROLE_ARN=$(aws iam get-role --role-name lambda-kinesis-role | jq -r '.Role.Arn')
    aws lambda update-function-code \
      --function-name $AWS_LAMBDA_FUNCTION_NAME \
      --zip-file fileb://function.zip
  ;;
  aws-kinesis-create-stream)
    aws kinesis create-stream --stream-name $AWS_KINESIS_STREAM_NAME --shard-count 1
    ;;
  aws-kinesis-describe-stream)
    aws kinesis describe-stream --stream-name $AWS_KINESIS_STREAM_NAME
    AWS_KINESIS_STREAM_ARN=$(aws kinesis describe-stream --stream-name $AWS_KINESIS_STREAM_NAME | jq -r '.StreamDescription.StreamARN')
    echo "export AWS_KINESIS_STREAM_ARN=$AWS_KINESIS_STREAM_ARN"
    ;;
  aws-kinesis-add-event-source)
    AWS_KINESIS_STREAM_ARN=$(aws kinesis describe-stream --stream-name $AWS_KINESIS_STREAM_NAME | jq -r '.StreamDescription.StreamARN')
    aws lambda create-event-source-mapping \
        --function-name $AWS_LAMBDA_FUNCTION_NAME \
        --event-source  $AWS_KINESIS_STREAM_ARN \
        --batch-size 100 --starting-position LATEST
  ;;
  aws-kinesis-list-event-source-mappings)
    AWS_KINESIS_STREAM_ARN=$(aws kinesis describe-stream --stream-name $AWS_KINESIS_STREAM_NAME | jq -r '.StreamDescription.StreamARN')
    echo "export AWS_KINESIS_STREAM_ARN=$AWS_KINESIS_STREAM_ARN"
    aws lambda list-event-source-mappings \
      --function-name $AWS_LAMBDA_FUNCTION_NAME \
      --event-source $AWS_KINESIS_STREAM_ARN
  ;;
  aws-kinesis-put)
    MSG_STR="David Ryder $(date)"
    MSG_B64=$(echo $MSG_STR | base64)
    echo "$MSG_STR"
    aws kinesis put-record --stream-name $AWS_KINESIS_STREAM_NAME --partition-key 1 --data "$MSG_B64"  
  ;;
  serverless-deploy)
    serverless deploy
  ;;
  serverless-deploy-fast)
    serverless deploy function --function smartapp \
      --stage dev \
      --region us-west-1
  ;;
  serverless-config)
    serverless config credentials \
      --provider aws \
      --key $AWS_ACCESS_KEY_ID \
      --secret $AWS_SECRET_ACCESS_KEY \
      --overwrite 
    ;;
  aws-get-function-config)
    aws lambda get-function-configuration \
      --function-name $AWS_LAMBDA_FUNCTION_NAME
  ;;
  aws-lambda-add-permission)
    aws lambda add-permission \
      --profile $AWS_PROFILE_NAME \
      --region $AWS_REGION \
      --function-name $AWS_LAMBDA_FUNCTION_NAME \
      --statement-id smartthings \
      --principal $AWS_SERVICS_ACCOUNT_PRINCIPLE \
      --action lambda:InvokeFunction
    ;;
  aws-lambda-remove-permission)
    aws lambda remove-permission \
      --profile $AWS_PROFILE_NAME \
      --region $AWS_REGION \
      --function-name $AWS_LAMBDA_FUNCTION_NAME \
      --statement-id smartthings 
    ;;
  aws-profiles)
    cat ~/.aws/credentials
    ;;
  upgrade-all)
    sudo npm cache clean -f
    sudo npm install -g n
    sudo n stable
    serverless --version
    sudo npm install -g serverless
    ;;
  npm-upgrade)
    npm install -g npm@latest
  ;;
  npm-install)
    sudo rm -rf /Library/Developer/CommandLineTools
    brew install npm
    ;;
  mac-os-tools)
    sudo rm -rf /Library/Developer/CommandLineTools
    sudo xcode-select --install
    ;;
  test)
    echo "test"
    ;;
  *)
    echo "Help:"
    echo "  serverless-deploy"
    echo "  serverless-config"
    echo "  aws-get-function-config"
    echo "  aws-lambda-add-permissions"
    echo "  aws-profiles"
  ;;
esac


