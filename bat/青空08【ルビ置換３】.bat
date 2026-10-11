rem 青空08【ルビ置換３】.bat
chcp 65001
cd /d %~dp0
ruby -x "%~f0"
exit

#/
#!ruby
# encoding: utf-8

$stdout=open("tmp_u8.log","w")
$stderr=open("tmp_eu8.log","w")

require 'inifile'

ini=IniFile.load(__dir__+"/aozora.ini")
dir=ini["path"]["list"]
arr=(open(dir+"/置換リスト10【チェック項目】.txt")).read.
  gsub(/\xEF\xBB\xBF|\xEF\xBF\xBE/,""). #BOM除去
  split(%r|\R|).reject{|e| %r|^#|=~e}.select{|e| %r|,[rpy]|=~e}.
  map{|e| e.gsub(/ .*/,"").gsub(/《(?=[ぁ-んァ-ヴー]+》)/,"《%").split(/,(?!\d*\})/)}.
  select{|e| /[pr](?![4-9])/=~e[2]}

print "arr=";p arr

# p       :                     〇〇                    (?![\p{Han}｜]*《)
# p[0-9]+1:                     〇〇                    (文頭)
# p[0-9]+2:                     〇〇                    (文末)
# p[0-9]+3:(?<![《ａ-ｚＡ-Ｚ》])〇〇(?![《ａ-ｚＡ-Ｚ》])
# p[0-9]+4:    (?<![《a-zA-Z》])〇〇(?![《a-zA-Z》])
# p[0-9]+5:   (?<![《\p{Han}》])〇〇                    (?![\p{Han}｜]*《)
# p[0-9]+6:                     〇〇(?![《\p{Han}｜》])
# p[0-9]+7:   (?<![《\p{Han}》])〇〇(?![《\p{Han}｜》])
# p[0-9]+8:                     〇〇                    (?![\p{Han}｜]*《)
# p[0-9]+9:                     〇〇
# rオプション
# r:/[\p{Han}]/で終わる場合、後ろの文字が /[\p{Han}]*《/なら処理しない

arr=arr.map{|e|
  if /p[0-9]*1$/=~e[2]
    #e=["(?<=[ァ-ヴー])"+e[0],e[1],e[2]]
    e=["(?<=[　。「」『』【】─])"+e[0],e[1],e[2]]
  elsif /p[0-9]*2$/=~e[2]
    #e=["(?<=[ァ-ヴー])"+e[0]+"(?![《\\p{Han}｜》])",e[1],e[2]]
    e=[e[0]+"(?=[、。」』】])",e[1],e[2]]
  elsif /p[0-9]*3$/=~e[2]
    e=["(?<![《ａ-ｚＡ-Ｚ》])"+e[0]+"(?![《ａ-ｚＡ-Ｚ》])",e[1],e[2]]
  elsif /p[0-9]*4$/=~e[2]
    e=["(?<![《a-zA-Z》])"+e[0]+"(?![《a-zA-Z》])",e[1],e[2]]
  elsif /p[0-9]*5$/=~e[2]
    e=["(?<![《\\p{Han}｜》])"+e[0],e[1],e[2]]
  elsif /p[0-9]*6$/=~e[2]
    e=[e[0]+"(?![《\\p{Han}｜》])",e[1],e[2]]
  elsif /p[0-9]*7$/=~e[2]
    e=["(?<![《\\p{Han}｜》])"+e[0]+"(?![《\\p{Han}｜》])",e[1],e[2]]
  elsif /p[0-9]*8$/=~e[2]
    #print "e012=";p [e[0],e[1],e[2]]
    e=["(?<![｜])"+e[0],e[1],e[2]] if /》$/!~e[1]
    e=["(?<![｜])"+e[0]+"(?!\\p{Han}+《|[^《》]+》)",e[1],e[2]] if /》$/=~e[1]
  elsif /p[0-9]*9$/=~e[2]
    e=["(?<![｜])"+e[0],e[1],e[2]]
  end
  e}.map{|e| #print "e=";p e;
    if /p[0-9]*[34]$/=~e[2]
      e
    elsif /》$/=~e[1] && /\p{Han}$/=~e[0]
      [e[0]+"(?![\\p{Han}｜]*《)",e[1],"r"]
    elsif /》$/=~e[1]
      [e[0]+"(?!《)",e[1],"r"]
    else
      [e[0],e[1],"r"]
    end}

#arr.map{|e| p e}

Dir.glob('**/*_u6.txt'){|file|
  f1=file.gsub(%Q|/|,%Q|\\\\|)
  f2=f1.gsub(%Q|_u6.txt|,%Q|_u8.txt|)
  s=open(file).read
  arr.map{|ar|
    a0=ar[0]
    #print "a0=";p a0
    s=s.gsub(%r|(.)(#{a0})|){
      m1,m2=$1,$2
      #print "ar=";p ar
      #print "m1=";p m1
      #print "m2=";p m2
      #print "a0=";p a0
      #print "a1=";p ar[1]
      if %r|^\p{Han}|=~m1 && %r|^\p{Han}*《|=~ar[1]
        #s1=(m1+m2).gsub(%r|(#{a0})|,ar[1]).insert(1,"｜")
        s1=(m1+ar[1]).insert(1,"｜")
      else
        s1=m1+m2
      end
      #print "s1=";p s1
      s1
      }.gsub(%r|#{a0}|,ar[1])}
  File.write(f2,s)}

__END__
:end
