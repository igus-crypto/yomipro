# encoding: utf-8
# grep4
# 仕上げのgrep

Encoding.default_external = 'UTF-8'

require 'open3'
require 'inifile'
require 'win32ole'
require 'clipboard'

ini=IniFile.load(__dir__+"/config.ini")
hide=ini["path"]["hide"]
soro=ini["grep"]["soroe"]

$stderr=open("tmp_err.txt","w")
$stdout=open("tmp99.txt","w")
puts Dir.pwd.encode(Encoding::UTF_8)
p soro

cbd=ClipBoard.new(__ENCODING__)

def bsize(txt)
  txt.to_s.tr("—","-").split("").map{|e| e.bytesize==1 ? 1 : 2}.sum
  #"—"は３バイト,"-"は１バイトという罠回避
end

def convert_kansuji(text)
  text.tr('〇○一二三四五六七八九・、，','00123456789.,,')
    .gsub(/(\d+)?十(\d+)?/)  {  ($1||1).to_i*10+$2.to_i}
    .gsub(/(\d+)?百(\d+)?/)  {  ($1||1).to_i*100+$2.to_i}
    .gsub(/(\d+)?千(\d+)?/)  {  ($1||1).to_i*1000+$2.to_i}
    .gsub(/(\d+)万(\d+)?/)  {  $1.to_i*10000+$2.to_i}
    .gsub(/(\d+)億(\d+)?/)  {  $1.to_i*100000000+$2.to_i}
    .gsub(/(\d+)兆(\d+)?/)  {  $1.to_i*1000000000000+$2.to_i}
end


i=1
while FileTest.file?(ofile="tmps_"+sprintf("%#02d",i)+".txt")
  i+=1
end

ofile=File.expand_path(ofile)
p ofile
ofl=open(ofile,"w")
#p Dir.pwd
fname=ARGV[0].encode(Encoding::UTF_8)
fname=File.basename(fname)

ls=cbd.getText

kk1,kk2,kk3,kk4,kk5,kk6,kk7=[],[],[],[],[],[],[]
n=15 #前後の文字数

# 親文字が７文字以上の個所をチェック
ls.scan(/([一-龠]{7,})《([^》]+)》/){|e| kk1<<$&}
if kk1.size>0
  ofl.puts "//親文字が７文字以上の個所をチェック"
  kk1=kk1.uniq
  kk1.each{|e| 
    ls.split("\r\n").each_with_index{|f,i|
      if /#{e}/=~f
        a,b,c=$`,$&,$'
        ofl.puts e+","+e[0..3]+"《》"+e[4..-1]
        ofl.puts fname+%Q|:(#{i+1}):|+(a[-n,n]||a)+b+
          (c[0,n]).gsub(/(?<=[、。])(.*)/,"")
      end}}
  ofl.puts "\n"
end

# 小数点付き漢数字を半角に
ls.scan(/(?<!｜)[一二三四五六七八九〇○十百千万億兆]+・[〇○一二三四五六七八九]+(?![一-龠]*《)/){|e| kk3<<$&}
kk3=kk3.uniq.sort_by{|e| e.bytesize }.reverse
if kk3.size>0
  ofl.puts "//小数点付き漢数字を半角に"
  kk3.each{|e|
    ls.split("\r\n").each_with_index{|f,i|
      if /#{e}/=~f
        a,b,c=$`,$&,$'
        ofl.puts e+","+convert_kansuji(e)
        ofl.puts fname+%Q|:(#{i+1}):|+(a[-n,n]||a)+b+
          (c[0,n]).gsub(/(?<=[、。])(.*)/,"")
      end}}
  ofl.puts "\n"
end

# 二桁以上の漢数字を半角に
ls.scan(/(?<!｜)([一二三四五六七八九〇○]{2,})
  ([、，][一二三四五六七八九〇○]{3})*[\p{Han}]*(?=[^\p{Han}《])/x){|e| kk4<<$&}
print "kk4=";p kk4
p kk4=kk4.uniq.sort_by{|e| e.bytesize }.reverse
if kk4.size>0
  ofl.puts "//二桁以上の漢数字を半角に"
  kk4.each{|e|
    ofl.puts e+","+convert_kansuji(e)
    ls.split("\r\n").each_with_index{|f,i|
      if /#{e}/=~f
        a,b,c=$`,$&,$'
        ofl.puts fname+%Q|:(#{i+1}):|+(a[-n,n]||a)+b+
          (c[0,n]).gsub(/(?<=[、。])(.*)/,"")
      end}}
  ofl.puts "\n"
end

# 小数点を含むアラビア数字を半角に
ls.scan(/([０-９]+[・．][０-９]+)/){|e| kk5<<$&}
kk5=kk5.uniq.sort_by{|e| e.bytesize }.reverse
if kk5.size>0
  ofl.puts "//小数点を含むアラビア数字を半角に"
  kk5.each{|e|
    ls.split("\r\n").each_with_index{|f,i|
      if /#{e}/=~f
        a,b,c=$`,$&,$'
        ofl.puts e+","+e.tr("０-９・．","0-9..")
        ofl.puts fname+%Q|:(#{i+1}):|+(a[-n,n]||a)+b+
          (c[0,n]).gsub(/(?<=[、。])(.*)/,"")
      end}}
  ofl.puts "\n"
end

# 「は」を含むルビをカタカナに
ls.scan(/([一-龠])*《[^》-]*は[^-》]*》/){|e| kk6<<$&}
kk6=kk6.uniq.sort_by{|e| e.bytesize }.reverse
if kk6.size>0
  ofl.puts "//「は」を含むルビをカタカナに"
  kk6.each{|e|
    ls.split("\r\n").each_with_index{|f,i|
      if /#{e}/=~f
        a,b,c=$`,$&,$'
        ofl.puts e+","+e.tr('ぁ-ん','ァ-ン')
        ofl.puts fname+%Q|:(#{i+1}):|+(a[-n,n]||a)+b+
          (c[0,n]).gsub(/(?<=[、。])(.*)/,"")
      end}}
  ofl.puts "\n"
end

# 「へ」を含むルビをカタカナに（チェック）
ls.scan(/([一-龠])*《[^》-]*[へヘ][^-》]*》/){|e| kk7<<$&}
kk7=kk7.uniq.sort_by{|e| e.bytesize }.reverse
if kk7.size>0
  ofl.puts "//「「へ」を含むルビをカタカナに（チェック）"
  kk7.each{|e|
    ls.split("\r\n").each_with_index{|f,i|
      if /#{e}/=~f
        a,b,c=$`,$&,$'
        ofl.puts e+","+e.tr('ぁ-ん','ァ-ン')
        ofl.puts fname+%Q|:(#{i+1}):|+(a[-n,n]||a)+b+
          (c[0,n]).gsub(/(?<=[、。])(.*)/,"")
      end}}
  ofl.puts "\n"
end

kk8=kk1+kk2+kk3+kk4+kk5+kk6+kk7
ofl.puts "異常なし\n" if kk8==[]

ofl.close

mac=File.expand_path("tmp.mac")
p mac

macro=open(mac,"w")
macro.print("\uFEFF")
macro.puts %|openfile "#{ofile}",utf8;|
macro.puts %|
#color[ 1]=val("0x#{ini['color']['color_1']}");
#color[ 2]=val("0x#{ini['color']['color_2']}");
#color[ 3]=val("0x#{ini['color']['color_3']}");
#color[ 4]=val("0x#{ini['color']['color_4']}");
#color[ 5]=val("0x#{ini['color']['color_5']}");
#color[ 6]=val("0x#{ini['color']['color_6']}");
#color[ 7]=val("0x#{ini['color']['color_7']}");
#color[ 8]=val("0x#{ini['color']['color_8']}");
#color[ 9]=val("0x#{ini['color']['color_9']}");
#color[10]=val("0x#{ini['color']['color_10']}");
#color[11]=val("0x#{ini['color']['color_11']}");
#color[12]=val("0x#{ini['color']['color_12']}");
#color[13]=val("0x#{ini['color']['color_13']}");
#color[14]=val("0x#{ini['color']['color_14']}");
#color[15]=val("0x#{ini['color']['color_15']}");
#color[16]=val("0x#{ini['color']['color_16']}");
|

i=10
macro.puts %|

//マーカー設定
//setsearch "^//.*" , 0x4003819;
//colormarkerallfound 0x000000, #color[#{i%16+1}], 11, 1;;
//setsearch "(.*?):(\\\\(.*?\\\\)):(.*)" , 0x4003819;
//colormarkerallfound 0x000000, 0xc2c79e, 11, 1;;
setsearch ".*=>.*" , 0x4003819;
colormarkerallfound 0x000000, 0xc2c79e, 11, 1;;
setsearch "(.*?):(\\\\(.*?\\\\)):" , 0x4003819;
colormarkerallfound 0, 0xB2B2F5, 0, 0;

|

(kk1+kk2+kk3+kk4+kk5+kk6+kk7).each{|e|
  macro.puts %|setsearch "#{e}" , 0x4003809;|
  macro.puts %|colormarkerallfound 0x000000, #color[#{i%16+1}], 11, 1;|
  i+=1
}

macro.puts %|

gofiletop;enabledraw;save;endmacro;
|
macro.close

spawn(%Q|"#{hide}" /x "#{mac}"|)
#Open3.popen3(hide,"/x "+mac)
#File.write("tmp.bat",%Q|chcp 65001\n"#{hide}" /x "#{mac}"\nexit\n|)
#Open3.popen3("start /min tmp.bat")

__END__

マクロメニュー01.mac
仕上げのgrep
