rem 青空02【注釈除去】.bat
chcp 65001
cd /d %~dp0
ruby -x "%~f0"
goto end

#/
#!ruby
# encoding: utf-8

#$stdout=open("tmp_u2.log","w")
$stderr=open("tmp_eu2.log","w")

h=open(__dir__+"/aozora.csv").readlines.map{|e|e.chomp.split(/(?<!,),/)}.to_h
h.transform_keys!{|k| k.split("-").map{|f|f.to_i}}

Dir.glob('**/*_u.txt'){|file|
  f1=file.gsub(%Q|/|,%Q|\\\\|)
  f2=f1.gsub(%Q|_u.txt|,%Q|_u2.txt|)
  s=open(file).read
  s=s.gsub(/(※［＃[^［］]*］)/){|e|
    if /((\d)-(\d+)-(\d+))/=~e
      n=$1.split("-").map{|e| e.to_i}
      e=h[n] if h[n]
    end
    e}.gsub(/(※?［＃[^［］]*］)/){|e|
    /^※/=~e ? "龠" : ""}
  File.write(f2,s)}


__END__

:end
