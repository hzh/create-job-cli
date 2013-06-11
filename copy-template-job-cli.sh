#!/bin/bash
#############################################################
#
# This script needs some pre-defined environment variables:
# 1. JENKINS_CLI_ACCESS_POINT: root url of the jenkins instance, 
#             at the moment, only http is supported.
#             This environment variable is injected as
#             a "shared object" in Jenkins.
# 2. JIRA_ID: Jira ticket ID, as the same time it is also
#             the new job name and Git branch name.
#
# Arguments:
# 1. SRC_JOB: [Optional] name of the template job to be copied 
#             from, default "Feature_Branch_Builder_Template"
# 
#############################################################

#JENKINS_CLI_ACCESS_POINT=http://jenkins.company.com:8080/jenkins

## Get the latest jenkins-cli.jar direct from the target Jenkins server
wget --no-check-certificate $JENKINS_CLI_ACCESS_POINT/jnlpJars/jenkins-cli.jar

#CLI_ARGS=-Djavax.net.ssl.trustStorePath=trusted_cacerts -Djavax.net.ssl.trustStorePassword=jenkins 
#CLI_CMD="java -jar jenkins-cli.jar -s $JENKINS_CLI_ACCESS_POINT -i /home/jenkins-slave/.ssh/id_rsa"
#CLI_CMD="/home/jenkins-slave/tools/jdk1.6/jdk1.6.0_26/bin/java -jar jenkins-cli.jar -s $JENKINS_CLI_ACCESS_POINT"

## First part of Jenkins cli command line being used repeatedly
CLI_CMD="java -jar jenkins-cli.jar -s $JENKINS_CLI_ACCESS_POINT"


    ## login by key authentification
    $CLI_CMD -i ~/.ssh/id_rsa login

    ## some info
    $CLI_CMD who-am-i

    ## clone a new job from a template job named SRC_JOB
    $CLI_CMD copy-job $SRC_JOB $NEW_JOB

    ## get the config.xml of the new job
    $CLI_CMD get-job $NEW_JOB > config.xml

    ## manipulate the config.xml, replace the dummy git branch name
    ## 'XXX-XXX-XXX' to $NEW_JOB (CONVENSION: identical with the job name)
    sed -i -e s/XXX-XXX-XXX/$NEW_JOB/g config.xml

    ## update the new job to apply the changes
    $CLI_CMD update-job $NEW_JOB < config.xml

    ## the template job might be disabled by default, now enable the new job
    $CLI_CMD enable-job $NEW_JOB

    ## build the feature branch job
    $CLI_CMD build $NEW_JOB

    ## logout from Jenkins
    $CLI_CMD logout
