# encoding: utf-8
# convert

Encoding.default_external = 'UTF-8'
require 'clipboard'

require_relative 'clipboard_compat'
$stdout=open("tmp99.txt","w")
$stderr=open("tmp_err.txt","w")

cbd=ClipBoard.new(__ENCODING__)

#s :漢数字（小数点）
#k :漢数字（二桁）
#a :全角アラビア数字（小数点）
#y :=> を追加
#n :改行
#d :div削除
#a2:無変換
#at:青空文庫注釈除去
#ha:「は」を含むルビをカタカナに
#he:「へ」を含むルビをカタカナに
#ra:読みをルビ化
#rb:読みをルビ化（ルビ追加）

op=ARGV[0]

def convert_kansuji(text)
  text.tr('〇○一二三四五六七八九・、，','00123456789.,,')
    .gsub(/(\d+)?十(\d+)?/)  {  ($1||1).to_i*10+$2.to_i}
    .gsub(/(\d+)?百(\d+)?/)  {  ($1||1).to_i*100+$2.to_i}
    .gsub(/(\d+)?千(\d+)?/)  {  ($1||1).to_i*1000+$2.to_i}
    .gsub(/(\d+)万(\d+)?/)  {  $1.to_i*10000+$2.to_i}
    .gsub(/(\d+)億(\d+)?/)  {  $1.to_i*100000000+$2.to_i}
    .gsub(/(\d+)兆(\d+)?/)  {  $1.to_i*1000000000000+$2.to_i}
end

st=cbd.getText

if op=="ha"
  r=%r{(?:[^《》]《[^》]*》)*[^《》]《[^》]*は[^》]*》(?:[^《》]《[^》]*》)*}
  bf=st.scan(r).flatten.uniq.sort_by{|e| e.bytesize }.reverse #長い順に並べ替えて置換間違い防止
  ar=bf.map{|e| [e,e.tr('ぁ-ん','ァ-ン')]}
elsif op=="he"
  r=%r{(?:[^《》]《[^》]*》)*[^《》]《[^》]*へ[^》]*》(?:[^《》]《[^》]*》)*}
  bf=st.scan(r).flatten.uniq.sort_by{|e| e.bytesize }.reverse
  ar=bf.map{|e| [e,e.tr('ぁ-ん','ァ-ン')]}
elsif op=="y" #=>を追加
  arr=st.split("\r\n")
  bf=st.split("\r\n").grep_v(/^[#―]|^最終更新日：/).grep_v(/=>/).uniq.
    sort_by{|e| e.bytesize }.reverse.map{|e| e.gsub(/\\/,"\\\\\\")}
  ar=bf.map{|e| [e,e+" =>"]}
elsif op=="a"
  r=%r{([０-９]+[・．][０-９]+)}
  bf=st.scan(r).flatten.uniq.sort_by{|e| e.bytesize }.reverse
  ar=bf.map{|e| [e,e.tr("０-９・．","0-9..")]}
elsif op=="a2"
  ar=[]
elsif op=="at"
  r=%r|(［＃[^］]*］)|
  bf=st.scan(r).flatten.uniq.sort_by{|e| e.bytesize }.reverse
  ar=bf.map{|e| [e,""]}
elsif op=="s"
  r=%r{([一二三四五六七八九〇○十百千万億兆]+・[〇○一二三四五六七八九]+(?![\p{Han}]*《))}
  bf=st.scan(r).flatten.uniq.sort_by{|e| e.bytesize }.reverse
  ar=bf.map{|e| [e+"(?![亜-龠々]*《)",convert_kansuji(e)]}
elsif op=="k"
  r=%r{(?<![｜])([一二三四五六七八九〇○]+
    (?:[、，][一二三四五六七八九〇○]{3})+|[一二三四五六七八九〇○]{2,})(?![\p{Han}]*《)}
  bf=st.scan(r).flatten.uniq.sort_by{|e| e.bytesize }.reverse
  ar=bf.map{|e| [e+"(?![亜-龠々]*《)",convert_kansuji(e)]}
elsif op=="n" #改行置換
  st=st.gsub("\r","").gsub(/\n{2,}/m,"\n\n")
  cbd.setText(st)
  exit
elsif op=="d" #div削除
  ar=[["≪div [^≫]*≫[ ]?",""],["≪a href[^≫]*≫",""],["【】[ ]?",""]]
elsif /r/=~op #読みをルビ化
  bf=st.split("\r\n").grep(/!*([^ ,]+),([^ ,]+),([^ ,]+)/)
  print "st=";p st
  print "bf=";p bf
  ar=bf.map{|e|a,b,c="","",""
    if /!*([^ ,]+),(.*)$/=~e
      a,b=$1,$2
      if /([^ ,]+),([^ ,]+)/=~b
        b,c=$1,$2
      end
      print "abc=";p [a,b,c]
      c=b if /^[\+\-]/=~b and c==""
      c=b.gsub(/,$/,"") if /,$/=~b and c==""
      c=c.sub(/^,/,"")
      print "abc=";p [a,b,c]
      if /rb/=~op #読みをルビ化（ルビ追加）
        st=%Q|!#{e}\\n!#{a},#{a}《#{c}》 =>\\n| if c!=""
        print "st=";p st if c!=""
      else
        st=%Q|!#{e}\\n!#{a},#{a}《#{c}》 =>\\n| if c!=""
      end
    end
    print "e=";print e
    cbd.setText(st)
    [e.gsub("+","\\\\\\\\+"),st]
    }
  puts ""
  ar.map{|e|
    print "e0=";p e[0]
    print "e1=";p e[1]}
  #ar=ar.reverse
  #print "ar=";p ar
end

macro=open("tmp.mac","w:utf-8")
macro.print("\uFEFF")
macro.puts %|

begingroupundo;
disabledraw;
|
if /^[skd]/=~op
  ar.each{|e|
    macro.puts %|replaceallfast "#{e[0]}" , "#{e[1]}" ,regular;|}
elsif /r/=~op
  ar.each{|e|
    macro.puts %|replaceallfast "^#{e[0]}$" , "#{e[1]}" ,regular;|}
else
  ar.each{|e|
    macro.puts %|replaceallfast "#{e[0]}" , "#{e[1]}" ;|}
end
macro.puts %|
enabledraw;endgroupundo;endmacro;
|


__END__

本文を変換.mac
