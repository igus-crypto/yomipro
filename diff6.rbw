# encoding: utf-8
# diff6
# 変更箇所を末尾にコピー

Encoding.default_external = 'UTF-8'

require 'inifile'
require 'diff/lcs'
require 'win32ole'
require 'clipboard'

require_relative 'clipboard_compat'
ini=IniFile.load(__dir__+"/config.ini")
hide=ini["path"]["hide"]
cbd=ClipBoard.new(__ENCODING__)

file_1=File.expand_path(ini["grep"]["file_1"])
if FileTest.file?(file_1)
  filename=file_1
else
  file_2=File.expand_path(ini["grep"]["file_2"])
  if FileTest.file?(file_2)
    filename=File.expand_path(file_2)
    Dir.chdir(File.dirname(file_2))
  else
    wsh = WIN32OLE.new('WScript.Shell')
    a=wsh.Popup("次のファイルがありません\n\n"+
      "#{file_1}\n#{file_2}",0,"注意",0)
    exit
  end
end


$stdout=File.open("tmp99d.txt","w")
$stderr=File.open("tmp_err_d.txt","w")

opt=ARGV[0]
#c:変更箇所を末尾にコピー
#a:変更箇所の頭に「!」

i=1
while FileTest.file?(ofile="tmp_"+sprintf("%#02d",i)+".txt")
  i+=1
end

#FileUtils.cp filename,ofile

ofile=File.expand_path(ofile)
p ofile
ofl=open(ofile,"w")

# 差分の取得(BOM除去)
bf=open(ARGV[1].encode(Encoding::UTF_8)).read.
  gsub(/\xEF\xBB\xBF|\xEF\xBF\xBE/,"").split(/\R/)
af=cbd.getText.
  gsub(/\xEF\xBB\xBF|\xEF\xBF\xBE/,"").split(/\R/)
#p bf=ARGV[0].encode(Encoding::UTF_8)
#bf=open(bf).readlines.map{|e| e.chomp}
#af=cbd.getText.split("\r\n").map{|e| e.chomp}

tf=File.basename(filename) #ターゲットファイル
#op=(/s/=~File.basename(ARGV[0]) ? "s" : "n")

#puts op

arr,ar1=[],[]
diffs=Diff::LCS.diff(bf,af)

#p diffs.methods
diffs.each{|hunk| hunk.each{|diff|
  arr << diff.position if diff.adding? && /^[ 　]*$/!~diff.element
  #print "diff.element=";p diff.element if diff.adding?
  ar1 << diff.element if diff.adding? && /^[ 　]*$/!~diff.element
  }}
puts "arr=";p arr
puts "ar1=";p ar1
#ar1=ar1.grep(/,/)
#puts "ar1=";p ar1

macro=open("tmp.mac","w:utf-8")
macro.print("\uFEFF")
if /c/=~opt
macro.puts %|disabledraw;begingroupundo;\n|
arr.each{|e|
  macro.puts %|movetolineno 1, #{e+1};beginsel;golineend2;delete;|}
macro.puts %|gofileend;insert "\\n";|
ar1.each{|e|
  macro.puts %|insert "#{e}\\n";|}
macro.puts %|
endgroupundo;enabledraw;endmacro;
|
else
macro.puts %|
disabledraw;begingroupundo;
|
arr.each{|e|
  macro.puts %|movetolineno 1, #{e+1};insert "!";|}
macro.puts %|
endgroupundo;enabledraw;endmacro;
|
end

__END__

変更箇所の頭に「!」追加
