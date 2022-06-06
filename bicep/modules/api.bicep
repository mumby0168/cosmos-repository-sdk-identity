param name string
param location string = resourceGroup().location
param containerAppEnvironmentId string
param envVars array = []
param targetIngressPort int = 80
param registry string
param minReplicas int = 1
param maxReplicas int = 1
param midName string
param image string

resource containerApp 'Microsoft.App/containerApps@2022-01-01-preview' ={
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
      registries: [
        {
          server: registry
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
