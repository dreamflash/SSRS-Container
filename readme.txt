build container:
docker build -t ssrs2017cnt .

delploy container:
1. docker run -d --memory 1024mb --name ssrs2017cnt -p 80:80 -e db_instance='ssrs.db.com' -e db_username='sa' -e db_password='password1!' -e ssrs_user='ssrsadmin' -e ssrs_password='ssrspassword1!' ssrs2017cnt

2. docker run -d --memory 1024mb --name ssrs2017cnt -p 80:80 -e db_instance='192.168.10.153' -e db_username='sa' -e db_password='password1!' -e ssrs_user='ssrsadmin' -e ssrs_password='ssrspassword1!' ssrs2017cnt


