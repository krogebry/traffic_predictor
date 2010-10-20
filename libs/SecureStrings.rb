##
# Secure encryption core
##
require 'openssl'

class SecureStrings
	def initialize()
		publicKeyFile	= "#{FSDocRoot}/data/ssl/public.pem"
		privateKeyFile	= "#{FSDocRoot}/data/ssl/private.pem"

		@publicKey	= OpenSSL::PKey::RSA.new(File.read( publicKeyFile ))
		@privateKey	= OpenSSL::PKey::RSA.new(File.read( privateKeyFile ),SecureStringKey )
	end
	
	def encrypt( string )
		@publicKey.public_encrypt( string )
	end

	def decrypt( string )
		@privateKey.private_decrypt( string )
	end
end
