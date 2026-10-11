# encoding: utf-8
# close_file

Encoding.default_external = 'UTF-8'

require 'inifile'
require 'win32ole'

ini=IniFile.load(__dir__+"/config.ini")
hide=ini["path"]["hide"]
uwsc=ini["path"]["uwsc"]

$stderr=open("tmp_err.txt","w")
$stdout=open("tmp99.txt","w")

opt=ARGV[0]
#0:メニュー表示
#1:セーブして終了
#2:ソートしてセーブ
#3:ソートしてセーブして終了

p opt
list=open(__dir__+"/tmp_f.txt").read.split(/\R/)
if list.size<2
  wsh = WIN32OLE.new('WScript.Shell')
  a=wsh.Popup("置換リストファイルをソートしますか？\n",-1,"確認",4)
  print "a=";p a
  Process.wait spawn(%Q|rubyw #{__dir__}/sort6.rbw |) unless a==7
  spawn(%Q|rubyw #{__dir__}/list_check.rbw |) unless a==7
  exit
end
f0=list[0]
fs=list[1..-1].sort
print "fs=";p fs
macro=File.expand_path("..", __FILE__)+"/tmp.mac"
print "macro=";p macro

mac=open(macro,"w")
mac.print("\uFEFF")

if /^0/=~opt
  uws=__dir__+"/ファイルを閉じる.uws"
  uw=open(uws).read
  uw=uw.gsub(/^list=.*$/,%Q|list="#{fs.join("<\#CR>")+"<\#CR>"}"|)
  File.write(uws,uw)
  spawn(%Q|"#{uwsc}" "#{uws}"|)
elsif /^1/=~opt #セーブして終了
  mac.puts %Q|#hwnd_0= hidemaruhandle(0);|
  #mac.puts %Q|#hwnd_0= hidemaruhandle(0);$s="";|
  fs.each_with_index{|e,i| mac.puts %Q|$files[#{i}]="#{e}";|}
  mac.puts %Q|#i=0;#j=#{fs.size};$fa="#{f0}";|
  mac.puts %Q|while(#i<#j){setactivehidemaru findhidemaru($files[#i]);save;#i=#i+1;}|
  mac.puts %Q|setactivehidemaru findhidemaru($fa);#i=0;|
  mac.puts %Q|while(#i<#j){sleep 1000;closehidemaruforced findhidemaru($files[#i]);#i=#i+1;}|
  mac.puts %Q|sleep 1000;closehidemaru #hwnd_0;|
  #mac.puts %Q|while(#i<#j){$s=$s+$files[#i]+"("+str(findhidemaru($files[#i]))+")";|
  #mac.puts %Q|closehidemaruforced findhidemaru($files[#i]);#i=#i+1;}|
  #mac.puts %Q|openfile "";insert $s;|
  #mac.puts %Q|closehidemaru #hwnd_0;|
  spawn(%Q|"#{hide}" /x "#{macro}"|)
  #ACW(GETID("秀丸","Hidemaru32Class"))
elsif /^2/=~opt #ソートしてセーブ
  mac.puts %Q|#hwnd_0= hidemaruhandle(0);|
  fs.each_with_index{|e,i| mac.puts %Q|$files[#{i}]="#{e}";|}
  mac.puts %Q|#i=0;#j=#{fs.size};$fa="#{f0}";|
  mac.puts %Q|while(#i<#j){setactivehidemaru findhidemaru($files[#i]);|
  mac.puts %Q|begingroupundo;selectall;cut;|
  mac.puts %Q|runsync2 "rubyw "+currentmacrodirectory+"\\\\sort1.rbw "+$files[#i];|
  mac.puts %Q|paste;endgroupundo;gofiletop;save;#i=#i+1;}|
  mac.puts %Q|setactivehidemaru findhidemaru($fa);#i=0;|
  mac.puts %Q|sleep 1000;closehidemaru #hwnd_0;|
  spawn(%Q|"#{hide}" /x "#{macro}"|)
  #ACW(GETID("秀丸","Hidemaru32Class"))
elsif /^3/=~opt #ソートしてセーブして終了
  mac.puts %Q|#hwnd_0= hidemaruhandle(0);|
  fs.each_with_index{|e,i| mac.puts %Q|$files[#{i}]="#{e}";|}
  mac.puts %Q|#i=0;#j=#{fs.size};$fa="#{f0}";|
  mac.puts %Q|while(#i<#j){setactivehidemaru findhidemaru($files[#i]);|
  mac.puts %Q|begingroupundo;selectall;cut;|
  mac.puts %Q|runsync2 "rubyw "+currentmacrodirectory+"\\\\sort1.rbw "+$files[#i];|
  mac.puts %Q|paste;endgroupundo;gofiletop;save;#i=#i+1;}|
  mac.puts %Q|setactivehidemaru findhidemaru($fa);#i=0;|
  mac.puts %Q|while(#i<#j){sleep 1000;closehidemaruforced findhidemaru($files[#i]);#i=#i+1;}|
  mac.puts %Q|sleep 1000;closehidemaru #hwnd_0;|
  mac.puts %Q|runsync2 "rubyw "+currentmacrodirectory+"\\\\list_check.rbw ";|
  spawn(%Q|"#{hide}" /x "#{macro}"|)
  #ACW(GETID("秀丸","Hidemaru32Class"))
end
__END__

置換リストファイルを閉じる
