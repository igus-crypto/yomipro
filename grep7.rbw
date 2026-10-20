# encoding: utf-8
# grep7
# 読み上げチェック

Encoding.default_external = 'UTF-8'

require 'open3'
require 'inifile'
require 'win32ole'
require 'clipboard'

require_relative 'clipboard_compat'
$stderr=open("tmp_err.txt","w")
$stdout=open("tmp99.txt","w")

opt=ARGV[0]
#n:ノーマル
#t:ルビ展開
#b:ルビ置換前
print "opt=";p opt

ini=IniFile.load(__dir__+"/config.ini")
chek=ini["grep"]["check"]

cbd = ClipBoard.new(__ENCODING__)

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

puts Dir.pwd.encode(Encoding::UTF_8)
#p soro
print "chek=";p chek

class String
  def tr2
    self.gsub(/^[+=]/,"").tr('ァ-ン','ぁ-ん').
      tr('ぁぃぅぇぉっゃゅょ','あいうえおつやゆよ')
  end
  def del_oya
    st=self.gsub(/｜([^《》]+)《[=#][^《》]*》/,'\1').gsub(/｜[^《》]+《([^《》]*)》/,'\1').
      gsub(/《[+%!]([^《》]*)》/,'《\1》').gsub(/([\p{Han}])(《[=#][^《》]*》)/,'\1').
      gsub(/([^\p{Han}])《[=#]([^《》]*)》/,'\1').gsub(/[\p{Han}]+《([^《》]*)》/,'\1').
      gsub(/.《([^《》]*)》/,'\1').gsub(/^《?([^《》]*)》/,'\1').gsub(/《[^《》]*$/,"")
  end
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

ls=cbd.getText.split(/\R/)

mtc,oya,rub,rb2,com,rp=[],[],[],[],[],[]
ls.each_with_index{|line,i|
  mtc[i],oya[i],rub[i],rb2[i]=/^([!+]?[^,]*),?([^, ]*)?,?([^, ]*)?/.match(line.chomp).to_a}

oya2=oya.map{|e| e+"《(?:[^《》]+)》"}
#  rb2=rb2.map.with_index{|e,i| e=rub[i] if e=="" ; e}
if /^t/=~opt
  rb2=rub.map.with_index{|e,i| /^=/=~e ? oya[i] : e}
elsif /^b/=~opt
  rb2=rb2.map{|e| e=""}
end

print "oya=";p oya
print "oya2=";p oya2
print "rub=";p rub
print "rb2=";p rb2
kk,mt=[],[]
fname=File.basename(filename)
#fl=open(filename).readlines
st=open(filename).read
st="◇"*15+st+"◇"*15

#マッチの結果を kk に突っ込んでいく
kk=[]
oya2.each_with_index{|s,i|
  next if rub[i]==""
  tb=[]
  #print "s=";p s
  aor=st.scan(/#{s.gsub(/^!+/,"")}/).uniq.select{|t|
    t.gsub(/.*《([^=]*)》/){$1}.tr2==rub[i].tr2}
  print "aor=";p aor
  aor.map{|e| 
    st.scan(/(.{7}[^\p{Han}])(#{e.gsub("《+","《\\\\\+")})(.{8})/m){|t|
      print "t=";p t
      m1,m2,m3=t[0],t[1],t[2]
      m1=m1.gsub(/.*\n/,"").gsub(/^([^《》]+)》/){$1}.
        gsub(/(?<!｜)([^\p{Han}]+)(?=[^\p{Han}]《)/,"").
        gsub(/｜$/,"").gsub(/《+/,"《")
      m3=m3.gsub(/(?<=[、。])(.*)/,"").gsub(/\n.*/,"").
        gsub(/(^[\p{Han}]+《)/){"｜"+$1}.gsub(/《[^《》]+$/,"").gsub(/《+/,"《")
      m3=" "+m3 if /^｜?[\p{Han}]+《/=~m3
      if /《([^《》]+)》/=~m2
        s1=$1
        oy=oya[i].gsub(/^[!]+/,'')
        print "rub[i]=";p rub[i]
        print "s1=";p s1
        print "oy=";p oy
        print "m2=";p m2
        if /^[t]/=~opt
          if rub[i]===s1 and oy===m2.gsub(/《.*》/,"")
            rb=(rb2[i]=="" ? rub[i] : "#{rb2[i]}")
            print "rb=";p rb
            hdr=(chek==1 ? "" : "#{oya[i]},#{rub[i]}◆　")
            if rb2[i]=="" and /^\+/!~rub[i]
              kk << hdr+m1+oy+m3
            else
              kk << hdr+m1+rb+m3
            end
          end
        else
          if rub[i].tr2===s1.tr2 and oy===m2.gsub(/《.*》/,"")
            rb=(rb2[i]=="" ? rub[i] : "#{rb2[i]}")
            print "rb=";p rb
            hdr=(chek==1 ? "" : "#{oya[i]},#{rub[i]}◆　")
            if rb2[i]=="" and /^\+/!~rub[i]
              kk << hdr+m1+oy+m3
            else
              kk << hdr+m1+rb+m3
            end
          end
        end
      end
      }
    }
  }
#kk=kk.map{|e| e.gsub(/[#+｜=]/,"")}
kk=kk.map{|e| e.gsub(/[#+｜=]/,"").del_oya.gsub(/^%/,"")}
print "kk=";p kk

ofl.puts kk.each_slice(10).to_a.map{|e|e.join("\n")}.join("\n\n")+"\n"


ofl.close
mac=File.expand_path("tmp.mac")
macro=open(mac,"w")
macro.print("\uFEFF")
macro.puts %|openfile "/h #{ofile}",utf8;endmacro;|
macro.close

__END__

