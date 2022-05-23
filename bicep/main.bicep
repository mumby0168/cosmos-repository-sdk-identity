param location string = resourceGroup().location

resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: toLower('${uniqueString(resourceGroup().name)}acr')
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

resource booksApiMid 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' = {
  name: 'books-api-mid'
  location: location
}

module acaEnv 'aca_env.bicep' = {
  name: 'env'
  params: {
    location: location
  }
}

module api 'api.bicep' = {
  name: 'api'
  params: {
    name: 'books-api'
    location: location
    containerAppEnvironmentId: acaEnv.outputs.id
    registry: acr.name
    registryUsername: acr.listCredentials().username
    registryPassword: acr.listCredentials().passwords[0].value
    midName: booksApiMid.name
    envVars: [
      {
        name: 'ASPNETCORE_ENVIRONMENT'
        value: 'Development'
      }
      {
        name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        value: acaEnv.outputs.appInsightsInstrumentationKey
      }
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: acaEnv.outputs.appInsightsConnectionString
      }
      {
        name: 'RepositoryOptions__AccountEndpoint'
        value: cosmos.outputs.cosmosDns
      }
      {
        name: 'RepositoryOptions__DatabaseId'
        value: cosmos.outputs.databaseId
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


module cosmos 'cosmos.bicep' = {
  name: 'cosmos'
  params: {
    location: location
    appPrincipalId: booksApiMid.properties.principalId
  }
}

output acrLoginServer string = acr.properties.loginServer
