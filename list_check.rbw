# encoding: utf-8
# list_check
# 置換リストの重複チェック

Encoding.default_external = 'UTF-8'
require 'inifile'

#デバッグ用
$stdout=File.open("tmp99.txt","w")
$stderr=File.open("tmp_err.txt","w")

ini=IniFile.load(__dir__+"/config.ini")
hide=ini["path"]["hide"]

arr,i,e,m1,m2=[],0,"","",""
seen={}
groups={}
reg=/^([^,]*),(?![^\{\}]*})/
Dir.glob(__dir__+%Q|/置換リスト/置換リスト*.txt|){|file|
  p File.basename(file)
  next if /ルビチェック|英数字チェック/=~file
  File.foreach(file).with_index{|f,j|
    #reg=(/ルビチェック/=~file ? /^[\p{Han}]+,/ : /^([^,]*),/)
    if reg=~f
      m2=$1
      if m1==m2
        [File.basename(file)+"(#{i+1}): " + e.chomp,
         File.basename(file)+"(#{j+1}): " + f.chomp].each{|entry|
          next if seen[entry]
          seen[entry]=true
          key=entry.match(/(?<=: )([^,]*),/).to_a[0]
          (groups[key]||=[]) << entry
        }
      end
      m1,i,e=m2,j,f
    end}}
arr=groups.values
#arr=arr.group_by{|e| e.match(/(?<=: )([^,]*),(?![^\{\}]*})/).to_a[0]}.to_a.transpose[1]
arr=[["重複はありません"]] if arr.empty?

i=1
while FileTest.file?(ofile=__dir__+%Q|/置換リスト/tmp_|+sprintf("%#02d",i)+".txt")
  i+=1
end

File.write(ofile,arr.map{|e| e.join("\n")}.join("\n\n")+"\n")

# 秀丸マクロ作成
mac="tmp.mac"
macro=open(mac,"w")
macro.print "\uFEFF"
macro.puts %|
setsearch "(.*?)(\\\\(.*?\\\\)):(.*)" , 0x4003819;
colormarkerallfound 0x000000, 0xc2c79e, 11, 1;;
setsearch "(.*?)(\\\\(.*?\\\\)):" , 0x4003819;
colormarkerallfound 0, 0xB2B2F5, 0, 0;
|
mac=File.expand_path(mac)
spawn(%Q|"#{hide}" /x #{mac} /fu8 "#{ofile}"|)

__END__


