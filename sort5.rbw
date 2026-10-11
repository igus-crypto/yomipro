# encoding: utf-8
# sort5
# ルビソート（選択範囲）
Encoding.default_external = 'UTF-8'

require 'inifile'
require 'win32ole'
require 'clipboard'

ini=IniFile.load(__dir__+"/config.ini")

file=ini["grep"]["file_1"]
unless FileTest.file?(file)
  file=ini["grep"]["file_2"]
  if FileTest.directory?(File.dirname(file))
    Dir.chdir(File.dirname(file))
  else
    wsh = WIN32OLE.new('WScript.Shell')
    a=wsh.Popup("#{File.dirname(file)}がありません\n"+
      "#{__dir__}\nにtmpファイルを作成します",0,"注意",0)
  end
end

#デバッグ用
$stdout=open("tmp_s99.txt","w")
$stderr=open("tmp_serr.txt","w")

opt=ARGV[0]
print "opt=";p opt
# s :選択範囲
# s1:選択範囲（!分離）
# s2:置換リストを集める
# k :選択範囲を漢字ごとに
# k1:選択範囲を漢字ごとに（シフトキー）
# b :選択範囲（=分離）

if /[skb]/=~opt
  upd=""
  sep=""
else
  upd="最終更新日："+Time.new.strftime("%Y.%m.%d")+"\n\n"
  sep="―"*20+"\n"
end

cbd=ClipBoard.new(__ENCODING__)

# macro=open("tmp.mac","w")
class String
  def bsize
    self.to_s.tr("—","-").split("").map{|e| e.bytesize==1 ? 1 : 2}.sum
    #"—"が実は３バイトという罠回避 "-"は１バイト
  end
end
class Array
  def sortq
    ar=self.group_by{|e| e.gsub(/^(!*)([^!].*)/,'\1').size}.
      to_a.sort_by{|e| -e[0].to_i}.transpose[1].to_a.
      map{|e| e.partition{|f| %r|[^ ]*,y|!~f}}
    #print "ar=";p ar
    ar
  end
end

arr=cbd.getText.
  split("\r\n").grep_v(/^―*$|^最終更新日：/).uniq
print "arr=";p arr

if /s1/=~opt #選択範囲（!分離）
  ar1=arr.grep_v(/=>/)
  ar2=ar1.grep(/@/).sortq
  ar1=ar1.grep_v(/@/).sortq
  ar3=arr.grep(/=>/)#.sortq
  ar4=ar3.grep_v(/=>$/).sortq
  ar3=ar3.grep(/=>$/).sortq
  #ar2=arr.grep(/=>$/).sortq
  #ar3=arr.grep_v(/=>$/).sortq
  #ar3=arr.sortq
  print "ar1=";p ar1
  print "ar2=";p ar2
  print "ar3=";p ar3
  print "ar4=";p ar4
  print "arr=";p [ar1,ar2,ar3,ar4].map{|e| e.map{|f| f.join("\n")}.join("\n\n")}
  st=[ar1,ar2,ar3,ar4].map{|e| e.map{|f| f.map{|g| g.join("\n")}.join("\n\n")}.
    join("\n\n")}.join("\n\n")
  print "st=";p st
  st=st.strip.gsub(/\n{3,}/,"\n\n")+"\n"
  print "st=";p st
  cbd.setText(st)
  exit
elsif /s2/=~opt #置換リストを集める
  arr=cbd.getText.sub(/[^\R]*?\R\R/m,"").split(/\R/).grep_v(/^―*$|^最終更新日：/)
  print "arr=";p arr
  ar1=arr.grep(/,/)
  st=""
  st="\n\n"+ar1.join("\n")+"\n\n" if ar1.size>0
  print "st=";p st
  #st=st.strip.gsub(/\n{3,}/,"\n\n")+"\n"
  #print "st=";p st
  cbd.setText(st)
  exit
elsif /b/=~opt #選択範囲（=分離）
  arr=arr.compact.uniq
  ar0=arr.grep(/^!+/).sortq;arr=arr-ar0.flatten;
  ar1=arr.grep_v(/^[^ ]*《[^#=《》]+》/).sortq
  ar2=arr.grep(/^[^ ]*《[^#=《》]+》/).sortq
  print "ar0=";p ar0
  print "ar1=";p ar1
  print "ar2=";p ar2
  st=[ar1,ar0,ar2].map{|e| e.map{|f| f.map{|g| g.join("\n")}.join("\n\n")}.
    join("\n\n")}.join("\n\n")
  st=st.strip.gsub(/\n{3,}/,"\n\n")+"\n"
  #print "st=";p st
  cbd.setText(st)
  exit
elsif /k/=~opt #選択範囲を漢字ごとに
  st=arr.compact.uniq.sort_by{|e| -e.size}.
    group_by{|e| e.sub(/([^\p{Han}]*)(\p{Han}*).*/){$2}}.
    to_a.transpose[1].to_a.map{|e| e.map{|f|
      f=f.gsub(%r|^[。、「『]|,"　").gsub(%r|(?<=[,])[。、「『]|,"　")
      t=[]
      t << f
      if /^　/=~f
        t << f.gsub(%r|^　|,"。").gsub(%r|(?<=[,/])　|,"。")
        t << f.gsub(%r|^　|,"「").gsub(%r|(?<=[,/])　|,"「")
        t << f.gsub(%r|^　|,"『").gsub(%r|(?<=[,/])　|,"『")
        t << f.gsub(%r|^　|,"、").gsub(%r|(?<=[,/])　|,"、")
        t << f.gsub(%r|^　|,"が").gsub(%r|(?<=[,/])　|,"が")
        t << f.gsub(%r|^　|,"は").gsub(%r|(?<=[,/])　|,"は")
        t << f.gsub(%r|^　|,"").gsub(%r|(?<=[,/])　|,"") if %r|k1|=~opt
      end
      print "t=";p t
      t}.uniq.join("\n")}.join("\n\n")+"\n"
  cbd.setText(st)
  exit
end


#重複要素
ar2=arr.select{|e| arr.count(e) > 1}.uniq
jfk= (ar2==[] ? "" : ar2.map{|e| "!"+e}.join("\n")+"\n\n")
arr=arr-ar2

#コメント１分離
ar2=arr.grep(%r|^#|)
com1= (ar2==[] ? "" : ar2.join("\n")+"\n\n")
arr=arr.grep_v(%r|^#|)

arr=arr.sort_by{|e|
  g=(/^([^ ]*?),/=~e ? $1 : e.chomp)
  g.bsize}.reverse

#b オプションを最初
ar2=arr.grep(/[^, ]*,b/).sort
bop= (ar2==[] ? "" : ar2.join("\n")+"\n\n")
arr=arr.grep_v(/[^, ]*,b/)

#s オプションを次に
ar2=arr.grep(/[^, ]*,s/).sort
sop= (ar2==[] ? "" : ar2.join("\n")+"\n\n")
arr=arr.grep_v(/[^, ]*,s/)

#10個ずつに分けて出力
#コメント２分離
#ar2=arr.grep(%r|^/|).sort.each_slice(10).to_a.map{|e| e.join("\n")}
ar2=arr.grep(%r|^/|).group_by{|e| e.match(/^(.*?),/).to_s.bsize}.to_a.sort_by{|e| -e[0].to_i}.
  transpose[1].to_a.map{|e| e.sort.reverse}.flatten.each_slice(10).to_a.map{|e| e.join("\n")}
com2= (ar2==[] ? "" : ar2.join("\n\n")+"\n\n")
arr=arr.grep_v(%r|^/|)

#要注意分離
#ar2=arr.grep(/^!+/).sort.sort_by{|e| e.match(/^!+/).to_s.bsize}.reverse.
ar2=arr.grep(/^!+/).sort_by{|e| e.match(/^!+[^,]+/).to_s.bsize}.reverse.
  each_slice(10).to_a.map{|e| e.join("\n")}
ex=(ar2==[] ? "" : ar2.join("\n\n")+"\n\n")
arr=arr.grep_v(/^!/)

#親文字のみ分離
ar2=arr.grep_v(/,/)
grp=ar2.group_by{|e| e.chomp.bsize}.to_a.transpose[1].to_a.map{|e| e.sort.reverse}.
  map{|e| e.each_slice(10).to_a.map{|f| f.join("\n")}.join("\n\n")}
#oya=(ar2==[] ? "" : grp.map{|e| e.join("\n")}.join("\n")+"\n\n")
oya=(ar2==[] ? "" : grp.join("\n")+"\n\n")
arr=arr.grep(/,/)

#pとrのオプションなし
ar2=arr.grep_v(%r|[^, ]*,[rpy]|)
ar3=ar2.group_by{|e| e.match(/^(.*?),/).to_s.bsize}.to_a.sort_by{|e| -e[0].to_i}.
  transpose[1].to_a.map{|e| e.sort.reverse}
wor=(ar2==[] ? "" : ar3.flatten.each_slice(10).to_a.map{|f| f.join("\n")}.join("\n\n")+"\n\n")
ar4=arr.grep(%r|[^ ]*,[rp]|)
ar5=arr.grep(%r|[^ ]*,y|)

#pとrのオプション付き
ar4=ar4.group_by{|e| e.match(/[^, ]*,([rp][0-9.]*)/)[1]}.to_a.
  sort_by{|e| e[0]}.sort_by{|e| e[0].scan(/[0-9.]+/)}.transpose[1].
  to_a.map{|e| e.group_by{|v| 1.0/(v.gsub(/,.*$/,"").bsize)}.to_a.
  transpose[1].to_a.map{|v| v.sort.reverse}}
reg=(ar4==[] ? "" : sep+
  ar4.map{|e| e.flatten.each_slice(10).to_a.map{|f| f.join("\n")}.
    join("\n\n")}.join("\n\n"+sep)+"\n\n")
arr=arr.grep(%r|[^ ]*,y|)

#yオプション付き
ar5=ar5.group_by{|e| e.match(/[^, ]*,(y[0-9.]*)/)[1]}.to_a.
  sort_by{|e| e[0]}.sort_by{|e| e[0].scan(/[0-9.]+/)}.transpose[1].
  to_a.map{|e| e.group_by{|v| 1.0/(v.gsub(/,.*$/,"").bsize)}.to_a.
  transpose[1].to_a.map{|v| v.sort.reverse}}
yop=(ar5==[] ? "" : sep+
  ar5.map{|e| e.flatten.each_slice(10).to_a.map{|f| f.join("\n")}.
    join("\n\n")}.join("\n\n"+sep)+"\n\n")

st=jfk+upd+com1+bop+sop+com2+ex+oya+wor+reg+yop

p st
cbd.setText(st)

__END__

