# Terraform Up & Running - Modules.

This project contains the exercises proposed in Terraform Up & Running book (O'Reilly - Brikman).

## Prerequisites

The programs aws-cli & terraform should be installed in your machine prior to run it.

## Getting started

Go to any of the environment's folders [stage](stage) or [prod](prod) and then each one of the services inside and run the standard terraform commands inside:

```hcl-terraform
terraform init
``` 
```hcl-terraform
terraform plan
``` 
```hcl-terraform
terraform apply
``` 

## TODOs

- It seems like the cluster returns the same website whether in prod or in stage. The data should be different in each environment, so investigate and fix it.
- Nuke everything with aws-nuke