rem 青空05【ルビ置換１】.bat
chcp 65001
cd /d %~dp0
ruby -x "%~f0"
goto end

#/
#!ruby
# encoding: utf-8

$stdout=open("tmp_u5.log","w")
$stderr=open("tmp_eu5.log","w")

t1=Time.now

class String
  def to_hg(path)
    text=self
    groups=open(path).read.split(%r|\R|).
      select{|e| %r|,|=~e}.#reject{|e| %r|,[rpy]|=~e}.
      map{|e| e.gsub(%r| .*|,"").
        gsub(%r|《(?=[ぁ-んァ-ヴー]+》)|,"《%").split(",")}.
      reject{|f| f.size!=2}.
      group_by{|f,_| f.length}
    #p groups.class
    #groups.each{|e| p e}
    groups.keys.sort.reverse.each{|len|
      group = groups[len]
      next unless group
    
      fast = []
      slow = []
    
      group.each{|o, rep|
        ## 置換後に《》が無い → 区切り不要 → fast
        #if !rep.include?("《")
        #  fast << [o, rep]
        #else
        #  slow << [o, rep]
        #end
        # 置換後に《》が無い → 区切り不要 → fast
        if %r|^\p{Han}*《|=~rep or %r|》$|=~rep
          slow << [o, rep]
        else
          fast << [o, rep]
        end
      }
    
      # --- fast：一気に置換 ---
      if fast.any?
        table = fast.to_h
        re = Regexp.union(table.keys)
        text.gsub!(re){|m| table[m] }
      end
    
      # --- slow：文脈付きで1件ずつ ---
      slow.each{|o, rep|
        text.gsub!(%r|([^｜])#{Regexp.escape(o)}(?!\p{Han}*《)|){|_|
          m1 = $1
          if m1.match?(/\p{Han}/)
            m1 + "｜" + rep
          else
            m1 + rep
          end
        }
      }
    }






#    groups.keys.sort.reverse.each{|len|
#      group = groups[len]
#      next unless group
#      table=group.to_h
#      re=Regexp.union(table.keys)
#      text.gsub!(%r|([^｜])(#{re})(?!\p{Han}*《)|){|m|
#        m1,m2=$1,$2
#        unless table[m2]
#          warn "not found: #{m2}"
#          exit
#        end
#        if %r|^\p{Han}|=~m1 && %r|\p{Han}*《|=~m
#          m1+"｜"+table[m2]
#        else
#          m1+table[m2]
#        end
#      }
#    }

#    groups.keys.sort.reverse.each{|len|
#      group=groups[len]
#      next unless group
#      table=group.to_h
#      table.each{|k,v| p k;p v}
#      text.gsub!(%r|([^｜])(#{table.keys})(?!\p{Han}*《)|){|m|
#        m1,m2=$1,$2
#        unless table[m]
#          #p table.keys
#          print "m=";p m
#          print "m1=";p m1
#          print "m2=";p m2
#          exit
#        end
#        #print "[ar,m1,m2,e]=";p [ar,m1,m2]
#        if %r|^\p{Han}|=~m1 && %r|^\p{Han}*《|=~table[m]
#          m1+"｜"+table[m]
#        else
#          m1+table[m]
#        end
#        }
#      }
    text
  end
end

dir=File.expand_path("..",__dir__)+"/置換リスト"
Dir.glob('**/*_u4.txt'){|file|
  f1=file.gsub(%Q|/|,%Q|\\\\|)
  f2=f1.gsub(%Q|_u4.txt|,%Q|_u5.txt|)
  s=open(file).read
  s=s.to_hg(dir+"/置換リスト03【数字関連】.txt")
  s=s.to_hg(dir+"/置換リスト04【五文字以上】.txt")
  s=s.to_hg(dir+"/置換リスト05【四文字】.txt")
  s=s.to_hg(dir+"/置換リスト06【三文字】.txt")
  s=s.to_hg(dir+"/置換リスト07【二文字以下】.txt")
  File.write(f2,s)
}

t2=Time.now
p t2-t1

__END__
:end
