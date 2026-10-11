rem 青空03【直接置換】.bat
chcp 65001
cd /d %~dp0
ruby -x "%~f0"
goto end

#/
#!ruby
# encoding: utf-8

$stdout=open("tmp_u3.log","w")
$stderr=open("tmp_eu3.log","w")

require 'inifile'

ini=IniFile.load(__dir__+"/aozora.ini")
dir=ini["path"]["list"]

print "list=";p dir+"/置換リスト01【直接置換】.txt"
arr=open(dir+"/置換リスト01【直接置換】.txt").read.
  gsub(/\xEF\xBB\xBF|\xEF\xBF\xBE/,""). #BOM除去
  split(%r|\R|).reject{|e| %r|^#|=~e}.
  select{|e| %r|,|=~e}.reject{|e| %r|,y|=~e}.
  map{|e| e.chomp.gsub(%r| .*|,"").split(%r|,(?![^{}]*})|)}

arr=arr.map{|e| #print "ee=";p e;
  if /s/=~e[2]
  elsif /p[0-9]*1$/=~e[2]
    #e=["(?<=[ァ-ヴー])"+e[0],e[1],e[2]]
    e=["(?<=[　。「『─])"+e[0],e[1],e[2]]
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
    if /p[0-9]*[34]$|s/=~e[2]
      e
    elsif /》$/=~e[1] && /\p{Han}$/=~e[0]
      [e[0]+"(?![\\p{Han}｜]*《)",e[1],"r"]
    elsif /》$/=~e[1]
      [e[0]+"(?!《)",e[1],"r"]
    else
      [e[0],e[1],"r"]
    end}

#arr.map{|e| print "e=";p e}

Dir.glob('**/*_u2.txt'){|file|
  f1=file.gsub(%Q|/|,%Q|\\\\|)
  f2=f1.gsub(%Q|_u2.txt|,%Q|_u3.txt|)
  s=open(file).read.
    gsub(/\xEF\xBB\xBF|\xEF\xBF\xBE/,"").
    gsub(/\n{2,}/,"\n\n")
  s="◇。◇。◇。\n"+s unless %r|^◇。◇。◇。|=~s
  arr.map{|ar| #print "ar=";p ar
    if /{([^,]*),([^,]*),tr}/=~ar[1]
      m1,m2=$1,$2
      s=s.gsub(%r|#{ar[0]}|){|e| e.tr(m1,m2)}
    elsif /s/=~ar[2]
      s=s.gsub(ar[0],ar[1])
    elsif ar[3]
      s=s.gsub(%r|#{ar[0]}|,ar[1])
    else
      s=s.gsub(/([^｜])(#{ar[0]})(?!\p{Han}*《)/){|e|
        m1,m2=$1,$2
        if /^\p{Han}/=~m1 && /^\p{Han}*《/=~ar[1]
          m1+"｜"+ar[1]
        else
          m1+ar[1]
        end}
    end}
  s=s.gsub("◇。◇。◇。◇。◇。\n◇。◇。◇。◇。◇。\n","◇。◇。◇。◇。◇。\n")
  File.write(f2,"\uFEFF"+s)}

__END__
:end
