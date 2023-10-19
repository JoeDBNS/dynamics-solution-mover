# How To Run
Powershell.exe -ExecutionPolicy Bypass `
               -File ".\MoveDynamicsSolution.ps1"

&nbsp;

## Error: AADSTS50173
"The provided grant has expired due to it being revoked, a fresh auth token is needed. The user might have changed or reset their password. ..."

Run "`pac auth create`" which whill generate a new token and replace the expired token.
