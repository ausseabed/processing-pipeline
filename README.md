[![CircleCI](https://circleci.com/gh/ausseabed/processing-pipeline.svg?style=svg&circle-token=46ef01ebd72b56ec05a514c067d23655292ac5d8)]


This repo contains both the infrastructure and application code for ausseabed processing pipeline. There are two other supporting code repos
1.https://github.com/GeoscienceAustralia/ausseabed-caris-ami (used for creating an AWS AMI with Caris installed)
2.https://github.com/GeoscienceAustralia/ausseabed-caris-container (used for creating a socker image with Caris installed)


 
______________________________________________________________________________________________________________

#### Infarstructure as code
Terrafrom v0.12.17 is used as the IaaC tool.
Generally, the commands to create an infratucture setup with terraform is the following
* terraform init
* terraform plan
* terraform apply

However, refer to [circleci config](https://github.com/GeoscienceAustralia/ausseabed-processing-pipeline/blob/master/.circleci/config.yml) for exact steps.



______________________________________________________________________________________________________________

#### [User Ineraction diagram](./docs/ausseabed_processing_pipeline_component_diagram-user_interaction.png)
![](./docs/ausseabed_processing_pipeline_component_diagram-user_interaction.png?raw=true)


______________________________________________________________________________________________________________

#### [Component diagram](./docs/ausseabed_processing_pipeline_component_diagram-Components.jpg)
![](./docs/ausseabed_processing_pipeline_component_diagram-Components.jpg?raw=true)

______________________________________________________________________________________________________________

#### [Developers guide](./docs/dev_guide.md)
If you are starting as a developer in this project this document will be useful.
______________________________________________________________________________________________________________
#### [Users guide](./docs/user_guide.md)
If you are a hydorgrapher or a someone processing surveys this guide will be useful
