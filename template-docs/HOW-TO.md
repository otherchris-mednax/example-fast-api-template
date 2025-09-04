# How to Use the fast-api-template

> **IMPORTANT:** Please make sure to follow initial project steps found within the [main branch's README](https://github.com/mednax-it/nimbus-build-template/blob/main/README.md).

1. Cut a feature branch from the main branch for your Jira story and make the following changes:
    * Replace all instances of `fast-api-template` with your new project name.
    * Rename the `src/fast_api_template` folder at the root of the project
        * Replace all instances of `fast_api_template` with your new folder name
    * Add a new SonarCloud project for the repo.
    * Add project description to your README file.
    * Update CircleCI config (`.circleci/config.yml`):
        * Pediatrix orb (line 3) to the latest orb published in [CircleCI](https://app.circleci.com/settings/organization/github/mednax-it/orbs).
        * Remove `use_sonarcloud: false` from build_parameters (line 9)
        * Rollout resource name if different than project name or multiple resources (line 10).
        * **NOTE** the project name should have been updated in a previous step.
    * Setup your project in CircleCi and point to existing `.circleci/config.yml` in your feature branch.
    * Add [sdbi-aks-apps](https://github.com/mednax-it/sdbi-aks-apps) Kubernetes templates for ArgoCD. Refer to [How to Create ArgoCD Deployment steps](#how-to-create-argocd-deployment) below.
    * Push your changes.
        * **NOTE** The build will fail within CircleCI if the SonarCloud project is not created.

After you have done the steps above and verified your CircleCI build has run successfully, you should be good to modify the template to fit your project needs.

> **IMPORTANT:** Don't forget to delete the `template-docs` folder once your project is set up.

## How to Create ArgoCD Deployment

In order to deploy with Argo CD, updates must be made to the [sdbi-aks-apps](https://github.com/mednax-it/sdbi-aks-apps) repo.  The document [Using ArgoCD to Deploy Applications to AKS](https://mednax1500.atlassian.net/wiki/spaces/SDBI/pages/2033123496/Using+ArgoCD+to+Deploy+Applications+to+AKS) gives detailed instructions for this process.

**For convenience only**, the following files are provided to update and move to the [sdbi-aks-apps](https://github.com/mednax-it/sdbi-aks-apps) repo, and **should be deleted** once your project is set up:
- sdbi-aks-templates
    - applicationsets
        - fast-api-template.yaml -> rename to [project name].yaml
    - fast-api-template -> rename to [project name]
        - templates
            - fast-api-template-analysis.yaml -> rename to [project name]-analysis.yaml
            - fast-api-template-rollout.yaml -> rename to [project name]-rollout.yaml
            - fast-api-template-ingress.yaml -> rename to [project name]-ingress.yaml
            - fast-api-template-service.yaml -> rename to [project name]-service.yaml
        - Chart.yaml
        - values.yaml

1. Rename template files to match project name.
    * `applicationsets/fast-api-template.yaml` -> rename to `applicationsets/[project name].yaml`
    * `fast-api-template` folder -> rename to `[project name]`
    * `[project name]/templates/fast-api-template-analysis.yaml` -> rename to `[project name]/templates/[project name]-analysis.yaml`
    * `[project name]/templates/fast-api-template-rollout.yaml` -> rename to `[project name]/templates/[project name]-rollout.yaml`
    * `[project name]/templates/fast-api-template-ingress.yaml` -> rename to `[project name]/templates/[project name]-ingress.yaml`
    * `[project name]/templates/fast-api-template-service.yaml` -> rename to `[project name]/templates/[project name]-service.yaml`
    * **NOTE** Step 3-1 of [How to Use the fast-api-template](#how-to-use-the-fast-api-template) would have updated `fast-api-template` to your new project name in all of these files.
1. Add non secret environment variables to the `[project name]/values.yaml` and `[project name]/templates/[project name]-rollout.yaml` as required.
1. Copy `applicationsets/[project name].yaml` file to the `applicationsets` folder in the [sdbi-aks-apps](https://github.com/mednax-it/sdbi-aks-apps) repo.
1. Copy the `[project name]` folder to a new folder in the [sdbi-aks-apps](https://github.com/mednax-it/sdbi-aks-apps) repo.
1. Rename `skaffold/fast-api-template.yaml` to `skaffold/[project name].yaml`
1. Update `skaffold` templates to match templates found in `[project name]/templates` folder.
    * Refer to README on how to generate the secret values for Skaffold.
1. Delete the `sdbi-aks-templates` folder and all its contents from this repo.
