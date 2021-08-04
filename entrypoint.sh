#!/bin/sh

set -e

mkdir -p ~/.aws
touch ~/.aws/credentials

echo "[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}" > ~/.aws/credentials

if [ "$ASSUME_ROLE_ARN" != "" ]; then
  TEMP_ROLE=`aws sts assume-role --role-arn $ASSUME_ROLE_ARN --role-session-name ci`
  export AWS_ACCESS_KEY_ID=$(echo "$TEMP_ROLE" | jq -r '.Credentials.AccessKeyId')
  export AWS_SECRET_ACCESS_KEY=$(echo "$TEMP_ROLE" | jq -r '.Credentials.SecretAccessKey')
  export AWS_SESSION_TOKEN=$(echo "$TEMP_ROLE" | jq -r '.Credentials.SessionToken')
  export AWS_REGION=${REGION}
fi

ecs-deploy --skip-deployments-check -c ${CLUSTER} -n ${SERVICE} -i ${REPO} -t 3000
