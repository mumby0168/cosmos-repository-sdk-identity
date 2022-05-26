param location string = resourceGroup().location
param image string

resource booksApiMid 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' existing = {
  name: 'books-api-mid'
}

resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' existing = {
  name: toLower('cosmossdkidentitydemoacr')
}

resource acaEnv 'Microsoft.App/managedEnvironments@2022-01-01-preview' existing = {
  name: '${resourceGroup().name}env'
}

resource ai 'Microsoft.Insights/components@2020-02-02' existing = {
  name: '${resourceGroup().name}ai'
}

resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2021-03-15' existing = {
  name: '${resourceGroup().name}-cosmos'
}

resource kv 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: 'cosmosidentitydemokv'
}

module api 'modules/api.bicep' = {
  name: 'api'
  params: {
    image: image
    name: 'books-api'
    location: location
    containerAppEnvironmentId: acaEnv.id
    registry: acr.name
    registryUsername: acr.listCredentials().username
    registryPassword: kv.getSecret('acr_password')
    midName: booksApiMid.name
    envVars: [
      {
        name: 'ASPNETCORE_ENVIRONMENT'
        value: 'Development'
      }
      {
        name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        value: ai.properties.InstrumentationKey
      }
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: ai.properties.ConnectionString
      }
      {
        name: 'RepositoryOptions__AccountEndpoint'
        value: cosmos.properties.documentEndpoint
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
