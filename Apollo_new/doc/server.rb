require "webrick"
include WEBrick

s = HTTPServer.new(:Port=>2000, :DocumentRoot => '.')
trap("INT"){s.shutdown}
s.start