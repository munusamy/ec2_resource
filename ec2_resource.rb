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

resp = ec2.describe_instances()
@instance_stopped = []

@instance_running = []
resp.reservations.each do |f|
   f.instances.each do |id|
     if id.state.name == "running" 
        runners = {}
        sg_ary = []
    	runners[:id]= id.instance_id
	runners[:vpc_id] = id.vpc_id 
	runners[:subnet_id] = id.subnet_id
        id.security_groups.each do |sg| 
          sg_ary << sg.group_id
          runners[:security_groups]= sg_ary
        end
        @instance_running << runners
     else
       @instance_stopped << id.instance_id
     end
   end
end

=begin
pc = ec2.describe_instances({filters: [{ name: 'subnet-id', values: ['subnet-868050e2']}] })

@sub_arry = []
pc[0].each do |inst|
    inst.instances.each do |id|
      @sub_arry << id.instance_id
      @instance_running << @sub_arry
    end
end
=end
puts @instance_running
vpc_ids = (@instance_running.uniq {|e| e[:vpc_id]}).map {|k| k[:vpc_id]}
#subnet_ids = (@instance_running.uniq {|e| e[:subnet_id]}).map {|k| k[:subnet_id]}
@vpc_hash = {}
@vpc_item = []
vpc_ids.each do |file|
  @subnet_list = []
  @instances_list = []
  @security_list = []
  @instance_running.each do |ins|
    if file == ins[:vpc_id]
      @vpc_hash[:id] = 'vpc_resp'
      @vpc_hash[:vpc_id] = ins[:vpc_id]
      unless @subnet_list.include?(ins[:subnet_id])
        @subnet_list << ins[:subnet_id]
      end	
      unless @security_list.include?(ins[:security_groups])
        @security_list << ins[:security_groups]
      end
	@instances_list << ins[:id]
    else
      puts "vpc is not matching"
    end
      @vpc_hash[:subnet_ids] = @subnet_list
      @vpc_hash[:instances] = @instances_list
      @vpc_hash[:security_groups] = @security_list.flatten 
  end
     puts @vpc_hash
end

