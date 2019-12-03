
[![CircleCI](https://circleci.com/gh/GeoscienceAustralia/ausseabed-processing-pipeline.svg?style=svg&circle-token=46ef01ebd72b56ec05a514c067d23655292ac5d8)](https://circleci.com/gh/GeoscienceAustralia/ausseabed-processing-pipeline)



### [WIP] This repo contains both the infrastructure as code for ausseabed processing pipeline.

1. upload to <S3bucket>/<survey-name> is completed. i.e a .done file is found in <S3bucket>/<survey-name>
2. The above triggers the aws step function.

#### [User Ineraction diagram](./docs/ausseabed_processing_pipeline_component_diagram-user_interaction.png)
![](./docs/ausseabed_processing_pipeline_component_diagram-user_interaction.png?raw=true)


#### [Component diagram](./docs/ausseabed_processing_pipeline_component_diagram-Components.jpg)
![](./docs/ausseabed_processing_pipeline_component_diagram-Components.jpg?raw=true)

