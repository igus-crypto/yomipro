#! ruby
# encoding: utf-8

DATA = <<'EOS'
📿📿📿
EOS

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require "base64"

mar=Marshal.load(Base64.decode64(DATA))
Object.send(:remove_const,:DATA)

HAS,TRI,PAT=mar[0]
TRI.clear
REP01,REP02,REP14=mar[1]
AR01,AR02,AR03,AR04,AR11,AR12,AR13,AR14,AR15=mar[2]
RE01,RE02,RE03,RE04,RE05,RE06,RE07,RE08,RE09,RE10=mar[3]
ST01,ST02,ST03,ST04,ST05,ST06,ST07,ST08,ST09=mar[4]
GC.start

# Compile the fixed replacement patterns once instead of rebuilding them for
# every call to convert.
AR01_RE=AR01.map{|e| [Regexp.new(e[0]),e[1]]}
AR03_RE=AR03.map{|e| [Regexp.new(e[0]),e[1]]}
AR11_RE=AR11.map{|e| Regexp.new(e)}
AR12_RE=AR12.map{|e| [Regexp.new(e[0]),e[1]]}
AR14_RE=AR14.map{|e| [Regexp.new(e[0]),e[1]]}
AR15_RE=AR15.map{|e| [Regexp.new(e[0],"m"),e[1]]}
AR04_RE=Regexp.new(AR04[0])

class String
  def gsub_ex
    text,mes=self,0
    cleanup_needed=true
    HAS.each{|key,value|
      n=key[0][0]+key[0][2..-1]
      if n=="p1a" && mes==0
        STDOUT.puts "直接置換完了"
        mes=1
      end
      before=PAT[n][0]+key[1]
      after =PAT[n][1]+key[2]
      replaced=gsub_literal_map_with_context(text,before,after,value)
      if replaced || cleanup_needed
        text=text.gsub(RE02,ST02).
          gsub(RE03,ST03).gsub(ST02,"")
        cleanup_needed=false
      end
      }
    text
  end
end

def gsub_literal_map_with_context(text,before,after,replacements)
  if replacements.size<=1000
    keys=replacements.keys.sort_by{|key|-key.length}
    union=Regexp.union(*keys)
    pattern=Regexp.new(before+"("+union.source+")"+after)
    normalized={}
    replaced=text.gsub!(pattern){|match|
      normalized[match] ||= replacements[match].gsub(RE01,ST01)
      ST02+normalized[match]
    }
    return !!replaced
  end
  two_char_buckets={}
  one_char_keys=[]
  replacements.each_key{|key|
    if key.length==1
      one_char_keys << key
    else
      prefix=key[0,2]
      two_char_buckets[prefix] ||= []
      two_char_buckets[prefix] << key
    end
  }

  patterns={}
  pattern_for=lambda{|prefix|
    patterns[prefix] ||= begin
      keys=two_char_buckets[prefix].sort_by{|key|-key.length}
      union=Regexp.union(*keys)
      Regexp.new("\\G"+before+"("+union.source+")"+after)
    end
  }
  one_char_pattern=nil
  unless one_char_keys.empty?
    one_char_keys.sort_by!{|key|-key.length}
    union=Regexp.union(*one_char_keys)
    one_char_pattern=Regexp.new("\\G"+before+"("+union.source+")"+after)
  end

  normalized={}
  output="".force_encoding(text.encoding)
  position=0
  copy_start=0
  text_size=text.length
  replaced=false
  while position<text_size
    prefix=text[position,2]
    pattern=two_char_buckets[prefix] && pattern_for.call(prefix)
    match=pattern && pattern.match(text,position)
    match ||= one_char_pattern && one_char_pattern.match(text,position)
    if match
      matched=match[0]
      normalized[matched] ||= replacements[matched].gsub(RE01,ST01)
      output << text[copy_start...position] if position>copy_start
      output << ST02 << normalized[matched]
      replaced=true
      next_position=match.end(0)
      next_position+=1 if next_position==position
      position=next_position
      copy_start=match.end(0)
    else
      position+=1
    end
  end
  output << text[copy_start...text_size] if copy_start<text_size
  text.replace(output) if replaced
  replaced
end
def gsub_literal_map_longest(text,replacements)
  trie={}
  replacements.each{|key,value|
    node=trie
    key.each_byte{|byte|
      node[byte] ||= {}
      node=node[byte]
    }
    node[:replacement]=value
  }

  output="".force_encoding(text.encoding)
  position=0
  copy_start=0
  text_size=text.bytesize
  while position<text_size
    node=trie
    cursor=position
    best_end=nil
    best_value=nil
    while cursor<text_size && (next_node=node[text.getbyte(cursor)])
      node=next_node
      cursor+=1
      if node.key?(:replacement)
        best_end=cursor
        best_value=node[:replacement]
      end
    end
    if best_end
      output << text.byteslice(copy_start,position-copy_start) if position>copy_start
      output << best_value
      position=best_end
      copy_start=position
    else
      position+=1
    end
  end
  output << text.byteslice(copy_start,text_size-copy_start) if copy_start<text_size
  output
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
  text=text.gsub(Regexp.union(rep01a.keys)){|m| rep01a[m]}
  text=gsub_literal_map_longest(text,rep01b)
  AR03_RE.each{|re,rep|
    text.gsub!(re,rep)}

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
  
  AR01_RE.each{|re,rep|
    text.gsub!(re,rep)}
  
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
  text=text.gsub(AR04_RE){|e|
    e.tr(AR04[1],AR04[2])}
  STDOUT.puts "正規表現の置換完了"
  
  if priority=="parent"
    AR11_RE.each{|re|
      text.gsub!(re,"")}
  elsif priority=="delete"
    AR12_RE.each{|re,rep|
      text.gsub!(re,rep)}
  end
  AR13.each{|e|
    text.gsub!(e[0],e[1])}
  
  # -----------------------------
  # 置換後処理（読み上げ用）
  # -----------------------------
  
  AR14_RE.each{|re,rep|
    text.gsub!(re,rep)
  }
  
  # -----------------------------
  # kindle用
  # -----------------------------
  
  if output_mode=="kindle"
    AR15_RE.each{|re,rep|
      text.gsub!(re,rep)}
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
  require_relative(File.file?(File.join(__dir__, "clipboard_compat.rb")) ? "clipboard_compat" : "../clipboard_compat")
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

