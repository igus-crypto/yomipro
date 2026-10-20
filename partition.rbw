# encoding: utf-8
# マッチしないのを分離
# partition

Encoding.default_external = 'UTF-8'

require "nkf"
require 'inifile'
require 'fileutils'
require 'clipboard'

require_relative 'clipboard_compat'
class String
  def tr2
    self.tr('ァ-ン','ぁ-ん').tr('ぁぃぅぇぉっゃゅょ','あいうえおつやゆよ')
  end
end

class String
  def bsize
    self.to_s.tr("—","-").split("").map{|e| e.bytesize==1 ? 1 : 2}.sum
    #"—"が実は３バイトという罠回避 "-"は１バイト
  end
end

class Array
  def p10
    if self[0].is_a?(Array)
      self.reject(&:empty?).map{|e| e.p10}
    else
      self.reject(&:empty?).group_by{|e| e.match(/^(.*?),/).to_s.bsize}.to_a.
        sort_by{|e| -e[0].to_i}.transpose[1].to_a.map{|e| e.sort}.flatten.
        each_slice(10).to_a.map{|e| e.join("\n")}.join("\n\n")
    end
  end
  def list_sort
    if self[0].is_a?(Array)
      self.reject(&:empty?).map{|e| e.list_sort}
    else
      arr,st=self,""
      sur=arr.grep(/^[\/]/).sort_by{|e| e.match(/^[\/]+[^\/]/).to_s.bsize}.reverse;arr=arr-sur
      exc=arr.grep(/^[\!]/).sort_by{|e| e.match(/^[\!]+[^\!]/).to_s.bsize}.reverse;arr=arr-exc
      #hik=arr.grep(/^[^\p{Han}, ]+,/);arr=arr-hik
      #print "sur=";p sur
      #print "exc=";p exc
      #print "hik=";p hik
      #print "arr=";p arr
      #[sur,exc,hik,arr]
      [sur,exc,arr]
    end
  end
end

ini=IniFile.load(__dir__+"/config.ini")
hide=ini["path"]["hide"]

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

$stdout=open("tmp_ms.txt","w")
$stderr=open("tmp_err_ms.txt","w")

cbd = ClipBoard.new(__ENCODING__)

file=filename=ini["grep"]["file_1"]
unless FileTest.file?(file)
  file=filename=ini["grep"]["file_2"]
  Dir.chdir(File.dirname(file))
end
file=File.expand_path(file)
fl=open(file).read

#出力ファイル準備
ofs,num="tmp",1
while FileTest.file?(ofn=ofs + num.to_s + ".txt")
  num+=1
end
ofn=File.expand_path(ofs+ num.to_s + ".txt")

arr=cbd.getText.split(/\R/).
  uniq.reject{|e| /^[#\/]|^[\s―]*$/=~e}
st,oya,ruby,com,rp=[],[],[],[],[]

exa=arr.grep(%r|^[\!]|).map{|e| "!"+e};arr=arr.grep_v(%r|^[\!]|)
print "arr=";p arr

arr.each_with_index{|line,i|
   line=line.gsub(/《[^《》]*》/){|s| s.gsub(" ","_spc_")}.
    gsub(/\[[^\[\]]*\]/){|s| s.gsub(" ","_spc_").gsub(",","_cmm_")}.
    gsub(/\{[^{}]*\}/){|s| s.gsub(" ","_spc_").gsub(",","_cmm_")}
  st[i],oya[i],ruby[i],rp[i],com[i]=
    /^([^,]*),?([^, ]*)?(,[rpy][0-9.]*)?(.*$)?/.match(line.chomp).to_a}
oya=oya.map{|e| e.sub(/^!+/,"")}.map{|e| e.gsub(/_spc_/," ").gsub(/_cmm_/,",")}
ruby=ruby.map{|e| e.gsub(/_spc_/," ").gsub(/_cmm_/,",")}
#print "oya=";p oya
#print "ruby=";p ruby


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
# オプション r:ルビ付き t:ルビ展開の時は除く


arr3=[]
arr2=arr.map.with_index{|e,i|
  s1,s2=oya[i],ruby[i]
  if /p\d*1$/=~rp[i]
    s1=(/[(\p{Han}｜)]$/=~s1 ? s1+"(?![\\p{Han}｜]*《)" : s1+"(?!《)")
    e="(?<=[ァ-ヴー])"+s1
  elsif /p\d*2$/=~rp[i]
    e="(?<=[ァ-ヴー])"+s1+"(?![《\\p{Han}｜》])"
  elsif /p\d*3$/=~rp[i]
    e="(?<![ａ-ｚＡ-Ｚ])"+s1+"(?![《ａ-ｚＡ-Ｚ])"
  elsif /p\d*4$/=~rp[i]
    e="(?<![a-zA-Z])"+s1+"(?![《a-zA-Z])"
  elsif /p\d*5$/=~rp[i]
    s1=(/[(\p{Han}｜)]$/=~s1 ? s1+"(?![\\p{Han}｜]*《)" : s1+"(?!《)")
    e="(?<![《\\p{Han}》])"+s1
  elsif /p\d*6$/=~rp[i]
    e=s1+"(?![《\\p{Han}｜》])"
  elsif /p\d*7$/=~rp[i]
    e="(?<![《\\p{Han}》])"+s1+"(?![《\\p{Han}｜》])"
  elsif /(^[^ ,]*),([^ ,]*),p\d*8$/=~rp[i]
    s1=(/[\p{Han}｜)]$/=~s1 ? s1+"(?![\\p{Han}｜]*《)" : s1+"(?!《)")
    e=s1
  elsif /p\d*9$/=~rp[i]
    e=s1
  elsif /y/=~rp[i]
    s1=s1.gsub("[^","[^《》")
    #print "s1=";p s1
    s1=(/[\p{Han}｜)]$/=~s1 ? s1+"(?![\\p{Han}｜]*《)" : s1+"(?!《)")
    e=s1
  elsif /r/=~rp[i]
    e=s1
  elsif /p/=~rp[i]
    s1=(/[\p{Han}｜)]$/=~s1 ? s1+"(?![\\p{Han}｜]*《)" : s1+"(?!《)")
    e=s1
  elsif rp[i]==nil
    s1=(/[\p{Han}｜)]$/=~s1 ? s1+"(?![\\p{Han}]*《)" : s1+"(?!《)")
    e=s1
  else
    e=s1
  end
  e}
print "arr=";p arr
print "arr2=";p arr2
arr.each_with_index{|e,i| print "arr[#{i}],arr2[#{i}]=";p [arr[i],arr2[i]]}
#p oya

arr2.each_with_index{|e,i|
  #oya=e[0]
  begin
    if fl.match?(%r|#{e}|) && /[《》]/!~fl.match(/#{e}/)[0] #マッチ部に「《》」を含まない
      arr3 << arr[i]
    else
      print "e=";p e
      print "arr[i]=";p arr[i]
      arr3 << "!"+arr[i]
    end
  rescue
    arr3 << arr[i]
  end}
#print "arr3=";p arr3

#exc=arr3.grep(/^[\!]/);arr3=arr3-exc
#hik=arr3.grep(/^[^\p{Han}, ]+,/);arr3=arr3-hik
print "exa=";p exa
#print "exc=";p exc
print "arr3=";p arr3
st=exa.list_sort.p10.join("\n")+"\n\n"+
#  exc.list_sort.join("\n")+"\n\n"+
  #hik.list_sort.join("\n")+"\n\n"+
  arr3.list_sort.p10.join("\n\n")
st=st.strip.gsub(/\n{3,}/,"\n\n")+"\n"
cbd.setText(st)
exit
__END__

マッチしないのを分離
