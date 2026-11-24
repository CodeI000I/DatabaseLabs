#!/bin/bash

docker kill sql-lab
docker rm sql-lab

docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=<iu9_student>" -p 1433:1433 --name sql-lab -d mcr.microsoft.com/mssql/server:2022-latest

sleep 10

cat general.sql | docker exec -i sql-lab /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "<iu9_student>" -C