rem aozora04【ログ削除】.bat
chcp 65001
cd /d %~dp0
call ruby -x "%~f0"
goto end

#/
#!ruby

Dir.glob('**/*_u?.txt'){|f| File.delete(f)}
Dir.glob('**/*_u.txt'){|f| File.delete(f)}
Dir.glob('**/*.log'){|f| File.delete(f)}
Dir.glob('**/tmp*'){|f| File.delete(f)}
Dir.glob('log/*'){|f| File.delete(f)}
__END__
:end
