# encoding: utf-8
# コメントに変換

Encoding.default_external = 'UTF-8'

$stdout=open("tmp99.txt","w")
$stderr=open("tmp_err.txt","w")

require 'clipboard'

cbd=ClipBoard.new(__ENCODING__)
st=cbd.getText

puts ARGV[0]
ext=File.extname(ARGV[0])
if /rb/=~ext
  st=st.sub(/^/,"# ").gsub(/\r\n/m,"\r\n# ").
    gsub(%r|# \r\n|m,"\r\n").sub(%r|# $|,"")
else
  st=st.sub(/^/,"// ").gsub(/\r\n/m,"\r\n// ").
    gsub(%r|// \r\n|m,"\r\n").sub(%r|// $|,"")
end

cbd.setText(st)

__END__

マクロメニュー01.mac
コメントに変換

