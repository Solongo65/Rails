#!/bin/bash

# BRANCH_NAME is a default variable set by Jenkins
#    on Jenkins agents it's equal to the branch that's being built

export AWS_DEFAULT_REGION=us-east-1

# define current stage based on branch name
if [[ $BRANCH_NAME == rails-dev ]]
then
    current_stage=dev
elif [[ $BRANCH_NAME == rails-prod ]]
then
    current_stage=prod
fi

# this will happen only in dev and staging stages
#   to prevent build/push happening in prod stage
if [[ $current_stage == dev ]]
then
    pushd App/
    make build stage=$current_stage
    make push stage=$current_stage
    popd
fi

# this will happen regardless of the stage
pushd App/
make deploy stage=$current_stage
popd