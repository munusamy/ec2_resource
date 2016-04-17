require 'aws-sdk'
require 'pry'


require 'aws-sdk'
require 'json'
creds = JSON.load(File.read('secrets.json'))
Aws.config.update({
    region: 'us-west-2',
    credentials: Aws::Credentials.new(creds['AccessKeyId'], creds['SecretAccessKey'])
    })

ec2 = Aws::EC2::Client.new()

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
 if f.instances.class == Array
   f.instances.each do |id|
#binding.pry
     if id.state.name == "running" 
       @instance_running << id.instance_id
     else
       @instance_stopped << id.instance_id
     end
   end
 else
   if f.state.name == "running"
     @instance_running << f.instances[0].instance_id
   else
     @instance_stopped << f.instances[0].instance_id
   end
 end  
end


puts @instance_running
#puts "Stopped one"
#puts @instance_stopped


vpc = ec2.describe_instances(instance_ids: @instance_running)
puts "####################################"
@instance_running.each do |f|
 vpc_inst_id = vpc.reservations[0].instances[0].vpc_id
 vpc_hash = {}
 vpc_hash[f] = vpc_inst_id 
 puts vpc_hash
end
