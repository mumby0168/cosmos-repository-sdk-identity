param name string
param location string = resourceGroup().location
param containerAppEnvironmentId string
param envVars array = []
param targetIngressPort int = 80
param registry string
param registryUsername string
param minReplicas int = 1
param maxReplicas int = 1
@secure()
param registryPassword string
param midName string
param image string

resource containerApp 'Microsoft.App/containerApps@2022-03-01' ={
  name: name
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${midName}': {}
    }  
  }
  properties:{
    managedEnvironmentId: containerAppEnvironmentId
    configuration: {
      activeRevisionsMode: 'single'
      secrets: [
        {
          name: 'container-registry-password'
          value: registryPassword
        }
      ]      
      registries: [
        {
          server: registry
          username: registryUsername
          passwordSecretRef: 'container-registry-password'
        }
      ]
      ingress: {
        external: true
        targetPort: targetIngressPort
      }
    }
    template: {
      containers: [
        {
          image: image
          name: name
          env: envVars
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: maxReplicas
      }
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
