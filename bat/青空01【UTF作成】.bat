rem 青空01【UTF作成】.bat
chcp 65001
cd /d %~dp0
ruby -x "%~f0"
goto end

#/
#!ruby
# encoding: utf-8

#$stdout=open("tmp_u.log","w")
$stderr=open("tmp_eu1.log","w")

Dir.glob('**/*.txt'){|file|
  #p file
  next if %r|\/tmp|=~file
  f1=file.gsub(%Q|/|,%Q|\\\\|)
  f2=f1.gsub(%r|.txt|i,%Q|_u.txt|)
  begin
    s=open(file).read.encode(Encoding::UTF_8,Encoding::SJIS)
    s=s.gsub(/\xEF\xBB\xBF|\xEF\xBF\xBE/,"")
  rescue
    s=open(file).read.encode(Encoding::UTF_8,Encoding::UTF_8)
    s=s.gsub(/\xEF\xBB\xBF|\xEF\xBF\xBE/,"")
  end
  File.write(f2,"\uFEFF"+s)}

__END__
:end
