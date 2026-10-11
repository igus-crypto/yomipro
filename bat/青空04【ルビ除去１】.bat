rem 青空04【ルビ除去１】.bat
chcp 65001
cd /d %~dp0
ruby -x "%~f0"
goto end

#/
#!ruby
# encoding: utf-8

$stdout=open("tmp_u4.log","w")
$stderr=open("tmp_eu4.log","w")

#t1=Time.now

require 'inifile'

class String
  def tr2
    self.tr('ァ-ン','ぁ-ん').tr('ぁぃぅぇぉっゃゅょ','あいうえおつやゆよ')
  end
end

ini=IniFile.load(__dir__+"/aozora.ini")
dir=ini["path"]["list"]
ha={}
open(dir+"/置換リスト02【ルビチェック】.txt").read.
  split(/\R/).each{|e|
    o,r,z=e.split(",",3)
    next unless o && r
    ha[[o,r]]=(z||"="+r)
    ha[[o,r.tr2]]=(z||"="+r.tr2) if r!=r.tr2
  }

Dir.glob('**/*_u3.txt'){|file|
  #file="" unless file
  f1=file.gsub(%Q|/|,%Q|\\\\|)
  f2=f1.gsub(%Q|_u3.txt|,%Q|_u4.txt|)
  s=open(file).read
  #s="" unless s
  s=s.gsub(%r|｜([^《》]+)《ヽ+》|){｜$1}.
    gsub(%r|([^《》])《ヽ》|){$1}.
    gsub(%r|(\p{Han}+)《ヽ+》|){$1}.
    gsub(%r|(｜?[\p{Han}]+)《([^《》]+)》|){|m|
      o,r=$1,$2
      q=o.gsub("｜","")
      a=m
      #print "a=";p a
      if t=ha[[q,r]]
        a="#{o}《#{t}》"
      end
      a
    }.
    gsub(%r|｜([^《。｜》]+)《[=]([^》]*)》|,'\1').
    gsub(%r|｜([\p{Han}]+)《[=]([^》]*)》|,'\1').
    gsub(%r|｜?([^\p{Han}])《([=][^》]*)》|,'\1').
    gsub(%r|《[=][^》]*》|,"")
  File.write(f2,s)}

#t2=Time.now
#p t2-t1

__END__
:end
