# encoding: utf-8
# replace
# 置換実行

Encoding.default_external = 'UTF-8'

require 'clipboard'
require_relative 'clipboard_compat'
require 'win32ole'
require 'inifile'
require 'diff/lcs'

$stdout=open("tmp99.txt","w")
$stderr=open("tmp_err.txt","w")

opt=ARGV[0] 
#s:スタンダード 
#r1:ルビ付き・単語
#r2:ルビ付き・正規表現  旧 r：ルビを消して置換 
p opt

ini = IniFile.load(__dir__+"/config.ini")
hide=ini["path"]["hide"]
cbd = ClipBoard.new(__ENCODING__)


file_1=File.expand_path(ini["grep"]["file_1"])

if FileTest.file?(file_1)
  filename=file_1
else
  file_2=File.expand_path(ini["grep"]["file_2"])
  if FileTest.file?(file_2)
    filename=File.expand_path(file_2)
    Dir.chdir(File.dirname(filename))
  else
    wsh = WIN32OLE.new('WScript.Shell')
    a=wsh.Popup("次のファイルがありません\n\n"+
      "#{file_1}\n#{file_2}",0,"注意",0)
    exit
  end
end


class String
  def rep(arr) #replace
    ar,ss=[],self
    ar1=arr.select{|e| /s/=~e[2]}
    ar1.map{|e| ss=ss.gsub(e[0],e[1])}
    arr=arr-ar1
    ss=ss.split("\n").map{|st|
      arr.map{|e|
        st.scan(/#{e[0]}/){
          x,y,z=$`,$&,$'
          x=(x[-3,3]||x).gsub(/.*[!?]/,"")
          z=(z[0,8]||z).to_s.gsub(/([、。])(.*)/,"\\1").gsub(/[!?].*/,"").chomp
          a=[x,y,z] #前３後８文字取り出し
          #print "a=";p a
          print "e[1]=";p e[1]
          e[1]=e[1].gsub(/(?<!['])(,)/){'__cmm__'}
          #print "e[1]=";p e[1]
          if /^{.*}$/=~e[1]
            if /{'([^{}]+)','([^{}]+)',([a-z]+)?}/=~e[1].gsub(/__cmm__/,",") #ブロックへ渡す
              e1,e2,e3=[$1,$2,$3]#.map{|f| f.gsub(/__cmm__/,",")}
              print "e123=";p [e1,e2,e3]
            else 
              e[1]=e[1].gsub(/__cmm__/,",")
              if /{'([^{}]+)','([^{}]+)',([a-z]+)?}/=~e[1]
                e1,e2,e3=$1,$2,$3
                print "e123=";p [e1,e2,"r"]
              end
            end
            if /tr/=~e3
              print "a=";p a
              #b=a[0]+a[1].gsub(/#{e[0]}/){|s| s.tr(e1,e2)}+a[2]
              b=a[0]+a[1].gsub(/#{a[1]}/){|s| s.tr(e1,e2)}+a[2]
              print "b=";p b
            else
              #b=a.join.gsub(/#{e[0]}/){|s| s.gsub(/#{e1}/,"#{e2}")}
              b=a.join.gsub(/#{e[0]}(?![\p{Han}]*《|《)/){|s| s.gsub(/#{e1}/,"#{e2}")}
            end
          else
            e[1]=e[1].gsub(/__cmm__/,",")
            b=a.join.gsub(/#{e[0]}/,"#{e[1]}")
          end
          print "a.size=";p a.size
          print "a[0][-1]=";p a[0][-1]
          print "a[1]=";p a[1]
          print "a=";p a
          print "b[a[0].size..-1]=";p b[a[0].size..-1]
          if /s/=~e[2]
            b=a[0]+b[a[0].size..-1]
          elsif /([\p{Han}]+)/=~a[0][-1] && /(^[\p{Han}]+《[#])/=~b[a[0].size..-1]
            b=a[0]+b[a[0].size..-1]
          #elsif /([\p{Han}]+)/=~a[0][-1] && /(^[\p{Han}]+《)/=~b[a[0].size..-1]
          #  b=a[0]+"｜"+b[a[0].size..-1]
          #elsif a.size==3 && /([\p{Han}]+)/=~a[0][-1] && /(^[\p{Han}]+$)/=~a[1]
          elsif a.size==3 && /([\p{Han}]+)/=~a[0][-1] && /(^[\p{Han}]+《)/=~b[a[0].size..-1]
            if /[《》]/!~a[1]
              b=a[0]+"｜"+b[a[0].size..-1]
            else
              b=a[0]+b[a[0].size..-1]
            end
          end
          ar << [a.join,b,"r"]
          b}
        ar=ar.uniq
        unless ar==[]
          print "ar=";p ar
          ar.map{|e| st.gsub!("#{e[0]}","#{e[1]}")} unless ar==[]
          print "ar=";p ar
          print "st=";p st
        end
        ar=[]
      }
    st
    }
  ss.join("\n")
  end
end


filename
File.dirname(URI.encode filename)

puts Dir.pwd.encode(Encoding::UTF_8)

arr=cbd.getText.gsub(/\xEF\xBB\xBF|\xEF\xBF\xBE/,"").
  split(/\R/).grep_v(/^[―]*$/).grep(/,/)
#p arr
#gsub(/一-/,"亜-")

arr=arr.map{|e|
  p e
  if /([^,]*),([^,]*),s/=~e
    oya,ruby,rp=$1,$2,"s"
  else
    e=e.
      gsub(/\([^()]*\)/){|s| s.gsub(" ","_spc_").gsub(",","_cmm_")}.
      gsub(/\{[^{}]*\}/){|s| s.gsub(" ","_spc_").gsub(",","_cmm_")}.
      gsub(/《[^《》]*》/){|s| s.gsub(" ","_spc_").gsub(",","_cmm_")}.
      gsub(/｜[^《]*《/){|s| s.gsub(" ","_spc_").gsub(",","_cmm_")}
    p e
    if /([^, ]*),([^, ]*)(,[rpsy][\d.]+)?([ ].*$)?/=~e
      oya,ruby,rp=$1,$2,$3
      print "rp=";p rp
      next if /,y/=~rp
      rp=(rp ? rp[1..-1] : "p")
      print "oya=";p oya
      print "ruby=";p ruby
      oya=oya.gsub(/_spc_/," ").gsub(/_cmm_/,",")
      ruby=ruby.gsub(/\\/){'\\\\'} unless /s/=~opt
      ruby=ruby.gsub(/_spc_/," ").gsub(/_cmm_/,",")
      print "oya=";p oya
      print "ruby=";p ruby
    elsif /,/!~e
      oya,ruby,rp=$1,"","p"
    end
  end
  [oya,ruby,rp]}
print "arr=";p arr
# arr=[[oya,ruby,rp],‥…]
arr=arr.compact.map{|e| [e[0].gsub(/^!+/,""),e[1],e[2]]}

# /[\p{Han}]/で始まる場合、直前の文字が /[\p{Han}]/なら "｜"を付ける      ⇒マッチ評価時に対応
# 但し《#.*》の時は"｜"を付けない（ルビ展開するため）                     ⇒マッチ評価時に対応
# マッチ部に「《》」があれば処理しない                                    ⇒マッチ評価時に対応
# replace の新ルール
# ルビで終わる場合、後ろの文字が /[\p{Han}]*《/なら処理しない          ・・・Ａ
# （例）黒々,黒々《くろぐろ》
# ⇒ 黒々(?![\p{Han}]*《),黒々《くろぐろ》,r                           ・・・Ａ
# パターン検索（pオプション）
#                                                       ↓ルビで終わるとき
# p       :                     〇〇                    (?![\p{Han}｜]*《)
# p[0-9]+1:       (?<=[ァ-ヴー])〇〇                    (?![\p{Han}｜]*《)
# p[0-9]+2:       (?<=[ァ-ヴー])〇〇(?![《\p{Han}｜》])
# p[0-9]+3:(?<![《ａ-ｚＡ-Ｚ》])〇〇(?![《ａ-ｚＡ-Ｚ》])
# p[0-9]+4:    (?<![《a-zA-Z》])〇〇(?![《a-zA-Z》])
# p[0-9]+5:   (?<![《\p{Han}》])〇〇                    (?![\p{Han}｜]*《)
# p[0-9]+6:                     〇〇(?![《\p{Han}｜》])
# p[0-9]+7:   (?<![《\p{Han}》])〇〇(?![《\p{Han}｜》])
# p[0-9]+8:                     〇〇                    (?![\p{Han}｜]*《)
# p[0-9]+9:                     〇〇
# rオプション
# r:/[\p{Han}]/で終わる場合、後ろの文字が /[\p{Han}]*《/なら処理しない    ・・・Ａ
arww=arr.filter{|e| /p(?!\d*)/=~e[2]}                   #単語の置換を取り出し

if /r1|r2/=~opt #r1:ルビ付き・単語 #r2:ルビ付き・正規表現
  #arwa=arww.map{|e| /》$/=~e[1] ? [e[0],e[1],"r"] :e}                  #・・・Ａ（例外処理）
  arwa=arww.map{|e| /[\p{Han}]$/=~e[0] ? [e[0],e[1],"r"] :e}            #・・・Ａ（例外処理）
else
  #arwa=arww.map{|e| /》$/=~e[1] ? [e[0]+"(?![\\p{Han}]*《)",e[1],"r"] :e}   #・・・Ａ
  arwa=arww.map{|e| 
    /[\p{Han}]$/=~e[0] ? [e[0]+"(?![\\p{Han}]*《)",e[1],"r"] :[e[0]+"(?!《)",e[1],"r"]}   #・・・Ａ
end

arr=arr.map{|e|
  if /p[0-9]*1$/=~e[2]
    e=["(?<=[ァ-ヴー])"+e[0],e[1],e[2]]
  elsif /p[0-9]*2$/=~e[2]
    e=["(?<=[ァ-ヴー])"+e[0]+"(?![《\\p{Han}｜》])",e[1],e[2]]
  elsif /p[0-9]*3$/=~e[2]
    e=["(?<![《ａ-ｚＡ-Ｚ》])"+e[0]+"(?![《ａ-ｚＡ-Ｚ》])",e[1],e[2]]
  elsif /p[0-9]*4$/=~e[2]
    e=["(?<![《a-zA-Z》])"+e[0]+"(?![《a-zA-Z》])",e[1],e[2]]
  elsif /p[0-9]*5$/=~e[2]
    e=["(?<![《\\p{Han}》])"+e[0],e[1],e[2]]
  elsif /p[0-9]*6$/=~e[2]
    e=[e[0]+"(?![《\\p{Han}｜》])",e[1],e[2]]
  elsif /p[0-9]*7$/=~e[2]
    e=["(?<![《\\p{Han}》])"+e[0]+"(?![《\\p{Han}｜》])",e[1],e[2]]
  elsif /p[0-9]*8$/=~e[2]
    print "e012=";p [e[0],e[1],e[2]]
    e=[e[0],e[1],e[2]] if /》$/!~e[1]
    e=[e[0]+"(?!\\p{Han}+《|[^《》]+》)",e[1],e[2]] if /》$/=~e[1]
  elsif /p[0-9]*9$/=~e[2]
    e=[e[0],e[1],e[2]]
  end
  e}.map{|e| print "e=";p e;
    if /s/=~e[2]
      e
    elsif /p[0-9]*[34]$/=~e[2]
      e
    elsif /》$/=~e[1] && /\p{Han}$/=~e[0]
      [e[0]+"(?![\\p{Han}｜]*《)",e[1],"r"]
    elsif /》$/=~e[1]
      [e[0]+"(?!《)",e[1],"r"]
    else
      [e[0],e[1],"r"]
    end}

print "arr=";p arr
if opt=="r1" #ルビ付き・単語
  arr=arr.map{|e| [e[0]+"(《[^》]*》)",e[1],"r"]}
elsif opt=="r2" #ルビ付き・正規表現（ルビを消して置換）
  arr=arr.map{|e| 
    [e[0].split("").join("｜?(?:《[^》]*》)?")+"｜?(?:《[^》]*》)?",e[1],"r"]}
end
print "arr=";p arr

print "opt=";p opt
# マッチ評価時に対応する項目
# マッチ部に「《》」があれば処理しない
# /[\p{Han}]/で始まる場合、直前の文字が /[\p{Han}]/なら "｜"を付ける
#s:スタンダード
#a:ルビを含めて
#r1:ルビ付き・単語
#r2:ルビ付き・正規表現

fl=open(filename).read.gsub(/\xEF\xBB\xBF|\xEF\xBF\xBE/,""). #BOM除去
  rep(arr).rep(arr) #二度繰り返して置換漏れ防止

File.write("tmp_r.txt",fl+"\n")
spawn(%Q|rubyw #{__dir__}/diff4.rbw "#{filename}" tmp_r.txt|)

__END__

マクロメニュー01.mac
置換実行
