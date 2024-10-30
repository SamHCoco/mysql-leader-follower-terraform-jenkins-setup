# Jenkins MySQL Setup & Replication Pipeline - Terraform + Ansible for AWS

## Summary

Jenkins pipeline to deploy AWS EC2 instances using Terraform and configure Leader-Follower database replication for MySQL with Ansible.

## Versions

- **Java:** openjdk17
- **Jenkins:** 2.482
- **Ansible:** 2.14.16
- **Terraform:** v1.9.8

## Required Jenkins Plugins

To ensure proper functionality of the pipeline, the following Jenkins plugins are required:

- Terraform Plugin
- Ansible Plugin
- AWS Credentials Plugin
