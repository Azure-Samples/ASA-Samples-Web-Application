param asaInstanceName string
param asaManagedEnvironmentName string
param appName string
param location string = resourceGroup().location
param tags object = {}
param relativePath string
param databaseUsername string
@secure()
param databasePassword string
param datasourceUrl string

resource asaManagedEnvironment 'Microsoft.App/managedEnvironments@2022-11-01-preview' = {
  name: asaManagedEnvironmentName
  location: location
  tags: tags
  properties: {
    workloadProfiles: [
	  {
		name: 'Consumption'
		workloadProfileType: 'Consumption'
	  }
	]
  }

}

resource asaInstance 'Microsoft.AppPlatform/Spring@2023-03-01-preview' = {
  name: asaInstanceName
  location: location
  tags: union(tags, { 'azd-service-name': appName })
  sku: {
    name: 'S0'
	tier: 'StandardGen2'
  }
  properties: {
	managedEnvironmentId: asaManagedEnvironment.id
  }
}

resource asaApp 'Microsoft.AppPlatform/Spring/apps@2023-03-01-preview' = {
  name: appName
  location: location
  parent: asaInstance
  properties: {
    public: true
    activeDeploymentName: 'default'
  }
}

resource asaDeployment 'Microsoft.AppPlatform/Spring/apps/deployments@2023-03-01-preview' = {
  name: 'default'
  parent: asaApp
  properties: {
    deploymentSettings: {
      resourceRequests: {
        cpu: '1'
        memory: '2Gi'
      }
      environmentVariables: {
        SPRING_DATASOURCE_URL: datasourceUrl
		SPRING_DATASOURCE_USERNAME: databaseUsername
		SPRING_DATASOURCE_PASSWORD: databasePassword
	  }
    }
    source: {
      type: 'Jar'
      runtimeVersion: 'Java_17'
      relativePath: relativePath
    }
  }
}

output name string = asaApp.name
output uri string = 'https://${asaApp.properties.url}'
