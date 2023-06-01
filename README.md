# swa-troubleshoot

This is a quick workaround script for demostrating how to use bicep to provision an Azure Static Web app with a custom domain.

It seems there's a cycle dependency if we try to do it in a single bicep file.

That is: 
1. Txt Record -> SWA : Txt Record waits for the validation token from SWA (custom domain).
2. SWA -> Txt Record : SWA waits for a Txt Record with the correct validation token for domain ownership validation.

Suppose you got a App Serivce Domain created, then you can run the following script to provision a swa with custom domain:
```
bash main.sh {SWA_NAME} {DOMAIN_NAME}
```
