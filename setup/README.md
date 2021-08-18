# IGNORE THIS FOLDER

This folder is for setting up the technical test, if you are taking the test
you can ignore this folder.




## Overview

Make sure you are using AWS CLI v2 (v1 still compatible).

We'll run some CloudFormation to get some credentials and setup a user for use.

You will need a aws-vault set up for the `sf_sso` account and a `.aws/config` entry as follows:

```
[profile techtest.scalefactory.net]
region=eu-west-1
role_arn=arn:aws:iam::133002017424:role/ScaleFactoryUser
source_profile=sf_sso
role_session_name=jack
duration_seconds=3600
mfa_serial=arn:aws:iam::754021874844:mfa/jack
```

Then, in the setup folder run `make setup` e.g.

```shell
cd setup
make setup
```

## The Test/Rest

Please see instructions in the [GDrive](https://docs.google.com/document/d/1dDOY27fUS3kqemnksni7HU_YZNFdDUbJ9o_5st9cHLM/edit)


## After the test

If another candidate is going to use the system, you can reset the credentials
with `make reset_creds`.

You can clean up the test environment with `make nuke`
