rem touch
chcp 65001
ruby -x "%~f0"
goto end

#!ruby
# encoding: utf-8

require 'fileutils'
FileUtils.touch(Dir.glob('**/*'))

__END__
:end
