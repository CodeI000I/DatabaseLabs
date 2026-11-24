#!/bin/bash

docker kill sql-lab
docker rm sql-lab

docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=<iu9_student>" -p 1433:1433 --name sql-lab -d mcr.microsoft.com/mssql/server:2022-latest