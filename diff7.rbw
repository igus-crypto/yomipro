# encoding: utf-8
# diff7
# 差分チェック

Encoding.default_external = 'UTF-8'

$stdout=open("tmp99.txt","w")
$stderr=open("tmp_err.txt","w")

require 'clipboard'
require_relative 'clipboard_compat'
require 'diff/lcs'
require 'inifile'

ini = IniFile.load(__dir__+"/config.ini")
hide=ini["path"]["hide"]
cbd=ClipBoard.new(__ENCODING__)

i=1
while FileTest.file?(ofile="tmp_d"+sprintf("%#02d",i)+".txt")
  i+=1
end


f1=ARGV[0].encode(Encoding::UTF_8).gsub("\\","/")
f2=ARGV[1].encode(Encoding::UTF_8).gsub("\\","/")
a1=open(f1,'r:BOM|UTF-8').read.gsub(/\xEF\xBB\xBF|\xEF\xBF\xBE/,"").split(/\R/)
a2=open(f2,'r:BOM|UTF-8').read.gsub(/\xEF\xBB\xBF|\xEF\xBF\xBE/,"").split(/\R/)

of1=open("tmp_d1.txt","w")
of2=open(ofile,"w")
print "f1=";p f1
print "f2=";p f2

df1 = Diff::LCS.diff(a1,a2)
df2 = Diff::LCS.diff(a2,a1)
print "df1=";p df1
print "df2=";p df2

sa1,sb1,aa1,ab1,s,n0,n1,n2="","",[],[],"",0,0,0
n1,n2=0,0
df1.each{|d| ad,s1,s2,flg=[],"","",true;print "d=";p d
  d.each{|f| nd,na=0,0
    nd=nd-1 if f.deleting?
    na=na+1 if f.adding?
    n0=n0+nd+na
    print "n0=";p n0
    ad << f if f.deleting?
    if f.adding?
      s1 += "#{File.basename(f2)}:(#{f.position+1}):#{f.element}\n"
      print "ad=";p ad
      print "f=";p f
      asp=ad.find{|x| print "x,n0,f=";p [x.position,n0,f.position];x.position+n0==f.position}
      print "asp=";p asp
      print "f="; p f
    end
    }
  aa1 << s1
}
n0=0
df2.each{|d| ad,s1,s2,flg=[],"","",true;print "d=";p d
  d.each{|f| nd,na=0,0
    nd=nd-1 if f.deleting?
    na=na+1 if f.adding?
    n0=n0+nd+na
    print "n0=";p n0
    ad << f if f.deleting?
    if f.adding?
      print "ad=";p ad
      print "f=";p f
      asp=ad.find{|x|  print "x,n0,f=";p [x.position,n0,f.position];x.position+n0==f.position}
      s1 += "#{File.basename(f1)}:(#{f.position+1}):#{f.element}\n"
      print "asp=";p asp
      print "f="; p f
    end
    }
  ab1 << s1
}

print "aa1=";p aa1
print "ab1=";p ab1

# tmp_d1  =>ab1+aa1
# tmp_d01 =>ab2+aa2


ab1.each_with_index{|e,i| sa1+=e+aa1[i]+"\n"}
print "sa1=";p sa1
sa2=sa1.split("\n\n").map{|e| e.split("\n")}
print "sa2=";p sa2
sa2=sa2.map{|e| ac,ad=[],[]
  e.map{|f|
    if /#{File.basename(f1)}:[^:]+:(.*)/=~f
      ac<<$1
    elsif /#{File.basename(f2)}:[^:]+:(.*)/=~f
      ad<<$1
    end}
  print "ac=";p ac
  print "ad=";p ad
  e.map{|f|
    f=f.gsub(/(#{File.basename(f1)}:[^:]+:)(.*)/){$1+ad.shift} unless ad==[]
    f=f.gsub(/(#{File.basename(f2)}:[^:]+:)(.*)/){$1+ac.shift} unless ac==[]
    f
  }.join("\n")
}.join("\n\n")+"\n"
print "sa2=";p sa2
of1.print "\uFEFF#{sa1}"
of2.print "\uFEFF#{sa2}"
puts "--------"

#spawn("rubyw #{__dir__}/diff4.rbw tmp_d2.txt tmp_d1.txt")

ar1=("#{sa2}\n").split(/\R/)
ar2=("#{sa1}\n").split(/\R/)

print "ar1=";p ar1
print "ar2=";p ar2


#x:列 y:行 x0:x値保持 r:right l:文字長さ mp:文字列(+) mm:文字列(-)
ar3,ar4,x,y,x0,r,l,mp,mm=[],[],0,0,0,0,0,"",""
(0..ar1.size).each{|i|
  #if ar1[i]!=ar2[i] && ar1[i] && ar2[i]
  print "ar1[i]=";p ar1[i]
  print "ar2[i]=";p ar2[i]
  if ar1[i]!=ar2[i]
    #p i;p ar1[i];p ar2[i]
    #print i.to_s+":"
    begin
      sdiffs = Diff::LCS.sdiff(ar1[i],ar2[i])
    rescue
      print "ar1=";p ar1[i]
      print "ar2=";p ar2[i]
    end
    print "sdiffs=";p sdiffs
    sdiffs.each_with_index{|f,j|
      if f.new_element != f.old_element
        new=(f.new_element=="\\" ? "\\\\" : f.new_element)
        ar3<<[i,j,f.new_position,new,f.old_element]
      end}
  end}

ar3.each{|e|
  #print "e=";p e
  if e[0]==y #同一行
    if e[1]<=x+1 #文字が連続
      x+=1
      #r+=1 if e[3]
      l+=1 if e[4]
      mp+=e[3].to_s
      mm+=e[4].to_s
      #x0=x0+r-l
    else #文字が非連続
      ar4<<[y,x0,l,mp,mm]
      x,x0,mp,mm=e[1],e[2],e[3].to_s,e[4].to_s
      #r+=1 if e[3]
      l=(e[4] ? 1 :0)
    end
  else #行が変わると
    ar4<<[y,x0,l,mp,mm]
    x,y,x0,mp,mm=e[1],e[0],e[1],e[3].to_s,e[4].to_s
    #r=(e[3] ? 1 :0)
    l=(e[4] ? 1 :0)
  end  }
#ar4<<[y,x0,r,l,mp,mm]
ar4<<[y,x0,l,mp,mm]
ar4.map{|e| print "ar4=";p e}

# 秀丸マクロ作成
mac=File.expand_path("tmp.mac")
macro=open(mac,"w")
macro.print "\uFEFF"
macro.puts %|
setcompatiblemode 0x20030;
#hwnd = hidemaruhandle(0);
if( findhidemaru("#{ofile}")==-1){openfile "#{ofile}";}
setactivehidemaru findhidemaru("#{ofile}");
closehidemaruforced #hwnd;selectall;
colormarker 0x000000, 0xc2c79e, 11, 1;
setsearch "^([^:]*):([^:]*):" , 0x4003819;
colormarkerallfound 0, 0xB2B2F5, 0, 0;
escape;begingroupundo;disabledraw;\n|
# ar4⇒[[y,x0,l,mp,mm]‥‥]
ar4.each{|e| 
  move=(e[1]==0 ? %Q|moveto2 0,#{e[0]+1};| : %Q|moveto2 0,#{e[0]+1};right #{e[1]}|)
  if (e[3]=="" && e[4]!="") # 文字削除 #e[2]=>l  e[3]=>mp e[4]=>mm
    macro.puts %Q|#{move};beginsel;right #{e[2]};delete;backspace;undo;|
  elsif (e[3]!="" && e[4]!="") #文字変更
    macro.puts %Q|#{move};beginsel;right #{e[2]};insert "#{e[3]}";|
  elsif e[3]!="" #文字追加
    macro.puts %Q|#{move};insert "#{e[3]}";|
  end}
macro.puts %|
endgroupundo;gofiletop;enabledraw;goupdatedown;save;endmacro;\n|

spawn(%Q|"#{hide}" /h /fu8 /x "#{mac}"|)


__END__

差分チェック
