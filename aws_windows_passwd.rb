require 'aws-sdk'

ec2 = Aws::EC2::Client.new

# Fetch Windows Login Password on AWS
encrypt_password = ec2.get_password_data({ dry_run: false, instance_id: 'i-xxxx' }).password_data
private_key = OpenSSL::PKey::RSA.new(File.read('actual_key.pem'))
decoded = Base64.decode64(encrypt_password)
password = private_key.private_decrypt(decoded)
puts password
