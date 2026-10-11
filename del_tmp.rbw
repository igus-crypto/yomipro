# encoding: utf-8
# tmpファイル削除

Encoding.default_external = 'UTF-8'
require 'win32ole'
require 'fileutils'

#$stdout=open("tmp99.txt","w")
#$stderr=open("tmp_err.txt","w")

#FileUtils.rm_r(Dir.glob(%q|**/tmp*|))
Dir.glob(%q|**/tmp*|){|f|begin;FileUtils.rm(f);rescue;next;end}
Dir.glob(__dir__+%q|/**/tmp*|){|f|begin;FileUtils.rm(f);rescue;next;end}
wsh = WIN32OLE.new('WScript.Shell')
wsh.Popup("tmpファイルを削除しました",1)
