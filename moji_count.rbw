# encoding: utf-8
# 文字数カウント
# moji_count

Encoding.default_external = 'UTF-8'

$stdout=File.open("tmp99.txt","w")
$stderr=File.open("tmp_err.txt","w")

require 'inifile'
require 'win32ole'
require 'clipboard'

wsh= WIN32OLE.new('WScript.Shell')
cbd=ClipBoard.new(__ENCODING__)
ini=IniFile.load(__dir__+"/config.ini")
uwsc=ini["path"]["uwsc"]

st=cbd.getText.gsub(/\r\n/,"\n")
print "st=";p st
n1=(st.size).to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/){"#{$1},"}
n2=((st.size)/400).to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/){"#{$1},"}
#n3=((st.size)/457)
n3=((st.size)/605.0)
n3a,n3b=n3.to_i/60,b=n3.to_i%60
n3c="#{n3b}分"
n3c="#{n3a}時間 "+n3c unless n3a==0
print "st.size=";p st.size
print "n1=";p n1
print "n2=";p n2
print "n3=";p n3
print "n3a=";p n3a
print "n3b=";p n3b

#msg =%Q|文字数は #{n1} です\n\n|
#msg+=%Q|400字詰め原稿用紙 #{n2} 枚以上です\n（改行を一文字でカウント）\n\n|
#msg+=%Q|読み上げ時間：#{n3c}\n読み上げ速度２０相当（605文字/min）|
#wsh.Popup(msg)
#Win32::Clipboard.set_data(n1)
cbd.setText("#{n3a}h#{n3b}m\n")

#uwsの吹き出しで表示<#CR>
msg =%Q|文字数は #{n1} です<#CR><#CR>|
msg+=%Q|400字詰め原稿用紙 #{n2} 枚以上です<#CR>（改行を一文字でカウント）<#CR><#CR>|
msg+=%Q|読み上げ時間：#{n3c}<#CR>読み上げ速度２０相当（605文字/min）|

uws="tmp.uws"
uw =%|FUKIDASI( "#{msg}",420,100,0,20,"ＭＳ ゴシック",,$eeeeee)\n|
#uw =%|FUKIDASI( "#{msg}",420,100,0,20,"Terminal",,$c2c79e)\n|
uw+=%|MSGBOX("ＯＫボタンを押してください")|
IO.write(uws,uw)
Process.wait spawn(%Q|"#{uwsc}" "#{uws}"|)


