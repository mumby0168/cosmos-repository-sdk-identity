param location string = resourceGroup().location
param acrPullRoleId string = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: toLower('cosmossdkidentitydemoacr')
  location: location
  sku: {
    name: 'Basic'
  }
}

resource booksApiMid 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' = {
  name: 'books-api-mid'
  location: location
}

var booksApiAcrPull = {
  name: guid(booksApiMid.id, resourceGroup().id, acrPullRoleId)
  roleDefinitionId: acrPullRoleId
}

resource booksApiAcrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: booksApiAcrPull.name
  scope: acr
  properties: {
    principalId: booksApiMid.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', booksApiAcrPull.roleDefinitionId)
  }
}


module acaEnv 'modules/aca_env.bicep' = {
  name: 'env'
  params: {
    location: location
  }
}

module cosmos 'modules/cosmos.bicep' = {
  name: 'cosmos'
  params: {
    location: location
    appPrincipalId: booksApiMid.properties.principalId
  }
}

module api 'modules/api.bicep' = {
  name: 'api'
  params: {
    image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
    name: 'books-api'
    location: location
    containerAppEnvironmentId: acaEnv.outputs.id
    registry: acr.name
    midName: booksApiMid.name
    midResourceId: booksApiMid.id
    envVars: [
      {
        name: 'ASPNETCORE_ENVIRONMENT'
        value: 'Development'
      }
      {
        name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        value: acaEnv.outputs.aiInstrumentationKey
      }
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: acaEnv.outputs.aiConnectionString
      }
      {
        name: 'RepositoryOptions__AccountEndpoint'
        value: cosmos.outputs.cosmosDns
      }
      {
        name: 'RepositoryOptions__DatabaseId'
        value: 'managed-id-db'
      }
      {
        name: 'RepositoryOptions__IsAutoResourceCreationIfNotExistsEnabled'
        value: 'False'
      }
      {
        name: 'AZURE_CLIENT_ID'
        value: booksApiMid.properties.clientId
      }
    ]
  }
}

output acrLoginServer string = acr.properties.loginServer
