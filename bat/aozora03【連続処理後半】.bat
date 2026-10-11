rem aozora03【連続処理後半】.bat
chcp 65001
cd /d %~dp0

call 青空05【ルビ置換１】.bat
call 青空06【ルビ置換２】.bat
call 青空07【ルビ除去２】.bat

:end
