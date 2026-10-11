# encoding: utf-8
# calibre

Encoding.default_external = 'UTF-8'
require 'clipboard'

$stdout=open("tmp99.txt","w")
$stderr=open("tmp_err.txt","w")
cbd=ClipBoard.new(__ENCODING__)

st=cbd.getText
#p st

#外字変換
r1=%r<(龠《img[^》]+[0-9]+.(?:jpeg|gif)[^》]+》)>
bf1=st.scan(r1).flatten.uniq
ar1=bf1.map{|e|
  if /alt="([^〓])"/=~e
    s=$1;[e,"#{s}"]
  else
    i=e.match(/([0-9]+).(?:jpeg|gif)/)[0].to_i;[e,"≪龠#{i}≫"]
  end}
ar1.each{|e| st=st.gsub(e[0],e[1])}
ar1=ar1.map{|e| [e[0].gsub(/\"/){'\\"'},e[1]]}
print "ar1=";p ar1

#ルビ変換
ar2,ar3=[],[]
r2=%r|[\p{Han}]《ruby》|
bf2=st.scan(r2).flatten.uniq
bf2.each{|e| ar2<<[e,e.gsub(/《ruby》/,"｜《ruby》")]}
print "ar2=";p ar2

r3=%r|([｜]?《ruby》(?:.*?)《/ruby》)|
bf3=st.scan(r3).flatten.uniq
bf3.each{|e| e=e.gsub(/\"/){'\\"'};
  p rb=e.scan(%r|《rb》.*?《/rb》|).join.gsub(%r|《/?rb》|,"")
  p rt=e.scan(%r|《rt》.*?《/rt》|).join.gsub(%r|《/?rt》|,"")
  p rb=e.gsub(%r|《rt》.*?《/rt》|,"").gsub(%r|《/?ruby》|,"") if rb==""
  ar3 << [e,"｜"+e] if /[^\p{Han}]/=~rb && rb.size>1 && /^｜/!~e}
print "ar3=";p ar3

ar=(ar1+ar2+ar3).uniq
#ar=ar1.uniq
print "ar=";p ar

macro=open("tmp.mac","w:utf-8")
macro.print("\uFEFF")
macro.puts %|

begingroupundo;
selectall;copy;setsearch ".*" , 0x4003819;
colormarkerallfound 0x000000, 0xc2c79e, 11, 1;
disabledraw;
|
ar.each{|e|
  macro.puts %|replaceallfast "#{e[0]}" , "#{e[1]}" ;|}
macro.puts %|
#num=10;
while(#num){
replaceallfast "》([^《]+)《rt》([^《]+)《/rt》([^《]+)《rt》([^《]+)《/rt》《","》\\\\1\\\\3《rt》\\\\2\\\\4《/rt》《",regular;
#num=#num-1;
}
#num=5;
while(#num){
replaceallfast "《rb》([^《]+)《/rb》《rt》([^《]+)《/rt》《rb》([^《]+)《/rb》《rt》([^《]+)《/rt》","《rb》\\\\1\\\\3《/rb》《rt》\\\\2\\\\4《/rt》",regular;
#num=#num-1;
}
replaceallfast "《ruby》(?:《rb》)?([^《]+)(?:《/rb》)?《rt》([^《]+)《/rt》《/ruby》","\\\\1《\\\\2》",regular;

enabledraw;endgroupundo;gofiletop;endmacro;
|

__END__

