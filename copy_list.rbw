# encoding: utf-8
# copy_list

Encoding.default_external = 'UTF-8'

require 'inifile'
require 'fileutils'

ini=IniFile.load(__dir__+"/config.ini")
repl=ini["path"]["repl"]

$stderr=open("tmp_err.txt","w")
$stdout=open("tmp99.txt","w")

p repl;p repl.gsub("/","\\");p __dir__+"/置換リスト/置換リスト*.txt"
Dir.glob(__dir__+"/置換リスト/置換リスト*.txt"){|e|
  f=File.basename(e);n=f.gsub(/置換リスト(\d+).*/){$1};
  FileUtils.cp(e,repl+"replace"+n+".txt")}
spawn(%Q|explorer.exe "#{repl.gsub("/","\\")}"|)

__END__

アップ用の置換リストを準備
