#!/bin/bash
#############################################################
# Using Jenkins ssh interface instead of earlier CLI interface,
# due to an open bug of Jenkins: 
# https://issues.jenkins-ci.org/browse/JENKINS-12629
#
# This script needs some pre-defined environment variables:
# 1. JENKINS_SSHD: Jenkins sshd server name, this is managed
#       by "Shared Objects" plugin.
# 2. NEW_JOB: name of the new job.
#
#############################################################

#JENKINS_SSHD=jenkins.company.com
JENKINS_SSHD_PORT=33222

## First part of Jenkins cli command line being used repeatedly
SSH_CMD="ssh -p $JENKINS_SSHD_PORT bot@$JENKINS_SSHD"

SRC_JOB=Feature_Branch_Builder_Template

# Get the new job name directly from environment variable JIRA_ID
# NEW_JOB=$JIRA_ID

## some info
$SSH_CMD who-am-i

## clone a new job from a template job named SRC_JOB
## copy-job will also copy all promotion configurations, yay!
$SSH_CMD copy-job $SRC_JOB $NEW_JOB

## get the config.xml of the new job
$SSH_CMD get-job $NEW_JOB > config.xml

## manipulate the config.xml, replace the placeholder
## 'XXX-XXX-XXX' to $NEW_JOB 
sed -i -e s/XXX-XXX-XXX/$NEW_JOB/g config.xml

## update the new job to apply the changes
## promotion configurations stay unchanged
$SSH_CMD update-job $NEW_JOB < config.xml

## the template job might be disabled by default, now enable the new job
$SSH_CMD enable-job $NEW_JOB

## build the new job immediately
$SSH_CMD build $NEW_JOB

