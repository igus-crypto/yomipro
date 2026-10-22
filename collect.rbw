# encoding: utf-8
# collect
# grepの修正を集める

Encoding.default_external = 'UTF-8'

$stdout=open("tmp99.txt","w")
$stderr=open("tmp_err.txt","w")

class Array
  def sortq
    ar=self.group_by{|e| e.gsub(/^(!*)([^!].*)/,'\1').size}.
      to_a.sort_by{|e| -e[0].to_i}.transpose[1].to_a.
      map{|e| e.partition{|f| %r|[^ ]*,y|!~f}}
    #print "ar=";p ar
    ar
  end
end


opt=ARGV[0]
#s:修正を集める
#h:本文を集める
#k:本文を集めて加工
#b:「!」行を末尾にコピー

require 'clipboard'

require_relative 'clipboard_compat'
cbd=ClipBoard.new(__ENCODING__)

arr=cbd.getText.split(/\R/).reject{|e| e==""}
#arr.map{|e| print "e=";p e.encode(Encoding::UTF_8)}
print "arr=";p arr

if /^s/=~opt #修正を集める
  #arr=arr.grep_v(/\(\d+\):|^\//)
  arr=arr.grep(%r| =>|)
  arr=arr.compact.uniq
  ar0=arr.grep(/^!+/).sortq;arr=arr-ar0.flatten;
  ar1=arr.grep(/^[^ ]*《[#=][^#=《》]+》/).grep_v(/^[^ ]*《[^#=《》]+》/)
  ar1=arr.grep(/^[^ ]*《[^#=《》]+》/).sortq
  ar2=arr.grep_v(/^[^ ]*《[^#=《》]+》/).sortq
  print "arr=";p arr
  print "ar0=";p ar0
  print "ar1=";p ar1
  print "ar2=";p ar2
  st=[ar0,ar1,ar2].map{|e| e.map{|f| f.map{|g| g.join("\n")}.join("\n\n")}.
    join("\n\n")}.join("\n\n")
  st=st.strip.gsub(/\n{3,}/,"\n\n")+"\n"
elsif /^h/=~opt #本文を集める
  arr=arr.grep(/:\(\d+\):/).map{|e| e.sub(/^(.*?):\(\d+\):[\+\=]?/){|f| f.gsub(/./," ")}}.uniq
  num=arr.map{|e| e.gsub(/([^ ].*)$/,"").size}.min
  arr=arr.map{|e| e.sub(" "*num,"")}
  st=arr.join("\n")+"\n"
elsif /^k/=~opt #本文を集めて加工
  arr=arr.grep(/:\(\d+\):/).map{|e| e.sub(/^(.*?):\(\d+\):[\+\=]?/){|f| f.gsub(/./," ")}}.uniq
  num=arr.map{|e| e.gsub(/([^ ].*)$/,"").size}.min
  arr=arr.map{|e| e.sub(" "*num,"").gsub(/《[^《》]*$/,"")}
  s1=arr.join("\n")+"\n"
  #親文字削除
  s2=s1.gsub(/｜([^《》]+)$/,'\1').gsub(/｜([^《》]+)《[=#][^《》]*》/,'\1').
    gsub(/《[+%]([^《》]*)》/,'《\1》').gsub(/[^\p{Han}]《([=#][^《》]*)》/,'\1').
    gsub(/(《[=#][^《》]*》)/,'').gsub(/｜[^《》]+《([^《》]*)》/,'\1').
    gsub(/[\p{Han}]+《([^《》]*)》/,'\1').gsub(/.《([^《》]*)》/,'\1').gsub(/[《》]/,"")
  #ルビを除去
  s3=s1.gsub(/｜([^《》]+)《[^》]*》/,'\1').gsub(/《[^》]*》/,"")
  print "s1=";p s1
  print "s2=";p s2
  print "s3=";p s3
  st=s2+"\n\n"+s3
elsif /^b/=~opt #「!」行を末尾にコピー
  p st=arr.grep(/^!/).group_by{|e| e.gsub(/^(!*)([^!].*)/,'\1').size}.
    to_a.sort_by{|e| -e[0].to_i}.transpose[1].to_a.map{|e| e.join("\n")}.join("\n")+"\n"
end

cbd.setText(st)
__END__

grepの修正を集める.mac



