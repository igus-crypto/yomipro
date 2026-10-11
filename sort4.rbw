# encoding: utf-8
# sort4
# 置換リストにコピペ　自動分配
Encoding.default_external = 'UTF-8'

#デバッグ用
$stdout=open("tmp_s99.txt","w")
$stderr=open("tmp_serr.txt","w")

require 'clipboard'
require 'inifile'

ini=IniFile.load(__dir__+"/config.ini")
hide=ini["path"]["hide"]

opt=ARGV[0]
#b:置換リストにコピペ　自動分配ＢＧ処理
#c:置換リストにコピペ　自動分配

class String
  def bsize
    self.to_s.tr("—","-").split("").map{|e| e.bytesize==1 ? 1 : 2}.sum
    #"—"が実は３バイトという罠回避 "-"は１バイト
  end
end


cbd=ClipBoard.new(__ENCODING__)
arr=cbd.getText.split("\r\n")

hs={}
hs["置換リスト01【直接置換】.txt"]=[]
hs["置換リスト02【ルビチェック】.txt"]=[]
hs["置換リスト03【数字関連】.txt"]=[]
hs["置換リスト04【五文字以上】.txt"]=[]
hs["置換リスト05【四文字】.txt"]=[]
hs["置換リスト06【三文字】.txt"]=[]
hs["置換リスト07【二文字以下】.txt"]=[]
hs["置換リスト08【パターン１】.txt"]=[]
hs["置換リスト09【パターン２】.txt"]=[]
hs["置換リスト10【チェック項目】.txt"]=[]
hs["置換リスト11【読み上げ】.txt"]=[]
hs["置換リスト12【最終チェック】.txt"]=[]
hs["置換リスト13【英数字チェック】.txt"]=[]

print "arr=";p arr
arr=arr.reject{|e| %r|^[ 　]*$|=~e}.grep_v(%r|^[\/]|).
  map{|e| e.gsub(%r|^[\!]+|,"")}.uniq.compact.delete_if(&:empty?)
print "arr=";p arr
arr=arr.map{|e|
  if (%r|,p16|=~e &&  %r|^[　。「」『』（）【】─※◇・]|=~e)
    e.gsub(%r|^[　。「」『』（）【】─※◇・]|,"(?<=[　。「」『』（）【】─※◇・])").gsub(%r|([,/])[　。「」『』（）【】─※◇・]|){$1}
  elsif %r|,[srpy]|=~e
    e
  elsif %r|^[　。「」『』（）【】─※◇・]|=~e
    e.gsub(%r|^[　。「」『』（）【】─※◇・]|,"").gsub(%r|([,/])[　。「」『』（）─※◇・]|){$1}.gsub(" ",",p11 ")
  elsif %r|^[^　。「」『』（）【】─※◇・][,]|=~e
    e.gsub(%r|[、。」』】](?=[, ])|,"").gsub(" ",",p12 ")
  else
    e
  end}.uniq
#print "arr=\n";arr.each{|e| puts e}

arr.each{|e|
  if /^,s=>$/=~e
  elsif /^[^, ]*$/=~e
    hs["置換リスト13【英数字チェック】.txt"] << e
  elsif /[^, ]*,s/=~e
    hs["置換リスト01【直接置換】.txt"] << e
  elsif /[^, ]*,y/=~e
    hs["置換リスト11【読み上げ】.txt"] << e
  elsif %r|《.*》|!~e && %r|=>|!~e
    hs["置換リスト02【ルビチェック】.txt"] << e
  elsif /[^, ]*,([rp]2)/=~e
    hs["置換リスト09【パターン２】.txt"] << e
  elsif /[^, ]*,([rp][3-9])/=~e
    hs["置換リスト10【チェック項目】.txt"] << e
  elsif /[^, ]*,([rp]1?)/=~e
    hs["置換リスト08【パターン１】.txt"] << e
  elsif /[0-9０-９一二三四五六七八九十百千万①②③④⑤⑥⑦⑧⑨⑩]/=~e.
    gsub(%r|,.*|,"").gsub(%r|\([^()]+\)|,"")
    hs["置換リスト03【数字関連】.txt"] << e
  elsif /^([^, ]*),/=~e
    mj=$1
    hs["置換リスト04【五文字以上】.txt"] << e if mj.size>=5
    hs["置換リスト05【四文字】.txt"] << e if mj.size==4
    hs["置換リスト06【三文字】.txt"] << e if mj.size==3
    hs["置換リスト07【二文字以下】.txt"] << e if mj.size<=2
  end}

hs=hs.reject{|k,v| v==[]}
print "hs=";p hs

if /b/=~opt
  txt=""
  hs.each{|k,v|
    print "v=";p v
    #v=v.sort.sort_by{|e| -e.gsub(/,.*/,"").bsize}
    v=v.sort.sort_by{|e| #オプション毎、長さ順に並べ替え
      [e.match(%r|(,[a-z0-9]+)|).to_a[0].to_s,-e.gsub(/,.*/,"").bsize]}
    #print "v=";p v
    #txt+=k+"\n"
    v.each_with_index{|e,i| txt+="#{k}(#{i+1}): #{e}\n"}
    txt+="\n"
    print "v=";p v
    st=v.join("\n")+"\n\n"
    k=__dir__+"/置換リスト/"+k
    st+=open(k).read.gsub(/\xEF\xBB\xBF|\xEF\xBF\xBE/,"") #BOM除去
    File.write(k,"\uFEFF"+st)
  }
  tmp=__dir__+"/置換リスト/tmp.txt"
  tmp=tmp.gsub("/","\\\\\\")
  File.write(tmp,"\uFEFF"+txt)
  mac=File.expand_path("tmp.mac")
  macro=open("tmp.mac","w")
  macro.print "\uFEFF"
  macro.puts %Q|setcompatiblemode 0x20030;|
  macro.puts %Q|if(findhidemaru("#{tmp}")==-1){openfile "#{tmp}";|
  macro.puts %Q|}else{closehidemaruforced findhidemaru("#{tmp}");openfile "#{tmp}";}|
  macro.puts %Q|setsearch "(.*?)(\\\\(.*?\\\\)): (.*)" , 0x4003819;|
  macro.puts %Q|colormarkerallfound 0x000000, 0xc2c79e, 11, 1;;|
  macro.puts %Q|setsearch "(.*?)(\\\\(.*?\\\\)): " , 0x4003819;|
  macro.puts %Q|colormarkerallfound 0, 0xB2B2F5, 0, 0;|
  #spawn(%Q|"#{hide}" /fu8 /x "#{mac}" "#{tmp}"|)
  exit
end


# 秀丸マクロ作成
macro=open("tmp.mac","w")
macro.print "\uFEFF"
macro.puts "setcompatiblemode 0x20030;"
hs.each{|k,v| 
  #next if v==[]
  print "v=";p v
  v=v.map{|e| e.gsub(/\\/,"\\\\\\")}.sort.sort_by{|e| -e.gsub(/,.*/,"").bsize}
  print "v=";p v
  k=__dir__+"/置換リスト/"+k
  macro.puts %|
if( findhidemaru("#{k}")==-1){openfile "#{k}";}
setactivehidemaru findhidemaru("#{k}");
gofiletop;begingroupundo;
|
  v.each{|e|
      macro.puts "insert \"#{e}\\n\";"
  }
  macro.puts "insert \"\\n\";"
  macro.puts "endgroupundo;enabledraw;"
}
macro.puts %|
gofiletop;goupdatedown;endmacro;
|

__END__
