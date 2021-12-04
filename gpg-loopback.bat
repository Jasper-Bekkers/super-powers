@echo off
rem git config --global gpg.program "C:/Scripts/gpg-loopback.bat"
"C:\Program Files\Git\usr\bin\gpg" --pinentry-mode loopback %*
