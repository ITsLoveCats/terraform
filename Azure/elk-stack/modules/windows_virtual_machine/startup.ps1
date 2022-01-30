Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
c:\ProgramData\chocolatey\bin\choco.exe install notepadplusplus -y
c:\ProgramData\chocolatey\bin\choco.exe install filebeat -y

invoke-webrequest https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.16.3-windows-x86_64.zip -outfile c:\filebeat.zip


#group=$(az group list | jq '.[0].name' --raw-output)

# az vm list | jq '.[].name' -r  
# az vm run-command invoke --command-id RunPowerShellScript --name AzureVM1 -g $group --scripts @startup.ps1
