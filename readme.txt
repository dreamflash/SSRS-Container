build container:
docker build -t ssrs2017cnt .

delploy container:
docker run -d --memory 4096mb --name ssrs2017cnt -p 1433:1433 -p 80:80 -v C:/temp/:C:/temp/ -e sa_password=password1! -e ACCEPT_EULA=Y -e ssrs_user=ssrsadmin -e ssrs_password=ssrspassword1! ssrs2017cnt