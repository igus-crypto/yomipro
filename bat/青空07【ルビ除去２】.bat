rem 青空07【ルビ除去２】.bat
chcp 65001
cd /d %~dp0
ruby -x "%~f0"
goto end

#/
#!ruby
# encoding: utf-8

#$stdout=open("tmp_u7.log","w")
$stderr=open("tmp_eu7.log","w")


class String
  def del_oya
    st=self.gsub(/｜([^《》]+)《[=#~][^《》]*》/,'\1').
      gsub(/｜[^《》]+《[+%]?([^《》]*)》/,'\1').gsub(/《[+%]([^《》]*)》/,'《\1》').
      gsub(/([\p{Han}])(《[=#~!][^《》]*》)/,'\1').gsub(/([^\p{Han}])《[=#~!]([^《》]*)》/,'\1').
      gsub(/[\p{Han}]+《([^《》]*)》/,'\1').
      gsub(/.《([^《》]*)》/,'\1').gsub(/^《?([^《》]*)》/,'\1').gsub(/《[^《》]*$/,"")
  end
end

Dir.glob('**/*_u6.txt'){|file|
  f1=file.gsub(%Q|/|,%Q|\\\\|)
  f2=f1.gsub(%Q|_u6.txt|,%Q|_u7.txt|)
  s=open(file).read
  s=s.del_oya
  File.write(f2,s)}

__END__
:end
