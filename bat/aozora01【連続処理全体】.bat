rem aozora01【連続処理全体】.bat
chcp 65001
cd /d %~dp0
rem ~

call 青空01【UTF作成】.bat
call 青空02【注釈除去】.bat
call 青空03【直接置換】.bat
call 青空04【ルビ除去１】.bat
call 青空05【ルビ置換１】.bat
call 青空06【ルビ置換２】.bat
call 青空07【ルビ除去２】.bat
call 青空08【ルビ置換３】.bat

