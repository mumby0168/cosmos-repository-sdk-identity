param baseName string = resourceGroup().name
param location string = resourceGroup().location
param dbId string = 'managed-id-db'
param pk string = '/partitionKey'

resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2021-03-15' = {
  name: '${baseName}-cosmos'
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    locations: [
      {
        locationName: location
        failoverPriority: 0
      }
    ]
    databaseAccountOfferType: 'Standard'
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
  }
}

resource db 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-06-15' = {
  name: '${cosmos.name}/${dbId}'
  properties: {
    resource: {
      id: dbId
    }
  }
}

resource booksContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-06-15' = {
  parent: db
  name: 'books'
  properties: {
    resource: {
      id: 'books'
      partitionKey: {
        paths: [
          pk
        ]
        kind: 'Hash'
      }
    }
  }
}

output accountId string = cosmos.id
output accountName string = cosmos.name
output databaseId string = dbId
output cosmosDns string = cosmos.properties.documentEndpoint
