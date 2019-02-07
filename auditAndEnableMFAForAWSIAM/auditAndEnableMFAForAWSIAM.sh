#!/bin/bash
# audit aws IAM users for MFA status and enable MFA for any IAM users without MFA enabled
# USAGE:  bash auditAndEnableMFAForAWSIAM.sh
# Requirements: 
#   install aws cli tools
#       the credentials used need to have privs to audit all of the accounts
# notes:
#   wondering why i didnt use functions? because passing arrays between functions has a ton of issues in bash.
#############################################################

## enable MFA for all IAM users
enableMFA () {
    echo "$1 was passed"
    #Run create-virtual- mfa-device command
    #(OSX/Linux/UNIX) to create a new virtual MFA device within your AWS account:
    #aws iam create-virtual-mfa-device --virtual-mfa-device-name $1MFADevice --outfile /root/QRCode.png --bootstrap-method QRCodePNG
    #The command output should return the new virtual MFA device Amazon Resource Name (ARN):
    # {
    #     "VirtualMFADevice": {
    #         "SerialNumber": "arn:aws:iam::123456789012:mfa/JohnsMFADevice"
    #     }
    # }
    #Run enable-mfa-device command (OSX/Linux/UNIX) to activate the specified MFA virtual device (in this case Google Authenticator) and associate it with the selected IAM user. The highlighted values represent two consecutive MFA device passcodes. The enable-mfa-device command is not returning an output:
    #aws iam enable-mfa-device --user-name $1 --serial-number arn:aws:iam::123456789012:mfa/$1MFADevice --authentication-code-1 256689 --authentication-code-2 432030
    #Finally, run list-mfa-devices command (OSX/Linux/UNIX) to determine if the new MFA device has been successfully installed for the selected IAM user:
    #aws iam list-mfa-devices --user-name $1
    #If successful, the command output should return the MFA device metadata (ARN, instantiation date, etc ):
    # {
    #     "MFADevices": [
    #         {
    #             "UserName": "John",
    #             "SerialNumber": "arn:aws:iam::123456789012:mfa/JohnsMFADevice",
    #             "EnableDate": "2016-05-20T18:51:54Z"
    #         }
    #     ]
    # }
}

auditMFA () {
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
            #echo "$i does not have MFA enabled"
            #enable MFA
            enableMFA $i
        #else
            #if MFA status is enabled, don't touch
            #echo "$i has MFA status enabled, don't touch" 
        fi
    done
}

#############################################################
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
#audit all IAM users for MFA status
auditMFA