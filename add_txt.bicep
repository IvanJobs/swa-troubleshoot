param webAppName string
param dnsZoneName string

resource dnsZone 'Microsoft.Network/dnszones@2018-05-01' existing =  {
  name: dnsZoneName
}

resource txtRecord 'Microsoft.Network/dnsZones/TXT@2018-05-01' = {
  parent: dnsZone
  name: '@'
  properties: {
    TTL: 3600
    TXTRecords: [
      {
        value: [swaCustomDomain.properties.validationToken]
      }
    ]
  }
  dependsOn:[
    swaCustomDomain
  ]
}

resource staticWebApp 'Microsoft.Web/staticSites@2022-03-01' existing = {
  name: webAppName
}

resource swaCustomDomain 'Microsoft.Web/staticSites/customDomains@2022-03-01' existing = {
  name: dnsZoneName
  parent: staticWebApp
}
