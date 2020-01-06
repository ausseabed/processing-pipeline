
[![CircleCI](https://circleci.com/gh/GeoscienceAustralia/ausseabed-processing-pipeline.svg?style=svg&circle-token=46ef01ebd72b56ec05a514c067d23655292ac5d8)](https://circleci.com/gh/GeoscienceAustralia/ausseabed-processing-pipeline)



### [WIP] This repo contains both the infrastructure as code for ausseabed processing pipeline.

1. upload to <S3bucket>/<survey-name> is completed. i.e a .done file is found in <S3bucket>/<survey-name>
2. The above triggers the aws step function.
 
______________________________________________________________________________________________________________

#### Infarstructure as code
Terrafrom v0.12.17 is used as the IaaC tool.
* terraform plan
* terraform apply

______________________________________________________________________________________________________________

#### [User Ineraction diagram](./docs/ausseabed_processing_pipeline_component_diagram-user_interaction.png)
![](./docs/ausseabed_processing_pipeline_component_diagram-user_interaction.png?raw=true)


______________________________________________________________________________________________________________

#### [Component diagram](./docs/ausseabed_processing_pipeline_component_diagram-Components.jpg)
![](./docs/ausseabed_processing_pipeline_component_diagram-Components.jpg?raw=true)

______________________________________________________________________________________________________________

#### [Developers guide](./docs/dev_guide.md)

______________________________________________________________________________________________________________
#### [Users guide](./docs/user_guide.md)
