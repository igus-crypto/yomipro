#! ruby
# encoding: utf-8

DATA = <<'EOS'
📿📿📿
EOS

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require "base64"

mar=Marshal.load(Base64.decode64(DATA))

HAS,TRI,PAT=mar[0]
REP01,REP02,REP14=mar[1]
AR01,AR02,AR03,AR04,AR11,AR12,AR13,AR14,AR15=mar[2]
RE01,RE02,RE03,RE04,RE05,RE06,RE07,RE08,RE09,RE10=mar[3]
ST01,ST02,ST03,ST04,ST05,ST06,ST07,ST08,ST09=mar[4]

class String
  def gsub_ex
    text,mes=self,0
    HAS.each{|key,value|
      n=key[0][0]+key[0][2..-1]
      if n=="p1a" && mes==0
        STDOUT.puts "直接置換完了"
        mes=1
      end
      before=PAT[n][0]+key[1]
      after =PAT[n][1]+key[2]
      hash=value.map{|k,v| [k,v.gsub(RE01,ST01)]}.to_h
      tkey=TRI[key]
      pattern=Regexp.new(before+"("+tkey+")"+after)
      text=text.gsub(pattern){|m| ST02+hash[m]}
      text=text.gsub(RE02,ST02).
        gsub(RE03,ST03).gsub(ST02,"")
      }
    text
  end
end

def convert(text,priority,output_mode)
  
  STDOUT.puts "作業開始"
  
  priority="delete" unless priority
  output_mode="moon" unless output_mode
  
  STDOUT.puts "置換開始"
  
  # -----------------------------
  # 外字取り込み前の処理
  # -----------------------------
  
  text="\n"+text
  text.gsub!(%r|\r\n|,"\n")
  text.gsub!(%r|^-{5,}\n.*?\n-{5,}\n|m,"")
  
  # -----------------------------
  # 外字取り込み
  # -----------------------------
  
  pairs=text.scan(RE04).uniq.map{|e|
    d=e.match(RE05).to_a.map{|e| e.to_i}[1..3]
    [e,REP14[d]] if d && REP14[d]
    }.compact.reject(&:empty?)
  pairs.each do |k,v|
    next unless k && v
    text.gsub!(k,v)
  end
  
  STDOUT.puts "外字取り込み完了"
  
  # -----------------------------
  # 置換前の処理
  # -----------------------------
  
  #注釈除去
  #（　＊）のみの行を空行に
  AR02.each{|e|
    text.gsub!(e[0],e[1])}
  text.gsub!(RE06){$1*$&.length}
  text.gsub!(RE07){$1+$1.tr(ST04,ST05)}
  
  STDOUT.puts "注釈の除去完了"
  
  # -----------------------------
  # 置換実行
  # -----------------------------
  
  #直接置換
  rep01a,rep01b=REP01.partition{|k,v|
    k.size==1 || (k.size==2 && k.end_with?(ST08,ST09) || RE10=~k)
  }.map(&:to_h)
  re01b=Regexp.union(rep01b.keys.sort_by{|s|-s.length})
  text=text.gsub(Regexp.union(rep01a.keys)){|m| rep01a[m]}.
    gsub(re01b){|m| rep01b[m]}
  AR03.each{|e|
    re=Regexp.new(e[0])
    text.gsub!(re,e[1])}

  #ルビ除去
  text.gsub!(RE08){|m|
    o,r=$1,$2
    t=REP02[[o,r]]
    if t
      t=t.force_encoding("UTF-8")
      a=o+ST06+t+ST07
    else
      m
    end
  }
  
  AR01.each{|e|
    re=Regexp.new(e[0])
    text.gsub!(re,e[1])}
  
  text.gsub!(RE04){|e|
    if m = e.match(RE09)
      #STDOUT.puts "e=";p e
      key = m.captures.map(&:to_i)
      gaiji[key] || e
    else
      e
    end
  }
  
  STDOUT.puts "ルビの除去完了"
  
  text=text.gsub_ex
  text=text.gsub(Regexp.new(AR04[0])){|e|
    e.tr(AR04[1],AR04[2])}
  STDOUT.puts "正規表現の置換完了"
  
  if priority=="parent"
    AR11.each{|e|
      re=Regexp.new(e)
      text.gsub!(re,"")}
  elsif priority=="delete"
    AR12.each{|e|
      re=Regexp.new(e[0])
      text.gsub!(re,e[1])}
  end
  AR13.each{|e|
    text.gsub!(e[0],e[1])}
  
  # -----------------------------
  # 置換後処理（読み上げ用）
  # -----------------------------
  
  AR14.each{|e|
    re=Regexp.new(e[0])
    text.gsub!(re,e[1])
  }
  
  # -----------------------------
  # kindle用
  # -----------------------------
  
  if output_mode=="kindle"
    AR15.each{|e|
      re=Regexp.new(e[0],"m")
      text.gsub!(re,e[1])}
  end
  
  # -----------------------------
  # 出力
  # -----------------------------
  
  text
  
end

unless RUBY_PLATFORM =~%r|wasm|
  $stderr=open("tmp_ea.txt","w")
  $stdout=open("tmp99a.txt","w")
  priority="keep"
  require 'clipboard'
  cbd=ClipBoard.new(__ENCODING__)
  text=cbd.getText
  text=convert(text,"moon","keep")
  n=0
  while 1
    n=n+1
    break unless FileTest.file?("s#{n}.txt")
  end
  File.write("s#{n}.txt","\uFEFF"+text)
  File.write("tmp.mac",%Q|openfile "s#{n}.txt";|)
end

# python -m http.server 8000
# http://localhost:8000/aozora2.html

