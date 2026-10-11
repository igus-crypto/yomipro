# encoding: utf-8
# grep5
# 「置換リストから」「ルビ付き・単語」「読み上げチェック」

Encoding.default_external = 'UTF-8'

require 'inifile'
require 'win32ole'
require 'clipboard'

#$stderr=open("tmp_err.txt","w")
#$stdout=open("tmp99.txt","w")

# l:置換リストから
# r1:ルビ付き（単語）
# y:読み上げチェック

opt=ARGV[0].gsub(/^s/,"")

ini=IniFile.load(__dir__+"/config.ini")
hide=ini["path"]["hide"]
soro=ini["grep"]["soroe"]

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

$stderr=open("tmp_err.txt","w")
$stdout=open("tmp99.txt","w")
puts Dir.pwd.encode(Encoding::UTF_8)
#p soro

class String
  def tr2
    self.tr('ァ-ン','ぁ-ん').tr('ぁぃぅぇぉっゃゅょ','あいうえおつやゆよ')
  end
end

def bsize(txt)
  txt.to_s.tr("—","-").split("").map{|e| e.bytesize==1 ? 1 : 2}.sum
  #"—"は３バイト,"-"は１バイトという罠回避
end

i=1
tp="tmps_"
while FileTest.file?(ofile=tp+sprintf("%#02d",i)+".txt")
  i+=1
end

ofile=File.expand_path(ofile)
p ofile
ofl=open(ofile,"w")
#p Dir.pwd


#ls= Win32::Clipboard.data(Win32::Clipboard::UNICODETEXT).
#  split("\r\n").reject{|e| e=="" or /^[―]*$/=~e }.map{|e| e.gsub(/^置換リスト[^:]*: /,"")}
ls=cbd.getText.split("\r\n").
  reject{|e| e=="" or /^[―]*$/=~e }.map{|e| e.gsub(/^置換リスト[^:]*: /,"")}

st,oya,ruby,com,rp=[],[],[],[],[]
ls.each_with_index{|line,i|
  st[i],oya[i],ruby[i]=/^([^,]*),?([^, ]*)?/.match(line.chomp).to_a}
oya2=oya.map{|e| e.sub(/^!+/,"")+"《([^》]+)》"}

p oya2

#配列
#ls:リスト kk:結果 mt:マッチ

kk,mt=[],[]
fname=File.basename(filename)
fl=open(filename).readlines
#p fl


#p oya
#マッチした行を kk に突っ込んでいく
oya2.each_with_index{|s,i|
  next if s==""
  fl.each_with_index{|line,f|
    kk << fname+":(#{f+1}):#{line}" if /#{s}/=~line}}

kk=kk.sort_by{|e|
  e.match(/#{fname}:\(([0-9]+)\):/)[1].to_i}

kk=kk.uniq
p kk
#kk2=kk.join("\n")
ls.each_with_index{|e,i|
  #p opt
  tb,n=[],10
  kk.each{|k|
    g=k.match(/^([^\)]*\):)/)[1]
    k=k.gsub(/^([^\)]*\):)/,"")
    if /#{oya2[i]}/ =~ k
      #p k
      k.scan(/#{oya2[i]}/){|s| 
        #m1,m2,m3=($`[-n,n]||$`),$&,($'[0,n]).to_s.gsub(/([、。])(.*)/,"\\1").chomp
        m1,m2,m3=($`[-n,n]||$`),$&,($'[0,n]).to_s.gsub(/([。])(.*)/,"\\1").chomp
        st=m1+m2+m3
        #st= $& + ($'[0,n]).to_s.chomp
        if /l/=~opt #置換リストから
          tb << [g+st,g+m1,g+m1+m2] if $1.tr2==ruby[i].tr2 if /《([^》]+)》/=~m2
        else
          tb << [g+st,g+m1,g+m1+m2] if $1==ruby[i] if /《([^》]+)》/=~m2
        end
      }
    end}
  print "tb=";p tb
  ofl.puts (tb.size==0 ? "//"+e : e) if /[rgl]/=~opt
  if soro==0
    ofl.puts tb.transpose[0].join("\n")
  elsif soro==1
    max=tb.transpose[1].to_a.map{|f| bsize(f)}.max
    max=35 if max.to_i<35
    ofl.puts tb.map{|f| " "*(max-bsize(f[1]))+f[0]}.join("\n")
  elsif soro==2
    max=tb.transpose[2].to_a.map{|f| bsize(f)}.max
    max=35 if max.to_i<35
    ofl.puts tb.map{|f| " "*(max-bsize(f[1]))+f[0]}.join("\n")
  end
  ofl.puts "\n" unless opt=="s"
}

ofl.close
t98a=[]
print "rp=";p rp
mac1=File.expand_path("tmp.mac")
mac2=File.expand_path("tmp_g.mac")

#mac=File.expand_path("tmp.mac")
p mac1
t98a=oya.map{|e| e.sub(/^!+/,"")+"(《([^》]+)》)?"}
t98a=t98a.sort{|e| e[1].to_i*(-1)}
p t98a
macro1=open(mac1,"w")
macro1.print("\uFEFF")
macro2=open(mac2,"w")
macro2.print("\uFEFF")
#macro.puts %|openfile "#{ofile}",utf8;|
macro2.puts %|
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

macro1.puts %|
if( findhidemaru("#{ofile}")==-1){
  setactivehidemaru 1;if( findhidemaru("#{ofile}")==-1)
{setactivehidemaru 1;openfile "#{ofile}",utf8;}}

setactivehidemaru findhidemaru("#{ofile}");
|


macro2.puts %|
setsearch ".*=>.*" , 0x4003819;
colormarkerallfound 0x000000, 0xc2c79e, 11, 1;;
setsearch "(.*?):(\\\\(.*?\\\\)):" , 0x4003819;
colormarkerallfound 0, 0xB2B2F5, 0, 0;
disabledraw;
|

i=0
t98a.each{|e|
  macro2.puts %|setsearch "#{e}" , 0x4003819;|
  macro2.puts %|colormarkerallfound 0x000000, #color[#{i%16+1}], 11, 1;|
  i+=1
}

macro2.puts %|
enabledraw;save;endmacro;
|

__END__

