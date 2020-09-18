#!/bin/bash

REGION=ap-southeast-2
SOURCE_ACCOUNT=288871573946 # Non Prod
TARGET_ACCOUNT=007391679308 # Data
SOURCE_IMAGE="ausseabed-gdal"
TARGET_IMAGE="ausseabed-gdal"
VERSION=latest

SOURCE_ACC_URL="$SOURCE_ACCOUNT.dkr.ecr.$REGION.amazonaws.com"
TARGET_ACC_URL="$TARGET_ACCOUNT.dkr.ecr.$REGION.amazonaws.com"

aws ecr get-login-password --profile=vscode --region $REGION | docker login --username AWS --password-stdin "$SOURCE_ACC_URL"
docker pull "$SOURCE_ACC_URL/$SOURCE_IMAGE:$VERSION"
docker tag "$SOURCE_ACC_URL/$SOURCE_IMAGE:$VERSION" "$TARGET_ACC_URL/$TARGET_IMAGE:$VERSION"
aws ecr get-login-password --profile=data --region $REGION | docker login --username AWS --password-stdin "$TARGET_ACC_URL"
docker push "$TARGET_ACC_URL/$TARGET_IMAGE:$VERSION"
