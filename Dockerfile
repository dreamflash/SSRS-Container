FROM mcr.microsoft.com/windows/servercore

LABEL  Name="SSRS Docker container"

ENV exe "https://download.microsoft.com/download/E/6/4/E6477A2A-9B58-40F7-8AD6-62BB8491EA78/SQLServerReportingServices.exe"

ENV db_instance="_" \
    db_username="_" \
    db_password="_" \
    sa_password_path="C:\ProgramData\Docker\secrets\sa-password" \
    ssrs_user="_" \
    ssrs_password="_" \
    SSRS_edition="EVAL" \
    ssrs_password_path="C:\ProgramData\Docker\secrets\ssrs-password"    

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# make install files accessible
COPY start.ps1 /
COPY configureSSRS2017.ps1 /
COPY newadmin.ps1 /
COPY ssrs_svc_account_setup.sql /
#COPY ssrs_svc_rsexec_role.sql /

WORKDIR /

RUN  Invoke-WebRequest -Uri $env:exe -OutFile ssrs2017.exe ; \
     Start-Process -Wait -FilePath .\ssrs2017.exe -ArgumentList "/quiet", "/norestart", "/IAcceptLicenseTerms", "/Edition=$env:SSRS_edition" -PassThru -Verbose ; \
     Install-PackageProvider nuget -Force -Confirm:$False ; \
     Remove-Item -Force ssrs2017.exe

RUN Install-Module -Name SqlServer -Force -Confirm:$False

CMD .\start -db_instance $env:db_instance -db_username $env:db_username -db_password $env:db_password -ssrs_user $env:ssrs_user -ssrs_password $env:ssrs_password -Verbose
