@echo OFF
setlocal enabledelayedexpansion

for %%i in (%*) do (
	echo %%i >> %1 
)