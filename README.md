# Delimit-Json
Powershell function that splits text consisting of concatenated JSON objects into separate JSON chunks. This is useful for processing JSON structured logging.

For example, the following script will act as tail-like monitoring for a json structured log file, showing new objects as soon as they are appended and complete.

```PowerShell
Get-Content -Wait "jsonstructuredlog.txt" | Delimit-Json | %{ "New structured log object: $($_ | ConvertFrom-Json)" }
```
