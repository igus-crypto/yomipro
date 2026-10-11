# encoding: utf-8
# ルビチェック
# ruby_check

Encoding.default_external = 'UTF-8'

$stdout=open("tmp99.txt","w")
$stderr=open("tmp_err.txt","w")

require 'clipboard'
cbd = ClipBoard.new(__ENCODING__)

class String
  def tr2
    self.tr('ァ-ン','ぁ-ん').tr('ぁぃぅぇぉっゃゅょ','あいうえおつやゆよ')
  end
end

opt=ARGV[0]
#puts opt

#出力ファイル準備
ofs,num="tmp",1
while FileTest.file?(ofn=ofs + num.to_s + ".txt")
  num+=1
end
ofn=File.expand_path(ofs+ num.to_s + ".txt")


fl= cbd.getText.gsub(/\r/,"")
rub=fl.scan(/《[ぁ-ん]+》/).map{|e| e.gsub(/[《》]/,"").tr2}.
  uniq.sort_by{|e| -e.size}
wrd=fl.scan(/([\p{Han}]+)《([ぁ-ん]+)》/).uniq.map{|e| [e[0],e[1].tr2]}
p wrd
arr=open(__dir__+"/置換リスト/置換リスト02【ルビチェック】.txt").
  readlines.grep(/(^[^ ,]*),/).map{|e| e.chomp}
arr=arr.select{|e|rub.include?(e.gsub(/^[^,]+,[+-]?([^,]+)(,.*)?/,'\1').tr2)}
p arr
arr=arr.select{|e| p e;
  p [e.gsub(/,.*/,""),e.gsub(/[^,]+,[+-]?([^,]+)(,.*)?/,'\1').tr2]
  wrd.include?([e.gsub(/,.*/,""),e.gsub(/[^,]+,[+-]?([^,]+)(,.*)?/,'\1').tr2])}
p arr

arr=arr.map{|e| e.gsub(/\\\?/,'?')}

st=arr.join("\n")+"\n"

cbd.setText(st)

mac=File.expand_path("tmp.mac")
macro=open(mac,"w")
macro.print("\uFEFF")
mc =%Q|openfile "#{ofn}",utf8;\n|
mc+=%Q|begingroupundo;paste;\n|
mc+=%Q|selectall;cut;\n|
mc+=%Q|runsync2 "rubyw #{__dir__}/sort5.rbw ";\n|
mc+=%Q|paste;gofiletop;\n|
mc+=%Q|endgroupundo;save;endmacro;\n|
macro.puts mc

macro.close

__END__

