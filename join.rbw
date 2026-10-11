# encoding: utf-8
# join
# ファイル連結

Encoding.default_external = 'UTF-8'

#デバッグ用
#$stdout=File.open("tmp99.txt","w")
#$stderr=File.open("tmp_err.txt","w")

files=%Q|*.txt|

print "files=";p files
st=""
Dir.glob(files){|f| p f;st+=open(f).read+"\n\n"}

File.write("a00.log",st)

__END__


