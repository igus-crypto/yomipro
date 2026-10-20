# encoding: utf-8
# 青空文庫外字抽出

Encoding.default_external = 'UTF-8'

$stdout=open("tmp99.txt","w")
$stderr=open("tmp_err.txt","w")

require 'inifile'
require 'clipboard'

require_relative 'clipboard_compat'
ini=IniFile.load(__dir__+"/config.ini")
hide=ini["path"]["hide"]

cbd=ClipBoard.new(__ENCODING__)
st=cbd.getText

filename=ARGV[0]
fname=File.basename(filename)
print "fname=";p fname
a1,ar,hs,oya=st.split(%r|\R|),[],{},[]
print "a1=";p a1
ofs="tmp_g"
jis=open(__dir__+"/bat/aozora.csv").readlines.map{|e|e.chomp.split(%r|(?<!,),|)}.to_h
jis.transform_keys!{|k| k.split("-").map{|f|f.to_i}}
a1.each_with_index{|e,i|
  e.scan(/([^※［］]{,9})(※［＃[^］]+］)([^※［］]{,9})/).map{|f| p f
    m1,m2,m3=f if f
    d=m2.match(/(\d+)-(\d+)-(\d+)/).to_a.map{|e| e.to_i}[1..3]
    print jis[d]
    print "d=";p d
    #m2=m2.gsub(/水準/,"水準　")
    #ar<<"#{fname}:(#{i+1}):#{m1+m2+m3}" if m2
    if d && jis[d]
      key=m2+","+jis[d]+",s"
    else
      key=m2+",龠,s" #仮置き
    end
    oya << m2
    hs[key]="" unless hs[key]
    hs[key]+="#{fname}:(#{i+1}):#{m1+m2+m3}\n"
  }}
p hs
hs.each{|k,v| ar << k+"\n"+v}

num=1
while FileTest.file?(ofn=ofs + num.to_s + ".txt")
  num+=1
end
ofn=ofs+ num.to_s + ".txt"
File.write(ofn,ar.join("\n")+"\n")
print "ofn=";p ofn

t98a=[]
mac=File.expand_path("tmp.mac")
print "mac=";p mac
macro=open(mac,"w")
macro.print("\uFEFF")
#macro.puts %|openfile "#{ofile}",utf8;|
macro.puts %|
#color[ 1]=val("0x#{ini['color']['color_1']}");
#color[ 2]=val("0x#{ini['color']['color_2']}");
#color[ 3]=val("0x#{ini['color']['color_3']}");
#color[ 4]=val("0x#{ini['color']['color_4']}");
#color[ 5]=val("0x#{ini['color']['color_5']}");
#color[ 6]=val("0x#{ini['color']['color_6']}");
#color[ 7]=val("0x#{ini['color']['color_7']}");
#color[ 8]=val("0x#{ini['color']['color_8']}");
#color[ 9]=val("0x#{ini['color']['color_9']}");
#color[10]=val("0x#{ini['color']['color_10']}");
#color[11]=val("0x#{ini['color']['color_11']}");
#color[12]=val("0x#{ini['color']['color_12']}");
#color[13]=val("0x#{ini['color']['color_13']}");
#color[14]=val("0x#{ini['color']['color_14']}");
#color[15]=val("0x#{ini['color']['color_15']}");
#color[16]=val("0x#{ini['color']['color_16']}");
|

macro.puts %|
//openfile "#{ofn}",utf8;
//setsearch "(.*?):(\\\\(.*?\\\\)):(.*)" , 0x4003819;
//colormarkerallfound 0x000000, 0xc2c79e, 11, 1;;
setsearch ".*=>.*" , 0x4003819;
colormarkerallfound 0x000000, 0xc2c79e, 11, 1;;
setsearch "(.*?):(\\\\(.*?\\\\)):" , 0x4003819;
colormarkerallfound 0, 0xB2B2F5, 0, 0;

|

i=0
oya.each{|e|
  macro.puts %|setsearch "#{e}" , 0x4003809;|
  macro.puts %|colormarkerallfound 0x000000, #color[#{i%16+1}], 11, 1;|
  i+=1
}

macro.puts %|
gofiletop;enabledraw;save;endmacro;
|
macro.close

#spawn(%Q|"#{hide}" "#{ofn}"|)
spawn(%Q|"#{hide}" /fu8 /x "#{mac}" "#{ofn}"|)

__END__
