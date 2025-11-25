#!/bin/bash

echo "Waiting for SQL Server to start..."
sleep 30

echo "Creating database EasyPC_RS2..."
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "YourStrong@Passw0rd" -C -Q "IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'EasyPC_RS2') CREATE DATABASE EasyPC_RS2"

echo "Database created successfully!"
