# How To Run
Powershell.exe -ExecutionPolicy Bypass `
               -File ".\MoveDynamicsSolution.ps1"

&nbsp;

## Error: AADSTS50173
"The provided grant has expired due to it being revoked, a fresh auth token is needed. The user might have changed or reset their password. ..."

Clear your expired authentication profiles and then run "`pac auth create`" which whill generate a new token and replace the expired token.

ex) `pac auth create --name 'test-app-dev' --environment 'https://test-app-dev.crm9.dynamics.com/'`
