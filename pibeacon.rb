
require 'fileutils'
require 'yaml'
require 'net/http'
require 'net/https'
require 'json'
require 'socket'

path = ENV['HOME'] + '/.pibeacon/config'
apiHost = 'https://pibeacon.herokuapp.com'
pibeaconUUID = '3E 7E 85 35 7B 24 4C 25 9E 5D 94 AD C9 96 8F 20'

if (File.exists?(path))
  @config = YAML::load(File.open(path))
else
  print "Name your beacon: "
  name = gets.chomp

  print "Enter your API Token: "
  token = gets.chomp
  @config = { token: token, name: name }

  dir = File.dirname(path)

  unless File.directory?(dir)
    FileUtils.mkdir_p(dir)
  end

  File.open(path, 'w+') { |f| f.write @config.to_yaml }
end

@config[:ip] = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.getnameinfo[0]

# request to server with email
@data = {
  name: @config[:name],
  ip: @config[:ip]
}.to_json

if (!@config[:id])
  uri = URI.parse(apiHost + '/beacons')
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  
  req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' => 'application/json'})
  req.add_field('authentication-token', @config[:token])
  req.body = @data
  
  res = https.request(req)
  result = JSON.parse(res.body)
  @config[:id] = result['id']
  File.open(path, 'w+') { |f| f.write @config.to_yaml }
else
  uri = URI.parse(apiHost + "/beacons/#{@config[:id]}")
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  
  req = Net::HTTP::Put.new(uri.path, initheader = {'Content-Type' => 'application/json'})
  req.add_field('authentication-token', @config[:token])
  req.body = @data
  
  res = https.request(req)
  puts res.body
end

if (system("hciconfig"))
  idBytes = [
    "%02X" % (@config[:id] >> 24),
    "%02X" % ((@config[:id] >> 16) & 0xFF),
    "%02X" % ((@config[:id] >> 8) & 0xFF),
    "%02X" % (@config[:id] & 0xFF)
  ]
  system("sudo hciconfig hci0 down")
  system("sudo hciconfig hci0 up")
  system("sudo hciconfig hci0 noscan")
  system("sudo hcitool -i hci0 cmd 0x08 0x0008 1e 02 01 1a 1a ff 4c 00 02 15 #{pibeaconUUID} #{idBytes * " "} c5")
  system("sudo hciconfig hci0 leadv 0")
end
