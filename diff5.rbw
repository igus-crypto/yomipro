# encoding: utf-8
# diff5
# grepの本文を集めて加工（修正箇所のみ）

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

i=1
while FileTest.file?(ofile="tmp_"+sprintf("%#02d",i)+".txt")
  i+=1
end

#FileUtils.cp filename,ofile

ofile=File.expand_path(ofile)
p ofile
ofl=open(ofile,"w")

p bf=ARGV[0].encode(Encoding::UTF_8)
# 差分の取得(BOM除去)
bf=open(ARGV[0].encode(Encoding::UTF_8)).read.
  gsub(/\xEF\xBB\xBF|\xEF\xBF\xBE/,"").split(/\R/)
af=cbd.getText.
  gsub(/\xEF\xBB\xBF|\xEF\xBF\xBE/,"").split(/\R/)
#bf=open(bf).readlines.map{|e| e.chomp}
#af=cbd.getText.split("\r\n").map{|e| e.chomp}

tf=File.basename(filename) #ターゲットファイル
#op=(/s/=~File.basename(ARGV[0]) ? "s" : "n")

#puts op

ar1,ar2,arr,hs=[],[],[],{}
diffs=Diff::LCS.diff(bf,af)

#p diffs.methods
#print "diffs=";p diffs
diffs.each{|hunk| hunk.each{|diff|
  ar1 << diff.element if diff.deleting?
  ar2 << diff.element if diff.adding?}}

ar1=ar1.grep( /(.*?:[^:]*:)/).map{|e| e.gsub(/^\s+/,"")}
ar2=ar2.grep( /(.*?:[^:]*:)/).map{|e| e.gsub(/^\s+/,"")}
puts "ar1=";p ar1
puts "ar2=";p ar2
#puts ar1[0]

st=ar2.join("\r\n")
print "st=";p st
cbd.setText(st)
__END__

grepの本文を集めて加工（修正箇所のみ）
