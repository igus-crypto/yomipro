# encoding: utf-8
# sort2
# ルビを分離

Encoding.default_external = 'UTF-8'


$stdout=open("tmp_s99.txt","w")
$stderr=open("tmp_serr.txt","w")

require 'clipboard'

cbd=ClipBoard.new(__ENCODING__)
arr=cbd.getText.split("\r\n")

#p arr
class String
  def bsize
    self.to_s.tr("—","-").split("").map{|e| e.bytesize==1 ? 1 : 2}.sum
    #"—"が実は３バイトという罠回避 "-"は１バイト
  end
end

class Array
  def each_s(n)
    self.group_by{|e| e.match(/^(.*?),/).to_s.bsize}.to_a.sort_by{|e| -e[0].to_i}.
      transpose[1].to_a.map{|e| e.sort}.flatten.each_slice(n).
      to_a.map{|e| e.join("\n")}.join("\n\n")
    #self.each_slice(n).to_a.map{|e|e.join("\n")}.join("\n\n")+"\n"
  end
end

p ARGV[0]
#n:出現回数でソート"
#k:カタカナルビを分離"
#y:拗音を含むルビを分離"
#s:冒頭が // を分離"
#e:冒頭が ! を分離"
#b:傍点を分離"
#m:-と+と#と漢字付きを分離"
#r:ルビの/を分離"
#c:コメント付き分離
#h:非漢字分離"

arr=arr.grep_v(/^$|^最終更新日：/)
st="最終更新日：#{Time.new.strftime("%Y.%m.%d")}\n\n"
if "n"==ARGV[0] #出現回数でソート
  g=arr.group_by{|e| /\,([\d]+)$/=~e ? $1.to_i : 0}.
    sort_by{|k,v| k}.reverse
  arr,st=[],""
  g.each{|k,v| st+=v.join("\n")+"\n\n"}
elsif "k"==ARGV[0] #カタカナルビを分離
  kana=arr.grep(/\,([^《》 ]*《)?[ァ-ヴー]/)
  arr=arr.grep_v(/\,([^《》 ]*《)?[ァ-ヴー]/)
  st+=kana.each_s(10)+"\n\n" unless kana==[]
  st+=arr.each_s(10)+"\n\n" unless arr==[]
elsif "y"==ARGV[0] #拗音を含むルビを分離
  you=arr.grep(/\,.*[ぁぃぅぇぉっゃゅょァィゥェォッャュョ]/)
  arr=arr.grep_v(/\,.*[ぁぃぅぇぉっゃゅょァィゥェォッャュョ]/)
  st+=you.each_s(10)+"\n\n" unless you==[]
  st+=arr.each_s(10)+"\n\n" unless arr==[]
elsif "s"==ARGV[0] #冒頭が // を分離
  sura=arr.grep(/^\/\//)
  arr=arr.grep_v(/^\/\//)
  st=sura.each_s(10)+"\n\n" unless sura==[]
  st+=arr.each_s(10)+"\n\n" unless arr==[]
elsif "e"==ARGV[0] #冒頭が ! を分離
  exc=arr.grep(/^\!/)
  arr=arr.grep_v(/^\!/)
  st+=exc.each_s(10)+"\n\n" unless exc==[]
  st+=arr.each_s(10)+"\n\n" unless arr==[]
elsif "b"==ARGV[0] #傍点を分離
  bou=arr.grep(/\,[ヽ丶]+$/)
  arr=arr.grep_v(/\,[ヽ丶]+$/)
  st+=bou.each_s(10)+"\n\n" unless bou==[]
  st+=arr.each_s(10)+"\n\n" unless arr==[]
elsif "m"==ARGV[0] #-と#を分離
  arr=arr.uniq
  sur=arr.grep(/^\//);arr=arr-sur
  exc=arr.grep(/^\!/);arr=arr-exc
  bou=arr.grep(/ヽ/) ;arr=arr-bou
  mai=arr.grep(/[-]/);arr=arr-mai
  pur=arr.grep(/[+]/);arr=arr-pur
  shr=arr.grep(/[#]/);arr=arr-shr
  kan=arr.grep(/^[^, ]+,[^ ]*[\p{Han}]/);arr=arr-kan
  kat=arr.grep(/^[^, ]+,[^ ]*[ァ-ヴー]/);arr=arr-kat
  st+=sur.each_s(10)+"\n\n" unless sur==[]
  st+=exc.each_s(10)+"\n\n" unless exc==[]
  st+=bou.each_s(10)+"\n\n" unless bou==[]
  st+=mai.each_s(10)+"\n\n" unless mai==[]
  st+=pur.each_s(10)+"\n\n" unless pur==[]
  st+=shr.each_s(10)+"\n\n" unless shr==[]
  st+=kan.each_s(10)+"\n\n" unless kan==[]
  st+=kat.each_s(10)+"\n\n" unless kat==[]
  st+=arr.each_s(10)+"\n\n" unless arr==[]
elsif "r"==ARGV[0] #ルビの/を分離
  rus=arr.grep_v(/^\/\//).grep_v(/^\!/).grep(/《[^》]*\/[^》]*》/)
  arr=arr-rus
  st+=rus.each_s(10)+"\n\n" unless rus==[]
  st+=arr.each_s(10)+"\n\n" unless arr==[]
elsif "g"==ARGV[0] #ひらがなルビを分離
  hir=arr.grep(/\,[ぁ-ん]+$/)
  arr=arr.grep_v(/\,[ぁ-ん]+$/)
  st+=hir.each_s(10)+"\n\n" unless hir==[]
  st+=arr.each_s(10)+"\n\n" unless arr==[]
elsif "c"==ARGV[0] #コメント付き分離
  sur=arr.grep(/^\/\//)
  arr=arr.grep_v(/^\/\//)
  com=arr.grep(/=>[^ ]+/)
  arr=arr.grep_v(/=>[^ ]+/)
  st+=com.each_s(10)+"\n\n\n" unless com==[]
  st+=sur.each_s(10)+"\n\n\n" unless sur==[]
  st+=arr.each_s(10)+"\n" unless arr==[]
elsif "h"==ARGV[0] #非漢字分離
  sura=arr.grep(/^\/\//)
  arr=arr.grep_v(/^\/\//)
  exc=arr.grep(/^\!/)
  arr=arr.grep_v(/^\!/)
  hik=arr.grep(/^[^一-龠, ]+,/)
  arr=arr.grep_v(/^[^一-龠, ]+,/)
  st=st+sura.join("\n")+"\n\n" unless sura==[]
  st=st+exc.join("\n")+"\n\n" unless exc==[]
  st=st+hik.join("\n")+"\n\n" unless hik==[]
  st=st+arr.each_s(10)+"\n" unless arr==[]
end

cbd.setText(st)

__END__

