rem aozora05【ファイル転送】.bat
chcp 65001
cd /d %~dp0

adb push %1 /sdcard/Download/%~n1.txt
adb push %2 /sdcard/Download/%~n2.txt
adb push %3 /sdcard/Download/%~n3.txt
adb push %4 /sdcard/Download/%~n4.txt
adb push %5 /sdcard/Download/%~n5.txt
adb push %6 /sdcard/Download/%~n6.txt
adb push %7 /sdcard/Download/%~n7.txt
adb push %8 /sdcard/Download/%~n8.txt
adb push %9 /sdcard/Download/%~n9.txt
