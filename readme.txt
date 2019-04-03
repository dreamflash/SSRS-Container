build container:
docker build -t ssrs2017cnt .

delploy container:
docker run -d --memory 1024mb --name ssrs2017cnt -p 80:80 -e db_instance='ssrs.db.com' -e db_username='sa' -e db_password='password1!' -e ssrs_user='ssrsadmin' -e ssrs_password='ssrspassword1!' ssrs2017cnt

ex:
1. Deploy MSFT official SQL container
   docker run -d --memory 2048mb --name mssql2017cnt -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=password1!' -p 1433:1433 mcr.microsoft.com/mssql/server:2017-latest
   
2. Deploy SSRS container
   docker run -d --memory 1024mb --name ssrs2017cnt -p 80:80 -e db_instance='192.168.10.153' -e db_username='sa' -e db_password='password1!' -e ssrs_user='ssrsadmin' -e ssrs_password='ssrspassword1!' ssrs2017cnt


