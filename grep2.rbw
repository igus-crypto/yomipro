# encoding: utf-8
# grep2
# 置換リストをgrep

Encoding.default_external = 'UTF-8'
require 'inifile'
require 'clipboard'

#デバッグ用
$stdout=File.open("tmp99.txt","w")
$stderr=File.open("tmp_err.txt","w")

ini=IniFile.load(__dir__+"/config.ini")
hide=ini["path"]["hide"]
mac=File.expand_path("tmp.mac")
cbd=ClipBoard.new(__ENCODING__)

sel=cbd.getText
p sel
st=""

Dir.chdir(__dir__+"/置換リスト")

i=1
while FileTest.file?(ofile="tmp_"+sprintf("%#02d",i)+".txt")
  i+=1
end

opt=ARGV[0]
# h :標準
# f :複数処理（五四三二）
# fs:複数処理（全て）
# fc:複数・ルビを除く
# c :除くチェックリスト
# m :マッチを探す
# s :正規表現

if /^m/=~opt #マッチを探す
  Dir.glob(__dir__+%Q|/置換リスト/置換リスト*.txt|){|f|
    p File.basename(f)
    open(f).readlines.each_with_index{|e,i|
      #p e
      begin
        if /^#/=~e
          next
        elsif /^([^,]*),?/ =~ e
          r=$1
          st+=File.basename(f)+"(#{i+1}): "+e if /#{r}/=~sel
        end
      rescue
        next
      end
    }
  }
elsif /^[hfc]/=~opt #標準・複数・ルビを除く
  word=sel.split("\r\n").map{|e| e.gsub(%r|^!+|,"")}.map{|e| e.gsub(%r|%|,"")}.
    reject{|e| e=="" or /^―+$/=~e or /^#/=~e}
  print "word=";p word
  hash={}
  if "f"==opt
    files=__dir__+%Q|/置換リスト/置換リスト0[1-7]*.txt|
  elsif /fc/=~opt
    files=__dir__+%Q|/置換リスト/置換リスト0[1-9]*.txt|
  else
    files=__dir__+%Q|/置換リスト/置換リスト*.txt|
  end
  print "files=";p files
  Dir.glob(files){|f| p f}

  Dir.glob(files){|f|
    next if /01【/=~f 
    hash[File.basename(f)]=open(f).read.split("\n")}
  word.each{|w| arr=[];hash.each{|k,v| v.each_with_index{|e,i|
    if /h/=~opt #標準
      arr << "#{k}(#{i+1}): #{e}\n" if e.include?(w)
    else
      arr << "#{k}(#{i+1}): #{e}\n" if /#{w.gsub(/,.*/,"")}/=~e
    end}}
    st+=(arr.size>0 ? "!#{w}\n"+arr.join+"\n" : "#{w}\n\n")}
  mc ="\uFEFF"
  mc+=%Q|#color[ 1]=val("0x#{ini['color']['color_1']}");\n|
  mc+=%Q|#color[ 2]=val("0x#{ini['color']['color_2']}");\n|
  mc+=%Q|#color[ 3]=val("0x#{ini['color']['color_3']}");\n|
  mc+=%Q|#color[ 4]=val("0x#{ini['color']['color_4']}");\n|
  mc+=%Q|#color[ 5]=val("0x#{ini['color']['color_5']}");\n|
  mc+=%Q|#color[ 6]=val("0x#{ini['color']['color_6']}");\n|
  mc+=%Q|#color[ 7]=val("0x#{ini['color']['color_7']}");\n|
  mc+=%Q|#color[ 8]=val("0x#{ini['color']['color_8']}");\n|
  mc+=%Q|#color[ 9]=val("0x#{ini['color']['color_9']}");\n|
  mc+=%Q|#color[10]=val("0x#{ini['color']['color_10']}");\n|
  mc+=%Q|#color[11]=val("0x#{ini['color']['color_11']}");\n|
  mc+=%Q|#color[12]=val("0x#{ini['color']['color_12']}");\n|
  mc+=%Q|#color[13]=val("0x#{ini['color']['color_13']}");\n|
  mc+=%Q|#color[14]=val("0x#{ini['color']['color_14']}");\n|
  mc+=%Q|#color[15]=val("0x#{ini['color']['color_15']}");\n|
  mc+=%Q|#color[16]=val("0x#{ini['color']['color_16']}");\n|
  mc+=%Q|\n|
  mc+=%Q|setsearch ".*?:" , 0x4003819;\n|
  mc+=%Q|colormarkerallfound 0x000000, #color[1], 11, 1;\n|
  mc+=%Q|\n|
  i=1
  word.each{|e|
    mc+=%Q|setsearch "#{e}" , 0x4003809;\n|
    mc+=%Q|colormarkerallfound 0x000000, #color[#{i%16+1}], 11, 1;\n|
    i+=1}
  mc+=%Q|gofiletop;enabledraw;save;endmacro;|
  File.write(mac,mc)
elsif /^s/=~opt #正規表現
  word=sel.split("\r\n").map{|e| e.gsub(/^!+/,"")}.
    reject{|e| e=="" or /^―+$/=~e}
  print "word=";p word
  hash={}
  files=__dir__+%Q|/置換リスト/置換リスト*.txt|
 
  print "files=";p files
  #Dir.glob(files){|f| p f}

  Dir.glob(files){|f|
    #next if /01【/=~f 
    #next if /02【/=~f && /c/=~ARGV[0]
    hash[File.basename(f)]=open(f).read.split("\n")}
  word.each{|w| ar1,ar2,m1,m2,m3=[],[],[],[],[];hash.each{|k,v| v.each_with_index{|e,i|
    if /#{w}/=~e
      ar2 << $&; m1 << $1 ;m2 << $2; m3 << $3
      ar1 << "#{k}(#{i+1}): #{e}\n"
    end}}
    print "ar1=";p ar1
    print "ar2=";p ar2
    if ar1.size>0
      st+="!#{w}\n"+ar1.join
      ar2=ar2.uniq.group_by{|e| e.size}.to_a.transpose[1].to_a.map{|e| e.sort}.flatten
      #print "ar2=";p ar2
      st+=ar2.join("\n")+"\n"
      #print "m1=";p m1
      #print "m2=";p m2
      #print "m3=";p m3
      m1=m1.compact.uniq.group_by{|e| e.size}.to_a.transpose[1].to_a.map{|e| e.sort}.flatten
      m2=m2.compact.uniq.group_by{|e| e.size}.to_a.transpose[1].to_a.map{|e| e.sort}.flatten
      m3=m3.compact.uniq.group_by{|e| e.size}.to_a.transpose[1].to_a.map{|e| e.sort}.flatten
      st+="[#{m1.join}]\n" if m1.size>0
      st+="[#{m2.join}]\n" if m2.size>0
      st+="[#{m3.join}]\n" if m3.size>0
      st+="\n"
    else
      st+="#{w}\n\n"
    end}
  mc ="\uFEFF"
  mc+=%Q|#color[ 1]=val("0x#{ini['color']['color_1']}");\n|
  mc+=%Q|#color[ 2]=val("0x#{ini['color']['color_2']}");\n|
  mc+=%Q|#color[ 3]=val("0x#{ini['color']['color_3']}");\n|
  mc+=%Q|#color[ 4]=val("0x#{ini['color']['color_4']}");\n|
  mc+=%Q|#color[ 5]=val("0x#{ini['color']['color_5']}");\n|
  mc+=%Q|#color[ 6]=val("0x#{ini['color']['color_6']}");\n|
  mc+=%Q|#color[ 7]=val("0x#{ini['color']['color_7']}");\n|
  mc+=%Q|#color[ 8]=val("0x#{ini['color']['color_8']}");\n|
  mc+=%Q|#color[ 9]=val("0x#{ini['color']['color_9']}");\n|
  mc+=%Q|#color[10]=val("0x#{ini['color']['color_10']}");\n|
  mc+=%Q|#color[11]=val("0x#{ini['color']['color_11']}");\n|
  mc+=%Q|#color[12]=val("0x#{ini['color']['color_12']}");\n|
  mc+=%Q|#color[13]=val("0x#{ini['color']['color_13']}");\n|
  mc+=%Q|#color[14]=val("0x#{ini['color']['color_14']}");\n|
  mc+=%Q|#color[15]=val("0x#{ini['color']['color_15']}");\n|
  mc+=%Q|#color[16]=val("0x#{ini['color']['color_16']}");\n|
  mc+=%Q|\n|
  mc+=%Q|setsearch ".*?:" , 0x4003819;\n|
  mc+=%Q|colormarkerallfound 0x000000, #color[1], 11, 1;\n|
  mc+=%Q|\n|
  i=1
  word.each{|e|e=e.gsub("\\","\\\\\\")
    mc+=%Q|setsearch "#{e}" , 0x4003809;\n|
    mc+=%Q|colormarkerallfound 0x000000, #color[#{i%16+1}], 11, 1;\n|
    mc+=%Q|setsearch "#{e}" , 0x4003810;\n|
    mc+=%Q|colormarkerallfound 0x000000, #color[#{i%16+1}], 11, 1;\n|
    i+=1}
  mc+=%Q|gofiletop;enabledraw;save;endmacro;|
  File.write(mac,mc)
end
p st
#cbd.setText(st)
File.write(ofile,st)
spawn(%Q|"#{hide}" /fu8 /x "#{mac}" "#{ofile}"|)

__END__


