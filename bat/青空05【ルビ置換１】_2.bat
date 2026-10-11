rem 青空05【ルビ置換１】.bat
chcp 65001
cd /d %~dp0
ruby -x "%~f0"
goto end

#/
#!ruby
# encoding: utf-8

$stdout=open("tmp_u5.log","w")
$stderr=open("tmp_eu5.log","w")

t1=Time.now

require 'inifile'

ini=IniFile.load(__dir__+"/aozora.ini")
dir=ini["path"]["list"]
arr=(
  open(dir+"/置換リスト03【数字関連】.txt").read+
  open(dir+"/置換リスト04【五文字以上】.txt").read+
  open(dir+"/置換リスト05【四文字】.txt").read+
  open(dir+"/置換リスト06【三文字】.txt").read+
  open(dir+"/置換リスト07【二文字以下】.txt").read).split(%r|\R|).
  select{|e| %r|,|=~e}.reject{|e| %r|,[rpy]|=~e}.
  map{|e| e.gsub(/ .*/,"").gsub(/《(?=[ぁ-んァ-ヴー]+》)/,"《%").split(",")}.
  reject{|e| e.size==1}

#arr.each{|e| print "e=";p e}
ar2=arr.find_all{|e| %r|^\p{Han}*《|=~e[1] or %r|》$|=~e[1]}
ar1=arr-ar2
#ar1.each{|e| print "e1=";p e}
#ar2.each{|e| print "e2=";p e}

Dir.glob('**/*_u4.txt'){|file|
  f1=file.gsub(%Q|/|,%Q|\\\\|)
  f2=f1.gsub(%Q|_u4.txt|,%Q|_u5.txt|)
  s=open(file).read
  #print "arr=";p arr
  h1=ar1.group_by{|e,_| e.length}
  #hs.each{|k,v|
  #  print "k=";p k
  #  print "v=";p v
  #}
  h1.keys.sort.reverse.each{|i|
    h2=h1[i].to_h
    #print "h2=";p h2
    regex = Regexp.union(h2.keys)
    s=s.gsub(regex){|m| h2[m]}
#
#
#    h2.each{|k,v|
#      #print "k=";p k
#      #print "v=";p v
#      s=s.gsub(k,v)
#    }
  }
  ar2.map{|ar|
    s=s.gsub(/([^｜])(#{ar[0]})(?!\p{Han}*《)/){|e|
      m1,m2=$1,$2
      #print "[ar,m1,m2,e]=";p [ar,m1,m2]
      if /^\p{Han}/=~m1 && /^\p{Han}*《/=~ar[1]
        m1+"｜"+ar[1]
      else
        m1+ar[1]
      end
      }}
  File.write(f2,s)}

t2=Time.now
p t2-t1
__END__
:end
