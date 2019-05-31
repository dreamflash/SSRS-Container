build container:
docker build -t ssrs2017cnt .

delploy container:
      docker run -d --memory 1024mb --name ssrs2017cnt -p 80:80 -e db_instance='ssrs.db.com' -e db_username='sa' -e db_password='password1!' -e ssrs_user='ssrsadmin' -e ssrs_password='ssrspassword1!' ssrs2017cnt

gMSA: docker run --security-opt "credentialspec=file://contoso_webapp01.json" --hostname webapp01  -d --memory 1024mb --name ssrs2017cnt -p 80:80 -e db_instance='ssrs.db.com' -e db_username='sa' -e db_password='password1!' -e ssrs_user='ssrsadmin' -e ssrs_password='ssrspassword1!' ssrs2017cnt

ex:
1. Deploy SSRS container
   docker run --security-opt "credentialspec=file://contoso_webapp01.json" --hostname webapp01 -d --memory 1024mb --name ssrs2017cnt -p 80:80 -e db_instance='192.168.11.5' -e db_username='sa' -e db_password='password1!' -e ssrs_user='ssrsadmin' -e ssrs_password='ssrspassword1!' ssrs2017cnt


