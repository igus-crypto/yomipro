rem aozora01【連続処理前半】.bat
chcp 65001
cd /d %~dp0

call 青空01【UTF作成】.bat
call 青空02【注釈除去】.bat
call 青空03【直接置換】.bat
call 青空04【ルビ除去１】.bat

:end
