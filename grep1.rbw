# encoding: utf-8
# grep1

Encoding.default_external = 'UTF-8'

#require 'open3'
require 'inifile'
require 'win32ole'
require 'clipboard'

#$stderr=open("tmp_err.txt","w")
#$stdout=open("tmp99.txt","w")
# g:通常（行付き短バージョン）
# a:全体
# r1:ルビ付き（単語）
# r2:ルビ付き（正規表現）
# t:ルビ展開後
# b:傍点ルビ

opt=ARGV[0].to_s.gsub(/^s/,"")

ini=IniFile.load(__dir__+"/config.ini")
hide=ini["path"]["hide"]
soro=ini["grep"]["soroe"]

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
cbd = ClipBoard.new(__ENCODING__)

def bsize(txt)
  txt.to_s.tr("—","-").split("").map{|e| e.bytesize==1 ? 1 : 2}.sum
  #"—"は３バイト,"-"は１バイトという罠回避
end

class String
  def gsub2
    self.gsub(/^《[+=]?([^》]+)》/,'\1').gsub(/《+/,"《").
      gsub(/｜([^《》]+)《=[^《》]*》/,'\1').gsub(/｜[^《》]+《#([^《》]*)》/,'\1').
      gsub(/([\p{Han}])(《=[^《》]*》)/,'\1').gsub(/([^\p{Han}])《(=[^《》]*)》/,'\1').
      gsub(/.《#([^《》]*)》/,'\1').gsub(/｜[^《》]+《([^《》]*)》/,'\1').
      gsub(/[\p{Han}]+《([^《》]*)》/,'\1').gsub(/.《([^《》]*)》/,'\1').
      gsub(/^[=#]?([^》]+)》/,'\1').gsub(/《[^》]+$/,"")
  end
end


i=1
tp=(/[mrgtb]/=~opt ? "tmps_" : "tmp_")
while FileTest.file?(ofile=tp+sprintf("%#02d",i)+".txt")
  i+=1
end

print "ofile=";p ofile
ofile=File.expand_path(ofile)
print "ofile=";p ofile
ofl=open(ofile,"w")
#p Dir.pwd
print "opt=";p opt

if /^b/=~opt
  ls=["(｜[^《｜]+《ヽ{2,}》|.《ヽ》),,r"]
else
  ls=cbd.getText.
    split("\r\n").reject{|e| /^[ 　]*$/=~e or /^[―]*$/=~e }.map{|e| e.gsub(/^置換リスト[^:]*: /,"")}
end

st,oya1,ruby,com,rp=[],[],[],[],[]
ls.each_with_index{|line,i|
  if /^([^,]*),?([^,]*)?,s/=~line
    st[i],oya1[i],ruby[i],rp[i],com[i]=
      /^([^,]*),?([^,]*)?(,s[0-9.]*)?(.*$)?/.match(line.chomp).to_a
  else /^([^,]*),?([^, ]*)?,[rspy]/=~line
    line=line.gsub(/\([^()]*\)/){|s| s.gsub(" ","_spc_").gsub(",","_cmm_")}.
      gsub(/\{[^{}]*\}/){|s| s.gsub(" ","_spc_").gsub(",","_cmm_")}.
      gsub(/《[^《》]*》/){|s| s.gsub(" ","_spc_").gsub(",","_cmm_")}.
      gsub(/｜[^《]*《/){|s| s.gsub(" ","_spc_").gsub(",","_cmm_")}
    st[i],oya1[i],ruby[i],rp[i],com[i]=
      /^([^,]*),?([^, ]*)?(,[rspy][0-9.]*)?(.*$)?/.match(line.chomp).to_a
  end}
rp=rp.map{|e| e.to_s.gsub(",","")}
#print "st=";p st
#print "oya1=";p oya1
oya1=oya1.map{|e| e.gsub(/_spc_/," ").gsub(/_cmm_/,",")}
oya=oya1.map{|e| e.sub(/^!+/,"")}
ruby=ruby.map{|e| e.gsub(/_spc_/," ").gsub(/_cmm_/,",")}

print "oya1=";p oya1
print "oya=";p oya
print "ruby=";p ruby
print "rp=";p rp

# パターン検索（pオプション）
#                                                  ↓ルビで終わるとき
# p       :                   〇〇                 (?![\p{Han}｜]*《)
# p[0-9]+1:     (?<=[ァ-ヴー])〇〇                 (?![\p{Han}｜]*《)
# p[0-9]+2:     (?<=[ァ-ヴー])〇〇(?![《\p{Han}｜》])
# p[0-9]+3:  (?<![ａ-ｚＡ-Ｚ])〇〇(?![《ａ-ｚＡ-Ｚ])
# p[0-9]+4:      (?<![a-zA-Z])〇〇(?![《a-zA-Z])
# p[0-9]+5: (?<![《\p{Han}》])〇〇                 (?![\p{Han}｜]*《)
# p[0-9]+6:                   〇〇(?![《\p{Han}｜》])
# p[0-9]+7: (?<![《\p{Han}》])〇〇(?![《\p{Han}｜》])
# p[0-9]+8:                   〇〇                 (?![\p{Han}｜]*《)
# p[0-9]+9:                   〇〇
# 正規表現オプションのある場合（rオプション）
# r:マッチ部に「《》」があれば処理しない ⇒ マッチ評価時に対応
# r:/[\p{Han}]/で終わる場合、後ろの文字が /[\p{Han}]*《/なら処理しない
# オプション r:ルビ付き t:ルビ展開 の時は除く

if /[rtl]/!~opt
  rp.each_with_index{|e,i|
    print "e=";p e
    print "oya=";p oya[i]
    print "ruby=";p ruby[i]
    if /^y/=~e #読み上げ
      oya[i]="(?<!《)"+oya[i] #+"(?![\\p{Han}｜]*《)"
    elsif e==nil # && /》$/=~ruby[i]
    #elsif e==nil && /》$/=~ruby[i]
      oya[i]=oya[i] +"(?![\\p{Han}]*《)" #if /\p{Han}$/=~oya[i]
    elsif /p(?!\d)/=~e && /》$/=~ruby[i]
      oya[i]=oya[i] +"(?![\\p{Han}｜]*《)"
    elsif /p\d*1$/=~e
      oya[i]="(?<=[ァ-ヴー])"+oya[i] +"(?![\\p{Han}｜]*《)"
    elsif /p\d*2$/=~e
      oya[i]="(?<=[ァ-ヴー])"+oya[i]+"(?![《\\p{Han}｜》])"
    elsif /p\d*3$/=~e
      oya[i]="(?<![ａ-ｚＡ-Ｚ])"+oya[i]+"(?![《ａ-ｚＡ-Ｚ])"
    elsif /p\d*4$/=~e
      oya[i]="(?<![a-zA-Z])"+oya[i]+"(?![《a-zA-Z])"
    elsif /p\d*5$/=~e
      #oya[i]="(?<![《\\p{Han}》])"+oya[i] +"(?![\\p{Han}｜]*《)"
      oya[i]="(?<![《\\p{Han}》])"+oya[i]
    elsif /p\d*6$/=~e
      oya[i]=oya[i]+"(?![《\\p{Han}｜》])"
    elsif /p\d*7$/=~e
      oya[i]="(?<![《\\p{Han}》])"+oya[i]+"(?![《\\p{Han}｜》])"
    elsif /p\d*8$/=~e
      oya[i]=oya[i] +"(?![\\p{Han}｜]*《)"
    elsif /p\d*9$/=~e
      oya[i]=oya[i]
    elsif /ry/=~e && /》$/=~ruby[i]
      oya[i]=oya[i] +"(?![\\p{Han}｜]*《)"
    elsif /ry/=~e
      oya[i]=oya[i] +"(?![\\p{Han}｜]*《)"
    else
      e
    end
    print "oya[i]=";p oya[i]
    #print "e=";p e
    unless /[rs]|^y|p[0-9]+[34]/=~e
      if /[(\\p{Han}｜)]$/=~oya[i]
        oya[i]=oya[i]+"(?![\\p{Han}｜]*《)"
      elsif /》$/=~ruby[i]
        unless /y/=~opt
          if /\p{Han}/=~oya[i]
            oya[i]=oya[i]+"(?!《)"
          else
            oya[i]=oya[i]+"(?![\\p{Han}]*《)"
          end
        end
      else
        #oya[i]=oya[i]+"(?![\\p{Han}]*《)"
      end
    end
    #rp[i]="r"
    rp[i]="w" unless rp[i]
  }
elsif opt=="r2" #ルビ付き（正規表現）
  oya=oya.uniq
  rp=oya.map{|e| ""}
  ls=oya.map{|e| e+","+ruby.find{|f| %r|#{e}|=~f }.to_s+" =>"}
  oya=oya.map{|e| e.split("").join(%q<(\p{Han}*《[^》]*》|｜)?>)+%q<(\p{Han}*《[^》]*》|｜)?>}
  rp=rp.map{|e| "r"}
  print "oya=";p oya
elsif opt=="t" #ルビ展開
  oya=oya.map{|e|%q<(｜?.[《])?>+e.split("").
    join(%q<([》])?(｜?(?:.+|[\\p{Han}]+)《[#=+!%]?)?(｜?(《[#=+!%]?[^》]+》)?)?>)+
    %q<([\\p{Han}》]*)?(｜?(《[#=+!%]?[^》]+》)?)?>}
   print "oya1=";p oya

  rp=rp.map{|e| "r"}
  opt="r"
end
print "oya=";p oya

#配列
#ls:リスト kk:結果 mt:マッチ

kk,mt=[],[]
fname=File.basename(filename)
fl=open(filename).readlines unless /^c/=~opt
#print "fname=";p fname
#print "fl=";p fl

#p oya
#マッチした行を kk に突っ込んでいく
oya.each_with_index{|s,i|
  next if s==""
  fl.each_with_index{|line,f|
    #print "s=";p s
    #print "line=";p line
    if /[rt]/=~opt #ルビ付き,ルビ展開後
      kk << fname+":(#{f+1}):#{line}" if /#{s}/=~line
    else
      if /[rs]/=~rp[i]
        kk << fname+":(#{f+1}):#{line}" if /#{s}/=~line
      else
        kk << fname+":(#{f+1}):#{line}" if /#{s}/=~line && /[《》]/!~line.match(/#{s}/)[0]
      end
    end}}

kk=kk.sort_by{|e|
  e.match(/#{fname}:\(([0-9]+)\):/)[1].to_i}

kk=kk.uniq
print "kk=";p kk
#kk2=kk.join("\n")
#print "ls=";p ls
ls.each_with_index{|e,i|
  if /n/=~opt #行全体
    ofl.puts e
    ofl.puts kk.grep(/#{oya[i]}/).join
    kk=kk.grep_v(/#{oya[i]}/)
  else #短バージョン
    #p opt
    tb=[]
    n=(/^y/=~opt ? 12 : 14)
    #n=5 if opt=="y2"
    #p e
    kk.each{|k|
      g=k.match(/^([^\)]*\):)/)[1]
      k=k.gsub(/^([^\)]*\):)/,"")
      if /#{oya[i]}/ =~ k
        #p k
        k.scan(/#{oya[i]}(《[^》]+》)?/){|s| 
          print "hogeoya[i]=";p oya[i]
          #m1,m2,m3=($`[-n,n]||$`),$&,($'[0,n]).to_s.gsub(/([、。])(.*)/,"\\1").chomp
          m1,m2,m3=($`[-n,n]||$`),$&,($'[0,n]).to_s.gsub(/([。])(.*)/,"\\1").chomp
          m1=m1.gsub(/^[^《]+》|^》/,"").gsub(/^([^\p{Han}]+)(?=[^\p{Han}]《)/,"")
          print "m123=";p [m1,m2,m3]
          st=m1+m2+m3
          #print "st="; p st
          #st= $& + ($'[0,n]).to_s.chomp
          if /[\p{Han}]/=~m1[-1] and /^[\p{Han}]+《/=~ruby[i]
            rub="｜"+ruby[i]
          else
            rub=ruby[i]
          end
          #p [rub,m1,m2,m1[-1]]
          tb << [g+st,g+m1,g+m1+m2] unless /\p{Han}$/=~m2 and /^\p{Han}*《/=~m3
          tb=tb.map{|b| b.map{|c| c.gsub(/《[^》]+$/,"")}}
          #print "tb=";p tb
          }
      end}
    ofl.puts (tb.size==0 ? "//"+e : e) if /[rg]/=~opt
    if soro==0
      ofl.puts tb.transpose[0].join("\n")
    elsif soro==1
      max=tb.transpose[1].to_a.map{|f| bsize(f)}.max
      ofl.puts tb.map{|f| " "*(max-bsize(f[1]))+f[0]}.join("\n")
    elsif soro==2
      max=tb.transpose[2].to_a.map{|f| bsize(f)}.max
      ofl.puts tb.map{|f| " "*(max-bsize(f[1]))+f[0]}.join("\n")
    end
  end
  ofl.puts "\n" unless opt=="s"
}

ofl.close
t98a=[]
#print "rp=";p rp
mac1=File.expand_path("tmp.mac")
mac2=File.expand_path("tmp_g.mac")
#print "mac=";p mac
oya.each_with_index{|e,i|
  if /r/=~rp[i]
    t98a << [e,rp[i]]
  else
    t98a << [e.gsub(/\([^\(\)]*\)/,""),rp[i]]
  end}
t98a=t98a.sort{|e| e[1].to_i*(-1)}
print "t98a=";p t98a
ofile=ofile.gsub("\/"){'\\\\'}
#ofile=ofile.gsub(/^.*\//,"")

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
if (leftstr(basename,4)=="tmps"){
setsearch ".*=>.*" , 0x4003819;
colormarkerallfound 0x000000, 0x71B33C, 11, 1;;
}
setsearch "(.*?):(\\\\(.*?\\\\)):" , 0x4003819;
colormarkerallfound 0, 0xB2B2F5, 0, 0;
disabledraw;
|

i=0
t98a.each{|e|
  if e[1]
    macro2.puts %|setsearch "#{e[0].gsub(/\\/){'\\\\'}}" , 0x4003819;|
  else
    macro2.puts %|setsearch "#{e[0]}" , 0x4003809;|
  end
  macro2.puts %|colormarkerallfound 0x000000, #color[#{i%16+1}], 11, 1;|
  i+=1
}

macro2.puts %|
enabledraw;endmacro;
|
macro1.close
macro2.close

#spawn(%Q|"#{hide}" /fu8 /x? "#{mac}" "#{ofile}"|)
#↑時々他のマクロが実行中と言われてエラーになるので変更

__END__

ルビのgrepのファイル出力.mac
