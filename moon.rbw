# encoding: utf-8

Encoding.default_external = 'UTF-8'
require 'inifile'
require 'win32ole'
require 'clipboard'
require_relative 'clipboard_compat'
require 'fileutils'

opt=ARGV[0].to_s.encode(Encoding::UTF_8).gsub("\\","/")

# .replacement  :Moon+ Reader 置換リスト変換
# .txt          :Moon+ Reader ハイライト変換
# l:リストチェック
# m:マクロメニューNoチェック
# s:対象ファイルに保存
# r:ルビ内空白除去


unless /^[hts]/=~opt
  $stdout=open("tmp99.txt","w")
  $stderr=open("tmp_err.txt","w")
end

ini=IniFile.load(__dir__+"/config.ini")
hide=ini["path"]["hide"]
gfl1=ini["grep"]["file_1"]
tfl2=ini["grep"]["file_2"]

cbd=ClipBoard.new(__ENCODING__)
st=cbd.getText

if /^[s]|\.txt|\.replacement/=~opt
  Dir.chdir(File.dirname(gfl1))
  $stdout=open("tmp99.txt","w")
  $stderr=open("tmp_err.txt","w")
end

print "opt=";p opt

if /\.replacement/=~opt # Moon+ Reader 置換リスト変換
  ofs="n"
  bf=st.split("\r\n")
  ar=bf.map{|e| e.gsub(/#->#/,",")}
elsif /\.txt/=~opt # Moon+ Reader ハイライト変換
  ofs="m"
  r=%r|^(▪ .*)$|
  bf=st.scan(r).flatten.uniq.map{|e| e.chomp}
  #ar=bf.map{|e| e.sub(/^▪ (.*)$/){|f| $1+','+$1.gsub(/([\p{Han}]+)/,'\1《’\1》')}+" =>"}.
  ar=bf.map{|e| e.sub(/^▪ (.*)$/){|f| $1+','+$1.gsub(/([\p{Han}]+)/,'\1《\1》')}+" =>"}.
    map{|e| e.gsub(/◆.*/,"")}
elsif /^l/=~opt # リストチェック
  #ar=st.split(/\R/).map{|e| e.gsub(%r|,.*|,"")}.
  #  map{|e| e=%Q|replaceallfast "(.*#{e}.*,)","!\\\\1",regular;|}
  ar9=st.to_s.split(/\R/)
  fn=ARGV[1]
  ar0=open(fn).read.split(/\R/)
  ar1,ar2=[],[]
  print "ar9=";p ar9
  ar0.each{|e| ar9.each{|f|
      f0=f.gsub(%r|,.*|,"")
      if %r|#{f0}|=~e
        ar1 << e
      end}}.uniq
  ar2=ar0-ar1
  print "ar1=";p ar1
  print "ar2=";p ar2
  az=("a".."z").to_a+("aa".."zz").to_a
  i=0
  ofile0=fn.gsub(/\.[^\.]+$/,"")
  while FileTest.file?(ofile0+az[i]+".txt")
    i+=1
  end
  ofile1=ofile0+az[i]+".txt"
  i+=1
  while FileTest.file?(ofile0+az[i]+".txt")
    i+=1
  end
  ofile2=ofile0+az[i]+".txt"
  #print "ofile1=";p ofile1
  #print "ofile2=";p ofile2
  File.write(ofile1,"\uFEFF"+ar1.join("\n")+"\n")
  File.write(ofile2,"\uFEFF"+ar2.join("\n")+"\n")
  ofile1=ofile1.gsub(/\\/){'\\\\'}
  ofile2=ofile2.gsub(/\\/){'\\\\'}
  mac=open("tmp.mac","w:utf-8")
  mac.print("\uFEFF")
  mdir=__dir__.gsub(/\//){'\\\\'}
  #print "mdir=";p mdir
  #mac.puts %Q|begingroupundo;disabledraw;|
  #ar.each{|e| mac.puts e}
  #mac.puts %Q|enabledraw;endgroupundo;|
#hwnd = hidemaruhandle(0);
  mac.puts %Q|#hwnd = hidemaruhandle(0);|
  unless ar1==[]
    mac.puts %Q|openfile "#{ofile1}",utf8;|
    mac.puts %Q|begingroupundo;selectall;cut;escape;|
    mac.puts %Q|runsync2 "rubyw #{mdir}\\\\partition.rbw";|
    mac.puts %Q|paste;endgroupundo;gofiletop;save;|
  end
  mac.puts %Q|openfile "#{ofile2}",utf8;|
  mac.puts %Q|begingroupundo;selectall;cut;escape;|
  mac.puts %Q|runsync2 "rubyw #{mdir}\\\\partition.rbw";|
  mac.puts %Q|paste;endgroupundo;gofiletop;save;setactivehidemaru 1;|
  mac.puts %Q|closehidemaruforced #hwnd;|
  mac.puts %Q|openfile "";insert "#{(ar1+ar2).size}\\n";|
  mac.puts %Q|saveas "tmp_memo.txt";setwindowsize 30,5;|
  exit
elsif /^m/=~opt # マクロメニューNoチェック
  ofs="tmp_m"
  r=/^\$a.*;#num=.*;/
  ar=st.scan(r).flatten.map{|e| e.gsub(/=""/,"").gsub(/\r/,"")}
  p st;p ar
elsif /^s/=~opt # 対象ファイルに保存
  mac=__dir__+"/tmp.mac"
  tfile=File.dirname(gfl1)+"/"+tfl2
  bfile=File.dirname(gfl1)+"/tmp_"+tfl2
  #print "t=";p tfile
  #print "b=";p bfile
  #print "m=";p mac
  if FileTest.file?(tfile)
    wsh = WIN32OLE.new('WScript.Shell')
    a=wsh.Popup("#{tfile}　に上書きしますか？\n",-1,"注意",4)
    print "a=";p a
    if a==7
      File.write(mac,"endmacro;")
      exit
    else
      FileUtils.cp tfile,bfile
    end
  end
  st =%Q|\uFEFFsaveas "#{tfile}",utf8,bom;\n|
  File.write(mac,st)
  exit
elsif /^r/=~opt #ルビ内空白除去
  r=%r|(《[^《》]+》)|
  p bf=st.scan(r).select{|e| /[ 　]/=~e[0]}.flatten.uniq
  p af=bf.map{|e| e.gsub(/[ 　]/,"")}
  mac=open(File.expand_path("tmp.mac"),"w:utf-8")
  st=st.chomp
  mac.print("\uFEFF")
  mac.puts %Q|begingroupundo;disabledraw;|
  bf.each_with_index{|e,i|
    mac.puts %Q|replaceallfast "#{e}","#{af[i]}";|}
  mac.puts %Q|endgroupundo;enabledraw;|
  exit
end

num=1
while FileTest.file?(ofn=ofs + num.to_s + ".txt")
  num+=1
end
ofn=ofs+ num.to_s + ".txt"
File.write(ofn,ar.join("\n")+"\n")
if /\.replacement/=~opt # Moon+ Reader 置換リスト変換
  mac=File.expand_path("tmp.mac")
  st =%Q|setwindowsize 40, 10;\n|
  st+=%Q|#hwnd=hidemaruhandle(1);closehidemaruforced #hwnd;\n|
  File.write(mac,st)
elsif /\.txt/=~opt # Moon+ Reader ハイライト変換
  mac=File.expand_path("tmp.mac")
  st =%Q|setwindowsize 40, 10;\n|
  st+=%Q|#hwnd=hidemaruhandle(1);closehidemaruforced #hwnd;\n|
  File.write(mac,st)
elsif /^[m]/=~opt # マクロメニューNoチェック
  mac=File.expand_path("tmp.mac")
  File.write(mac,"setwindowsize 30, 17;\n")
end
spawn(%Q|"#{hide}" /fu8 /x "#{mac}" "#{ofn}"|)
