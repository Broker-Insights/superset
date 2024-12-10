#!/bin/bash
set -e
# Requires buildx : sudo sudo apt install docker-buildx
docker buildx build -t superset_bi_base --target lean .

REGION=eu-west-2
AWS_ACCOUNT_ID=$(AWS_PROFILE=dev aws sts get-caller-identity --query Account --output text)
BRANCH=$(git rev-parse --abbrev-ref HEAD|sed 's#/#-#g' -)
COMMIT_HASH=$(git log -1 --pretty=format:%h)
COMMIT_TS=$(git show -s --format="%at" $COMMIT_HASH)
BUILD_TS=$(date '+%Y%m%d-%H-%M-%S')
TAG=${BRANCH}-${COMMIT_TS}-${COMMIT_HASH}-$BUILD_TS
docker build -t $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/bi-superset:$TAG -f Dockerfile.bi .

echo Built $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/bi-superset:$TAG
echo In order to release push to ECR
echo 'AWS_PROFILE=dev aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com'
echo docker push $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/bi-superset:$TAG
echo Then apply IaC changes to use as active image for task definition / later through Code Deploy
