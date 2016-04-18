require 'aws-sdk'
require 'json'
require 'pry'


require 'aws-sdk'
require 'json'
creds = JSON.load(File.read('secrets.json'))
Aws.config.update({
    region: 'us-west-2',
    credentials: Aws::Credentials.new(creds['AccessKeyId'], creds['SecretAccessKey'])
    })

ec2 = Aws::EC2::Client.new()
@work = Hash.new do |hash, missing_key|
  hash[missing_key] = 0
end

resp = ec2.describe_instances()
@instance_stopped = []
=begin
resp.reservations.each do |f|
 if f.instances.class == Array
   f.instances.each do |id|
     @instance_stopped << id.instance_id 
   end
 else
   @instance_stopped << f.instances[0].instance_id
 end  
end
=end
@instance_running = []
resp.reservations.each do |f|
# if f.instances.class == Array
   f.instances.each do |id|
     if id.state.name == "running" 
       runners = {}
    	runners[:id]= id.instance_id
	runners[:vpc_id] = id.vpc_id 
	runners[:subnet_id] = id.subnet_id
        puts runners
        @instance_running << runners
     else
       @instance_stopped << id.instance_id
     end
   end
end

