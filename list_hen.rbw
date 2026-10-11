# encoding: utf-8
# リストの変換
# list_hen

Encoding.default_external = 'UTF-8'

require 'clipboard'

$stdout=open("tmp99.txt","w")
$stderr=open("tmp_err.txt","w")

cbd=ClipBoard.new(__ENCODING__)
arr=cbd.getText.split("\r\n")

p arr
puts ARGV[0]
#y1:拗音修正
#y2拗音修正を戻す
#r1:ルビ付きをチェック
#t :単語を正規表現に
#s :正規表現から単語に
#r2:ルビから読みに
#r3:ルビを振ってないところにルビ
#r4:ルビ付きを読みに（ルビチェックリストへ）
#rs:ルビソート

arr=arr.map{|e|
  if /y1/=~ARGV[0] #拗音修正
    if /(.*?),([^ ]*)([ ].*$)?/=~e
      o,r,c=$1,$2,$3
      c="" unless c
      st=r.tr("ぁぃぅぇぉっゃゅょァィゥェォッャュョ","あいうえおつやゆよアイウエオツヤユヨ")
      os,rs=o.size,r.size
      n=( os!=0 ? rs/os : 0)
      n=( n!=0 ? n : 1)
      oa=o.split("")
      ra=r.scan(/.{1,#{n}}/)
      st2=""
      #p "o=";puts o;p "r=";puts r;p "c=";puts c;p ra
      oa.each_with_index{|f,i|
        if i==oa.size-1
          st2=st2+f+"《#{ra[i..-1].join}》"
        else
          st2=st2+f+"《#{ra[i]}》"
        end}
      o+"《"+st+"》,"+st2+c
    else
      e  
    end
  elsif /y2/=~ARGV[0] #拗音修正を戻す
    if /(.*?),([^ ]*)([ ].*$)?/=~e
      o,r,c=$1,$2,$3
      c="" unless c
      #p "o=";p o+"\n";p "r=";p r+"\n";p "c=";p c+"\n"
      o=o.gsub(/《[^》]*》/,"")
      r=r.gsub(/[^《》]*《/,"").gsub(/》[^《》]*《/,"").gsub(/》/,"")
      o+","+r+c
    else
      e  
    end
  elsif /r1/=~ARGV[0] #ルビ付きチェック
    if /(.*?),([^ ]*)([ ].*$)?/=~e
      o,r,c=$1,$2,$3
      c="" unless c
      oa=o.split("")
      st1,st2="",""
      p "o=";puts o;p "r=";puts r;p "c=";puts c;p ra
      oa.each_with_index{|f,i|
        st2=st2+f+"(《[^》]*》)?"
        }
      st2+","+r+",r"+c
    else
      e  
    end
  elsif /t/=~ARGV[0] #単語を正規表現に
    if /(.*?),(.*?)([, ].*$)/=~e
      %|([^《一-龠》])#{$1}([^《一-龠》]),\\1#{$2}\\2,r#{$3}|
    elsif  /(.*?),(.*?)$/=~e
      %|([^《一-龠》])#{$1}([^《一-龠》]),\\1#{$2}\\2,r|
    else
      e
    end
  elsif /s/=~ARGV[0] #正規表現から単語に
    if /\(\[\^《一-龠》\]\)(.*?)\(\[\^《一-龠》\]\),\\1(.*?)\\2,r(.*)$/=~e
      %|#{$1},#{$2}#{$3}|
    elsif /\(\[\^《一-龠》\]\)(.*?)\(\[\^《一-龠》\]\),\\1(.*?)\\2,r$/=~e
      %|#{$1},#{$2}|
    else
      e
    end
  elsif /r2/=~ARGV[0] #ルビから読みに
    if /(.*?),([^ ]*)([ ].*$)?/=~e
      o,r,c=$1,$2,$3
      c="" unless c
      p r
      st=r.gsub(/》[^《]*《/,"").gsub(/[^《]*《/,"").gsub(/》[^》]*/,"")
      p st
      o+","+st+c
    else
      e
    end
  elsif /r3/=~ARGV[0] #ルビを振ってないところにルビ
    if /(.*?),([^ ]*)([ ].*$)?/=~e
      o,r,c=$1,$2,($3 ? $3 : "")
      os,rs=o.size,r.size
      n=( os!=0 ? rs/os : 0)
      n=( n!=0 ? n : 1)
      oa=o.split("")
      ra=r.scan(/.{1,#{n}}/)
      p r ;p oa ;p ra
      st=oa.join(%q|([^《])|)+%q|([^《]),|
      oa.each_with_index{|f,i|
        if i==oa.size-1
          st+=f+"《#{ra[i..-1].join}》"
        else
          st+=f+"《#{ra[i]}》" 
        end}
      p st
      st+ %q|\1,r| + ( c=="" ? "" : " "+c)
    else
      e
    end
  elsif /r4/=~ARGV[0] #置換リストから読みに（ルビチェックリストへ）
    if /([^ ]+),(?:[^ ]+《([^》]+)》)+/=~e
      #e.gsub(/《.*?》/,"")+","+e.scan(/《.*?》/).join.gsub(/[《》]/,"")
      e.gsub(/([^ ]+),(?:[^ ]+《([^》]+)》)+( .*)/){"#{$1},#{$2}"}
    else
      e
    end
  end}

#p arr
cbd.setText(arr.join("\n")+"\n")

__END__

