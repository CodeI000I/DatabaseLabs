#!/bin/bash
cat general.sql | docker exec -i sql-lab /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "<iu9_student>" -C