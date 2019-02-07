#!/bin/bash
# audit aws IAM users for MFA status
# USAGE:  bash auditAndEnableMFAForAWSIAM.sh
# Requirements: 
#   install aws cli tools
#       the credentials used need to have privs to audit all of the accounts
############################################################
## audit all IAM users for MFA status
#Run list-users command (OSX/Linux/UNIX) to list all IAM users within your account:
IAMUsers=(`aws iam list-users --query 'Users[*].UserName' --output text`)
#The command output should return an array that contains all your IAM user names:
    # [
    #     "John",
    #     "David",
    #     ...
    #     "Mark"
    # ]
#Run get-login-profile command (OSX/Linux/UNIX) to check if AWS Console access is enabled for the selected IAM user:
for i in "${IAMUsers[@]}"
do
    #aws iam get-login-profile --user-name $i
    #The command output should return an object that contains the Login Profile for the selected IAM user:
        # {
        #   "LoginProfile": {
        #       "UserName": "John",
        #       "CreateDate": "2018-09-27T01:11:06Z",
        #   "   PasswordResetRequired": true
        #     }
        # }
    #If a LoginProfile object exists, then you should check if MFA is enabled below.
    #Run list-mfa-devices command (OSX/Linux/UNIX) to list the MFA devices (if any) for the selected IAM user:
    MFAStatus=(`aws iam list-mfa-devices --user-name $i --output text`)
    #The command output should return an array that contains all the MFA devices assigned to the specified IAM user:
        # {
        #     "MFADevices": []
        # }
    #If the MFADevices array returned for you is empty, i.e. [ ], the selected IAM user authentication process is not MFA-protected.
    if [ -z "$MFAStatus" ]
    then
        echo "$i does not have MFA enabled"
        #enable MFA
    #else
        #if MFA status is enabled, don't touch
        #echo "$i has MFA status enabled, don't touch" 
    fi
done