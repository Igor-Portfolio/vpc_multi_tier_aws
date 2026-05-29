# General view


The main idea of this project is to apply the 3-tier architecture on AWS.

The goal is to create a VPC with three layers:

* **Public Layer**: responsible for the frontend
* **Private Layer**: responsible for the application/backend, accessible only from the frontend layer
* **Database Layer**: responsible for secure and isolated data storage

This architecture improves security, scalability, and separation of concerns between each component of the system.


The application itself is intentionally simple.
The frontend was built using basic HTML, and the backend was developed with Flask and Python.

The main focus of this project is not frontend or application development, but rather:

The use of Docker for containerization
The design of a coherent cloud infrastructure
The implementation of a secure and organized architecture on AWS

The use of Docker will be properly documented throughout the project.

Infrastructure provisioning will be performed using Terraform, and all relevant architectural and technical decisions will be properly documented during the development process.