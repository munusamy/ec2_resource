module Vpc
  module Helpers 

    require 'aws-sdk'
    require 'pry'
    
    def aws_collection
      keys = Chef::EncryptedDataBagItem.load("aws_resources", "passwd")
      access_key = keys['aws_access_key_id']
      secret_key = keys['aws_secret_access_key']
      
      Aws.config.update({
        region: 'us-west-2',
        credentials: Aws::Credentials.new(access_key, secret_key)
        })
      ec2 = Aws::EC2::Client.new()
      
      ec2_show = ec2.describe_instances()
      
      @instance_running = []
      @instance_stopped = []
      
      ec2_show.reservations.each do |res|
      
        res.instances.each do |ints|
          if ints.state.name == "running"
            runners = {}
            runners['inst'] = ints.instance_id
            runners[:vpc_id] = ints.vpc_id
            runners[:subnet_id] = ints.subnet_id
            ints.security_groups.each {|sg| runners[:security_groups] = sg.group_id }
            @instance_running << runners
          else
            @instance_stopped << ints.instance_id
          end
        end
      
      end
      
      vpc_ids = (@instance_running.uniq {|e| e[:vpc_id]}).map {|k| k[:vpc_id]}
      
      @vpc_item = []
      @vpc_hash = {}
      vpc_ids.each do |file|
        @subnet_list = []
        @instances_list = []
        @instance_running.each do |ins|
          if file == ins[:vpc_id]
            @vpc_hash['id'] = 'vpc_resp'
            @vpc_hash[:vpc_id] = ins[:vpc_id]
       	unless @subnet_list.include?(ins[:subnet_id])
          @subnet_list << ins[:subnet_id]
      	end	
      	@instances_list << ins['inst']
          else
            puts "vpc is not matching"
          end
            @vpc_hash[:subnet_ids] = @subnet_list
            @vpc_hash[:instances] = @instances_list
            @vpc_hash[:security_groups] = ins[:security_groups]
        puts @vpc_hash
        unless Chef::DataBag.list.key?('vpc_resp')
        vpc_save = Chef::DataBag.new
        vpc_save.name('vpc_resp')
        vpc_save.create
        end
        
        databag_item = Chef::DataBagItem.new
        databag_item.data_bag('vpc_resp')
        databag_item.raw_data = @vpc_hash
        databag_item.save
        end
      end
    end
    
  end
end  
