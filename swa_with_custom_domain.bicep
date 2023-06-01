var location = 'eastasia'
param webAppName string
param dnsZoneName string
var githubRepoUrl = 'https://github.com/IvanJobs/Twitter-Clone.git'
var repositoryToken = 'YOUR_GITHUB_PAT'

resource dnsZone 'Microsoft.Network/dnszones@2018-05-01' existing =  {
  name: dnsZoneName
}

resource aRecord 'Microsoft.Network/dnszones/A@2018-05-01' = {
  parent: dnsZone
  name: 'www'
  properties: {
    TTL: 3600
    targetResource: {
      id: resourceId('Microsoft.Web/staticSites', webAppName)
    }
  }
  dependsOn:[ staticWebApp ]
}

resource staticWebApp 'Microsoft.Web/staticSites@2022-03-01' = {
  name: webAppName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {
    repositoryUrl: githubRepoUrl
    buildProperties: {
      apiLocation: '/api'
      appLocation: '/'
    }
    repositoryToken: repositoryToken
    branch: 'main'
    provider: 'GitHub'
  }
}

resource swaCustomDomain 'Microsoft.Web/staticSites/customDomains@2022-03-01' = {
  name: dnsZoneName
  parent: staticWebApp
  properties: {
    validationMethod: 'dns-txt-token'
  }
}
