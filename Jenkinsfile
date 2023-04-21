@Library("podTemplates") _
pipeline {
  parameters { booleanParam(name: 'FORCE_PUSH', defaultValue: false, description: 'Will force the publishing of the packages to the registry & repository') }
  environment {
    NAME = 'kickstart'
    REPOSITORY = 'git@github.com:nvanlaerebeke/container-kickstart.git'
    REPOSITORY_CREDENTIAL_ID = 'adfe5c5e-1b1c-4ecb-9b00-e08fe30f9c8b'
    REGISTRY = "harbor.crazyzone.be/crazyzone"
    REGISTRY_HELM = "harbor.crazyzone.be/crazyzone-helm"
    REGISTRY_SECRET_FILE = credentials('b60285fd-4580-4cba-8633-4c802ab2360c')
    REGISTRY_SECRET_FILE_HELM = credentials('8fec678f-91a4-4047-ab17-3c83d3651cba') 
  } 
  agent {
    kubernetes {
      yaml getPodTemplate("buildkit_with_helm")
    }
  }
  stages {
    stage('build') {
      when { anyOf {
        branch "master";
        branch "main"
        branch "stable";
        branch "dev";
        expression{params.FORCE_PUSH == true }
      } }
      steps {
        container(name: "buildkit", shell: '/bin/sh') {
          checkoutAndBuild(env.REPOSITORY, env.REPOSITORY_CREDENTIAL_ID, env.NAME, env.REGISTRY, env.BRANCH_NAME, env.REGISTRY_SECRET_FILE)
        }
        container(name: "helm", shell: '/bin/sh') {
          sh getHelmBuildScript(env.NAME, env.REGISTRY_HELM, REGISTRY_SECRET_FILE_HELM)
        }
      }
    }
  }
}