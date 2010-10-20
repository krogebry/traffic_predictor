#!/usr/bin/ruby
##
# Generate and write new public and private keys
##
require 'openssl'
require '../config/config.rb'

strKey	= ""
23.times { strKey  << (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }

rsaKey	= OpenSSL::PKey::RSA.generate( 2048 )
cipher	=  OpenSSL::Cipher::Cipher.new('des3')

File.new("#{FSDocRoot}/data/ssl/public.pem", "w").puts( rsaKey.public_key )
File.new("#{FSDocRoot}/data/ssl/private.pem", "w").puts(rsaKey.to_pem( cipher,strKey ))

puts "New keys created for: #{strKey}"
