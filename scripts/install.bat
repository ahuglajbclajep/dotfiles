@echo off
cd /d %~dp0
powershell -ExecutionPolicy RemoteSigned .\install.ps1
