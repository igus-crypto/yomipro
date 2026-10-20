# encoding: utf-8
# ruby_scan
# ルビ抽出（選択文字）

Encoding.default_external = 'UTF-8'

require 'open3'
require 'inifile'
require 'win32ole'
require 'clipboard'

require_relative 'clipboard_compat'
$stderr=open("tmp_err.txt","w")
$stdout=open("tmp99.txt","w")

ini=IniFile.load(__dir__+"/config.ini")
hide=ini["path"]["hide"]

cbd = ClipBoard.new(__ENCODING__)

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

$stderr=open("tmp_err.txt","w")
$stdout=open("tmp99.txt","w")
puts Dir.pwd.encode(Encoding::UTF_8)

i=1
tp="tmps_"
while FileTest.file?(ofile=tp+sprintf("%#02d",i)+".txt")
  i+=1
end

ofile=File.expand_path(ofile)
p ofile
ofl=open(ofile,"w")
#p Dir.pwd

arr=cbd.getText.split(/\R/)

fname=File.basename(filename)
st=open(filename).read
ar=[]
arr.each{|e|
  st.scan(/｜([^《》]*#{e})《([^《》]*)》/){|f| ar << f}}
a2,a3=arr.partition{|e| /^\p{Han}+$/=~e}
a2.each{|e|
  st.scan(/(\p{Han}*#{e})《([^《》]+)》/){|f| ar << f}}
a3.each{|e|
  st.scan(/(#{e})《([^《》]+)》/){|f| ar << f}}
ar=ar.uniq
print "ar=";p ar
ofl.puts ar.map{|e| e.join(",")+","}.join("\n")+"\n"


ofl.close
mac=File.expand_path("tmp.mac")
print "mac=";p mac
macro=open(mac,"w")
macro.print("\uFEFF")
macro.puts %|openfile "#{ofile}",utf8;endmacro;|
macro.close

__END__

