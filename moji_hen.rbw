# encoding: utf-8
# 文字変換
# moji_hen

Encoding.default_external = 'UTF-8'

$stdout=open("tmp99m.txt","w")
$stderr=open("tmp_errm.txt","w")

require 'clipboard'
require_relative 'clipboard_compat'
require 'romkan'

cbd = ClipBoard.new(__ENCODING__)
st=cbd.getText
#p st

class String
  def del_oya
    st=self.gsub(/｜([^《》]+)《[=#][^《》]*》/,'\1').gsub(/｜[^《》]+《([^《》]*)》/,'\1').
      gsub(/《[+%!]([^《》]*)》/,'《\1》').gsub(/([\p{Han}])(《[=#][^《》]*》)/,'\1').
      gsub(/([^\p{Han}])《[=#]([^《》]*)》/,'\1').gsub(/[\p{Han}]+《([^《》]*)》/,'\1').
      gsub(/.《([^《》]*)》/,'\1').gsub(/^《?([^《》]*)》/,'\1').gsub(/《[^《》]*$/,"")
  end
  def bsize
    self.to_s.tr("—","-").split("").map{|e| e.bytesize==1 ? 1 : 2}.sum
    #"—"が実は３バイトという罠回避 "-"は１バイト
  end
end

puts ARGV[0]
#  文字を変換
#h   :ひらがな変換
#k   :カタカナ変換
#y   :拗音変換
#t   :読点を半角
#e1  :半角英数（小文字→大文字）
#e2  :半角英数（大文字→小文字）
#e3  :半角数字除去
#e4  :半角数字－１
#r1y :テキスト読み上げ （廃止）
#r2  :ルビ分離
#r3  :空ルビ除去
#bc  :ボックス貼り付け
#ra  :「@」変換
#rc  :選択範囲をルビコピー
#ri  :ルビ入れ替え
#n   :数字付きを抜き出し
#z   :前後を削って連続複写
#o   :親文字削除
#oy  :テキスト読み上げ（親文字削除） （廃止）
#m   :置換元抜出し
#a   :読みをルビ化
#ap  :読みをルビ化（ルビを追加）
#j   :「=>」 除去
#b   :先頭の!除去
#k   :記号を半角
#ds  :「　」除去
#dk  :「。　、」除去
#ui  :「 _ 」挿入・除去（位置調整）
#s1  :《〇〇》
#s2  :（〇〇）
#s9  :【〇〇】
#s10 :文字列挿入〇〇《〇〇》

opt=ARGV[0]

if /^h/=~opt #ひらがな
  st=st.to_kana.tr("ァ-ン","ぁ-ん").gsub(%r|(?<=[《/])[ー]|,"-")
elsif /^k/=~opt #カタカナ
  st=st.to_kana.tr("ぁ-ん","ァ-ン").gsub(%r|(?<=[《/])[ー]|,"-")
elsif /^y/=~opt #拗音変換
  print "st=";p st
  st=st.tr("ぁぃぅぇぉっゃゅょあいうえおつやゆよァィゥェォッャュョアイウエオツヤユヨ",
    "あいうえおつやゆよぁぃぅぇぉっゃゅょアイウエオツヤユヨァィゥェォッャュョ").
    tr('a-zA-Z0-9ａ-ｚＡ-Ｚ-０-９','ａ-ｚＡ-Ｚ-０-９a-zA-Z0-9').
    #tr('\-\=－＝','－＝\-\=')
    #tr('-+*?<>()－＋＊？＜＞（）','－＋＊？＜＞（）-+*?<>()')
    tr('\-\=\+\*\?\<\>\(\)\#\-\/－＝＋＊？＜＞（）＃ー・','－＝＋＊？＜＞（）＃ー・\-\=\+\*\?\<\>\(\)\#\-\/')
  print "st=";p st
elsif /^s1/=~opt #《〇〇》
  st=("《"+st.gsub(/\R/,"》\n《")+"》").gsub(%r|\R《》$|,"\n")
elsif /^s2/=~opt #（〇〇）
  st=("（"+st.gsub(/\R/,"）\n（")+"）").gsub(%r|\R（）$|,"\n")
elsif /^s9/=~opt #【〇〇】
  st=("【"+st.gsub(/\R/,"】\n【")+"】").gsub(%r|\R【】$|,"\n").
    gsub(%r|【　+|,"【").
    gsub("【【","【").gsub("】】","】").
    gsub("【◇。◇。◇。】","◇。◇。◇。")
elsif /^t$/=~opt #読点を半角
  st=st.tr("、",",")
elsif /^g/=~opt #記号を半角
  st=st.tr("！＃＝＜＞（）／","!#=<>()/")
elsif /^e1/=~opt #半角英数（小文字→大文字） ""で囲まれた部分は処理しない
  st=st.gsub(/("[^"]*")?([^"]*)?/){$1.to_s+$2.to_s.tr("a-z","A-Z")}
elsif /^e2/=~opt #半角英数（大文字→小文字）
  st=st.gsub(/("[^"]*")?([^"]*)?/){$1.to_s+$2.to_s.tr("A-Z","a-z")}
elsif /^e3/=~opt #半角数字除去
  st=st.gsub(/[0-9]/,"")
elsif /^e4/=~opt #半角数字－１
  st=st.gsub(/([0-9]+)/){($1.to_i-1).to_s.gsub("0","")}
elsif /^ds/=~opt #「　」除去
  st=st.gsub(/[　]/,"")
elsif /^dk/=~opt #「。　、」除去
  st=st.gsub(/[。　、「」【】『』（）？！─‥]/,"")
elsif /^r1y/=~opt #テキスト読み上げ（ルビ無視）
  st=st.gsub(/ =>.*|,r|\\\d|\r/,"").gsub(/^[^:]*:\(\d+\):/,"").
    gsub(/｜([^《》]+)《[^》]*》/,'\1').gsub(/《[^》]*》/,"").split("\n").
    grep_v(/^\s+$|^$/).map{|e| e.size >= 75 ? e.gsub(/。/,"。\n") : e }.join("\n").
    split("\n").map{|e| e.size >= 75 ? e.gsub(/、/,"、\n") : e }.join("\n")+
    "\nこれにて終了"
  File.write("tmp_y.txt","\n\n\n"+st)
elsif /^r2/=~opt #ルビ分離
  arr=st.split("\r\n")
  arr=arr.map{|e| 
    s1=e.scan(/｜([^《》]+)《([^》]*)》/)
    e=e.gsub(/｜([^《》]+)《[^》]*》/,'\1')
    s2=e.scan(/([一-龠]+)《([^》]*)》/)
    #p s1+s2
    e=(s1+s2).join(",")+","+e.gsub(/《[^》]*》/,"")}
  st=arr.join("\n")+"\n"
elsif /^r3/=~opt #空ルビを除去
  st=st.gsub(/《》/,"")
elsif /^ri/=~opt #ルビ入れ替え
  arr=st.split("\r\n")
  arr=arr.map{|e|
    e.gsub(%r|,([^ ]*) //(.*) =>|,',\2 //\1 =>')}
  print "arr=";p arr
  st=arr.join("\n")
  print "st=";p st
elsif /^rc/=~opt #選択範囲をルビコピー
  arr=st.split("\r\n")
  flg,k1,c=true,"",[]
  #c1=arr.find{|e| %r|(《[^《》]*》)|=~e}.scan(%r|(《[^《》]*》)|).flatten
  arr=arr.map{|e|
    if /([\p{Han}]+|[^\p{Han}])(《[^《》]*》)/=~e
      k2=$1
      print "k2=";p k2
      print "e=";p e
      if flg or k1!=k2
        c=e.scan(%r|(《[^《》]*》)|).flatten
        flg=false
        k1=k2
      end
      e=e.scan(%r|([^《》]*)(《[^《》]*》)([^《》]*)|).
        map.with_index{|f,i| c[i]=c[i-1] unless c[i];f[0]+c[i]+f[2]}.join
    end
    e=e.gsub(%r|(《[^《》]*)\/-([^《》]*》)|,"\\1/=\\2")
    print "e=";p e
    if /=>$/=~e
      c2=e.split(%r([, ]|\/\/))
      print "c2=";p c2
      c2=e.split(%r([, ]|\/\/)).grep(%r|[《/][=#]|)[0].to_s
      print "c2=";p c2
      c2=c2.gsub(%r|《([=#][^\/]*)\/[^《》]*》|,"《\\1》").
        gsub(%r|《[^\/]*\/([=#][^《》]*)》|,"《\\1》")
      print "c2=";p c2
      c2=c2.to_s.gsub(/《[=#]/,"《").del_oya.gsub(%r|^[\/。、　「」─『』‥]+|,"").
        gsub(%r|[。、　「」『』【】‥─]$|,"").tr('ァ-ン','ぁ-ん')
      print "c2=";p c2
      c2=c2.to_kana
      print "c2=";p c2
      e=e.gsub(%r|[=#][^《》]*\/|,"").gsub(%r|\/[=#][^《》]*|,"")+c2
      e=e.gsub("=>=>","=>")
    else
       e=e.gsub(%r|[=#][^《》]*\/|,"").gsub(%r|\/[=#][^《》]*|,"")
       e=e.gsub("=>=>","=>")
    end
    flg=true if e==""
    e}
  print "arr=";p arr
  st=arr.join("\n")
  print "st=";p st
  st=st.gsub(%r|《=[a-z]+》|){|s| s.to_kana.tr("ぁ-ん","ァ-ン")}
  print "st=";p st
elsif /^bc/=~opt #ボックス貼り付け
  arg=ARGV[1].to_i
  st=st.chomp
  s2,n="",0
  st.each_char{|e| n+=e.size*2.0;s2+=e if n>arg;}
  s1=st.sub(s2,"")
  st=""
  "山川海陸カタガナひらがな".each_char{|e| st+=s1+e+s2+"\n"}
elsif /^ra/=~opt #「@」変換
  arr=st.split(/\R/)
  st=arr.map{|e| 
    if /@/=~e
      "山川海陸カタカナひらがな　".split("").map{|f| e.gsub(/@/,f)}
    else
      e
    end}.flatten.join("\n")+"\n"
elsif /^j/=~opt #=> 除去
  st=st.gsub(/ =>.*$/,"")+"\n"
elsif /^oy/=~opt #テキスト読み上げ
  st=st.gsub(/ =>.*|,r|\\\d|\r/,"").gsub(/^[^:]*:\(\d+\):/,"").
    gsub(/｜([^《》]+)《=[^《》]*》/,'\1').gsub(/｜[^《》]+《#([^《》]*)》/,'\1').
    gsub(/(《=[^《》]*》)/,'').gsub(/.《#([^《》]*)》/,'\1').
    gsub(/｜[^《》]+《([^《》]*)》/,'\1').gsub(/[\p{Han}]+《([^《》]*)》/,'\1').
    gsub(/.《([^《》]*)》/,'\1').gsub(/》/,"").split("\n").
    grep_v(/^\s+$|^$/).map{|e| e.size >= 75 ? e.gsub(/。/,"。\n") : e }.join("\n").
    split("\n").map{|e| e.size >= 75 ? e.gsub(/、/,"、\n") : e }.join("\n")+
    "\nこれにて終了"
  File.write("tmp_y.txt","\n\n\n"+st)
elsif /^o/=~opt #親文字削除
  st=st.del_oya
elsif /^n/=~opt #数字付きを抜き出し
  arr=st.split("\r\n")
  st="\n\n"
  arr.each{|e|
    if /^([0-9]+)?([^0-9].*[^0-9])([0-9]+)?$/=~e
      a,b,c=$1.to_i,$2,$3.to_i
      st+=e+"\n" if a+c>1 ;end}
elsif /^z/=~opt #前後を削って連続複写
  arr=st.split(/\R/)
  st=""
  arr=arr.map{|e| 
    if /@/=~e
      "山川海陸カタカナひらがな　".split("").map{|f| e.gsub(/@/,f)}
    else
      e
    end}.flatten
  arr.each{|e|
    if /^([0-9]+)?([^0-9].*[^0-9])([0-9]+)?$/=~e
      a,b,c=$1.to_i,$2,$3.to_i
      (a+1).times{|m| (c+1).times{|n|
        s2=b.split("")[m..-n-1]
        st+=(s2 ? s2.join+"\n" : "")}}
    else
      st+=e+"\n"
    end}
elsif /^m/=~opt #置換元抜出し
  st=st.gsub(/,.*$/,"")
elsif /^b/=~opt #先頭の!除去
  st=st.gsub(/^!+/,"").gsub(/\r\n!+/,"\r\n")
  print "st=";p st
elsif /^ui/=~opt #「 _ 」挿入・除去（位置調整）
  if %r|_|=~st.gsub(/\R/,"")
    st=st.gsub("_","")
  else
    arr=st.split(/\R/)
    ar5=st.split(/\n\s*\n/).map{|e| e.split(/\R/)}
    ar5=ar5.map{|c|
      ar1=c.map{|f| f.split(/([《》])/).each_slice(2).to_a}
      n2=ar1.map{|e| e.size}.max
      ar1=ar1.map{|e| (0..n2-1).map{|n| e[n] ? e[n] : ""}}
      n=ar1.transpose.to_a.map{|f| f.map{|t| t[0].to_s.bsize}.max}
      ar2=ar1.map{|e| e.map.with_index{|f,i|
          "_"*(n[i]-f[0].to_s.bsize)+f[0].to_s+f[1].to_s}}.
        map{|f| f.join.sub(/(》[^《》]*)$/){$1.gsub(/_+/,"")}}
      ar3=ar2.map{|e| e.gsub(/ =>.*/,"").bsize}
      n3=ar3.max
      ar2.map.with_index{|e,n| e.gsub(/( =>.*)/){"_"*(n3-ar3[n])+$1}}
    }
    st=ar5.map{|e| e.join("\n")}.join("\n\n")+"\n"
  end
end

print "op=";p opt
print "st=";p st
cbd.setText(st)

__END__

文字変換.mac
