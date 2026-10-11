# encoding: utf-8
# 選択を送信ファイルに

Encoding.default_external = 'UTF-8'

$stdout=open("tmp99.txt","w")
$stderr=open("tmp_err.txt","w")

require 'inifile'
require 'clipboard'
require 'win32ole'

#s:選択を send.txt
#n:選択を send.txt（ルビ無し）
#1:選択を send.txt（第一要素）
#a:ファイル転送（青空）
#p:ファイル転送（スクリプト）
#f:ファイル転送
#c:ログフォルダにコピー
#u:UTF8保存

opt=ARGV[0]

ini=IniFile.load(__dir__+"/config.ini")
hide=ini["path"]["hide"]
send=ini["path"]["send"]
adb=ini["path"]["adb"]
adb2=ini["path"]["adb2"]
gfl1=ini["grep"]["file_1"]

class String
  def del_oya
    st=self.gsub(/｜([^《》]+)《[=#][^《》]*》/,'\1').gsub(/｜[^《》]+《[+%]?([^《》]*)》/,'\1').
      gsub(/《[+%!]([^《》]*)》/,'《\1》').gsub(/([\p{Han}])(《[=#][^《》]*》)/,'\1').
      gsub(/([^\p{Han}])《[=#]([^《》]*)》/,'\1').gsub(/[\p{Han}]+《([^《》]*)》/,'\1').
      gsub(/.《([^《》]*)》/,'\1').gsub(/^《?([^《》]*)》/,'\1').gsub(/《[^《》]*$/,"")
  end
end


if /[afp]/=~opt
  file=ARGV[1].encode(Encoding::UTF_8)
  adb=File.dirname(adb.to_s)+"/"+File.basename(file)
  adb2=File.dirname(adb2.to_s)+"/"+File.basename(file)
  adb3="/sdcard/qpython/scripts3/"+File.basename(file)
  adb=adb2 if /a/=~opt
  adb=adb3 if /p/=~opt
  print "opt=";p opt
  print "file=";p file
  print "adb=";p adb
  puts "adb push #{send} #{adb}"
  wsh = WIN32OLE.new('WScript.Shell')
  wsh.run("adb push #{file} #{adb}")
  exit
elsif /u/=~opt #UTF8保存
  file=ARGV[1].gsub(/\\/,"/").encode(Encoding::UTF_8)
  print "file=";puts file
  mac=open("tmp.mac","w:utf-8")
  f2=file
  f3=f2.gsub("/","\\\\\\")
  mac.print("\uFEFF")
  mac.puts %Q|saveas "#{f3}",utf8,bom;|
  fi=open(__dir__+"/config.ini").readlines
  fi=fi.map{|e| e.gsub(/file_1=.*/,"file_1=#{f2}")}
  File.write(__dir__+"/config.ini",fi.join)
  wsh = WIN32OLE.new('WScript.Shell')
  wsh.Popup("対象ファイルを#{f2}に設定しました",1)
  exit
end

cbd = ClipBoard.new(__ENCODING__)
st=cbd.getText
#st=st.del_oya
print "st=";p st

if /n/=~opt
  ar=st.split(/\R/).map{|e| e.gsub(%r|《(?![=#])|,"《=")}.uniq
elsif /s/=~opt
  ar=st.split(/\R/)
elsif /1/=~opt
  ar=st.split(/\R/).map{|e| e.gsub(%r|,.*|,"").gsub(%r|\([^()]*\)|,"")}.uniq
end

ar=ar.map{|e| e.gsub(%r|《\+|,"《").del_oya.gsub(%r|《[^》]*$|,"").
  gsub(%r|.*:?\(?\d*\):|,"").gsub(%r| =>.*|,"").gsub("=","").
  gsub(%r|,?[srp]\d+|,"").gsub(" //"," ,").gsub(/\([^\(\)]+\)/,"")}
print "ar=";p ar
#puts "adb push #{send} #{adb}"

#ar=st.split("\r\n")
File.write(send,ar.join("\n")+"\n")
#spawn("adb push #{send} #{adb}")
wsh = WIN32OLE.new('WScript.Shell')
wsh.run("adb push #{send} #{adb}")
#wsh.run("adb push #{send} #{adb2}")
wsh.Popup("#{send} に出力しました",1)
