# encoding: utf-8
# grep3
# ルビの重複チェック

Encoding.default_external = 'UTF-8'

require 'open3'
require 'inifile'
require 'win32ole'
require 'clipboard'
require_relative 'clipboard_compat'
#require 'win32/clipboard'

#$stderr=open("tmp_err.txt","w")
#$stdout=open("tmp99.txt","w")

ini=IniFile.load(__dir__+"/config.ini")
hide=ini["path"]["hide"]


$stderr=open("tmp_err.txt","w")
$stdout=open("tmp99.txt","w")
puts Dir.pwd.encode(Encoding::UTF_8)
cbd=ClipBoard.new(__ENCODING__)

i=1
while FileTest.file?(ofile="tmp_"+sprintf("%#02d",i)+".txt")
	i+=1
end

ofile=File.expand_path(ofile)
p ofile
ofl=open(ofile,"w")

fname=ARGV[0].encode(Encoding::UTF_8)
fname=File.basename(fname)

#ls= Win32::Clipboard.data(Win32::Clipboard::UNICODETEXT).sub(/^a/,"").split("\r\n")
ls=cbd.getText.split("\r\n")

#配列
#kk(結果)=[[ln(行番号),m][ln,m]…]
kk=[]

ls.each_with_index{|fl,ln|
#	fl.split(/[。　]/).map{|fs| fs.scan(/([\p{Han}]+|[^\p{Han}])(《[^\s》]*》)/){|e|
	fl.split(/[。　]/).map{|fs| fs.scan(/([\p{Han}]+)(《[^\s#-》]*》)/){|e|
		fs.match(/(?<![《》])#{e[0]}(?![《》])/){|f| kk<<[ln,e[0],fs]}}}}
p kk=kk.uniq
#kk.transpose[0].to_a.uniq.map{|e|
#	ofl.puts fname+":(#{e+1}):#{ls[e]}\n\n"}
ofl.puts "重複箇所はありません\n\n" if kk==[]
kk.map{|e| ofl.puts fname+":(#{e[0]+1}):#{e[2]}\n\n"}

mac=File.expand_path("tmp.mac")
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
if kk==[]
  macro.puts %|
gofiletop;enabledraw;save;endmacro;
|
exit
end
macro.puts %|

//マーカー設定
//colormarkerallfound 0, 0xB2B2F5, 0, 0; //編集後もマーカーを保持したい
//setsearch "(.*?):(\\\\(.*?\\\\)):(.*)" , 0x4003819;
//colormarkerallfound 0x000000, 0xc2c79e, 11, 1;;
setsearch ".*=>.*" , 0x4003819;
colormarkerallfound 0x000000, 0xc2c79e, 11, 1;;
setsearch "(.*?):(\\\\(.*?\\\\)):" , 0x4003819;
colormarkerallfound 0, 0xB2B2F5, 0, 0;
disabledraw;
|

i=0
kk.each{|e|
	macro.puts %|gofiletop;searchdown ":(#{e[0]+1}):";selectline 1;rangeeditin;|
	macro.puts %|setsearch "#{e[1]}(《[^》]+》)?" , 0x4003819;|
	macro.puts %|colormarkerallfound 0x000000, #color[#{i%16+1}], 11, 1;|
	macro.puts %|rangeeditout;|
	i+=1
}
macro.puts %|
setsearch "《" , 0x4003819;
colormarkerallfound 0x000000, #color[#{i%16+1}], 11, 1;;
gofiletop;enabledraw;save;endmacro;
|
macro.close

#spawn(%Q|"#{hide}" /fu8 /x "#{mac}" "#{ofile}"|)
#spawn(%Q|"#{hide}" /x "#{mac}"|)
#Open3.popen3(hide,"/x "+mac)
#File.write("tmp.bat",%Q|chcp 65001\n"#{hide}" /x "#{mac}"\nexit\n|)
#Open3.popen3("start /min tmp.bat")


__END__

マクロメニュー01.mac
ルビの重複チェック
