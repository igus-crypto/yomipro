#! ruby
# encoding: utf-8
# replace4
# grep結果の編集を置換

Encoding.default_external = 'UTF-8'

$stdout=open("tmp99.txt","w")
$stderr=open("tmp_err.txt","w")

require 'diff/lcs'
require 'clipboard'

require_relative 'clipboard_compat'
cbd=ClipBoard.new(__ENCODING__)

#オプション k:高速 y:ゆっくり
opt=(ARGV[1] ? ARGV[1] : "y")

# 差分の取得
print "argv=";p ARGV
bf=open(ARGV[0].encode(Encoding::UTF_8)).read.
  gsub(/\xEF\xBB\xBF|\xEF\xBF\xBE/,"").split(/\R/)
af=cbd.getText.
  gsub(/\xEF\xBB\xBF|\xEF\xBF\xBE/,"").split(/\R/)

ar1,ar2,arr=[],[],[]
diffs=Diff::LCS.diff(bf,af)

diffs.each{|hunk| hunk.each{|diff|
  ar1 << diff.element if diff.deleting?
  ar2 << diff.element if diff.adding?}}

# 連想配列に代入
hs={}
ar1.each{|e|
  fn1,ln1,txd=/([^:]*?)\(([^:]+?)\): (.*)/.match(e).to_a.values_at(1,2,3)
  ar2.each{|f|
    fn2,ln2,txa=/([^:]*?)\(([^:]+?)\): (.*)/.match(f).to_a.values_at(1,2,3)
    if fn1==fn2
      hs[fn2]=[] unless hs.has_key?(fn2)
      hs[fn2]<<[ln1,txd,txa] if ln1==ln2
    end
}}
hs=hs.reject{|k,v| k==nil}

# 文字単位で差分を取得
arr=arr.delete_if{|e| e[0]==nil}
#p arr
hss,ar3,ar4,ar5,arr2={},[],[],[],[]

hs.each{|k,v|
  hss[k]=[] unless hss.has_key?(k)
  v.each{|e|
    sdiffs=Diff::LCS.sdiff(e[1],e[2]) if e[1]
    sdiffs.each_with_index{|f,i|
      if f.new_element != f.old_element
        f.new_element=="\\" ? new="\\\\" : new=f.new_element
        hss[k]<<[e[0],f.new_position,new,f.old_element] 
      end}}}

# 秀丸マクロ作成
macro=open("tmp.mac","w")
macro.print %|\uFEFF|
macro.puts %|setcompatiblemode 0x20030;$dir=directory+"\\\\";|
macro.puts %|setcompatiblemode 0x20030;$dir=directory+"\\\\";|
hss.each{|k,v| kk=k.gsub(/\\/){'\\\\'}
  macro.puts %|if( findhidemaru($dir+"#{kk}")==-1){openfile $dir+"#{kk}";}|
  macro.puts %|setactivehidemaru findhidemaru($dir+"#{kk}");|
  macro.puts %|disabledraw;selectall;|
  macro.puts %|colormarker 0x000000, 0xc2c79e, 11, 1;|
  macro.puts %|escape;begingroupundo;|
  macro.puts %|enabledraw;| if /y/=~opt
  v.each{|e|
    m=0
    macro.puts %|moveto2 0,#{e[0]};|
    macro.puts %|right #{e[1]+m};| unless e[1]+m==0
    if e[3]
      macro.puts %|delete;|
      m=m-1
    end
    if e[2]
      macro.puts %|insert "#{e[2]}";|
      m=m+1 if e[3]
    end
  }
  macro.puts %|endgroupundo;enabledraw;|
}
macro.puts %|gofiletop;goupdatedown;endmacro;|

__END__
*/
