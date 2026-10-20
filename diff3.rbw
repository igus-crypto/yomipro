# encoding: utf-8
# diff3
# 差分チェック（旧）

Encoding.default_external = 'UTF-8'

$stdout=open("tmp99.txt","w")
$stderr=open("tmp_err.txt","w")

require 'clipboard'
require_relative 'clipboard_compat'
require 'diff/lcs'
require 'inifile'

ini = IniFile.load(__dir__+"/config.ini")
hide=ini["path"]["hide"]
cbd=ClipBoard.new(__ENCODING__)

op=ARGV[0]
if /[ab]/=~op
  p arr=cbd.getText.gsub(/\xEF\xBB\xBF|\xEF\xBF\xBE/,"").split(/\R/)
  txt=( op=="a" ? "tmp_diff1.txt" : "tmp_diff.txt")
  ofl=open(txt,"w")
  ofl.puts arr.join("\n")
  ofl.close
  cbd.setText(arr.join("\n"))
  exit
end

spawn("rubyw #{__dir__}/diff4.rbw tmp_diff.txt tmp_diff1.txt")

__END__

差分チェック（旧）
