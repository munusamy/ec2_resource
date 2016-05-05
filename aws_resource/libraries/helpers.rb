require 'aws-sdk'
require 'pry'

module Vpc
  module Helpers 
    def aws_control 
      @@keys = Chef::EncryptedDataBagItem.load("aws_resources", "passwd")
      @@access_key = @@keys['aws_access_key_id']
      @@secret_key = @@keys['aws_secret_access_key']
      Aws.config.update({
        region: 'us-west-2',
        credentials: Aws::Credentials.new(@@access_key, @@secret_key)
        })
      
      @ec2 = Aws::EC2::Client.new()
      @ec2_detail = @ec2.describe_instances({filters: [ { name: 'instance-state-name', values: ['running'] }] })
    end
    
    def databg(item, bag_id)
      unless Chef::DataBag.list.key?('vpc_resp')
      vpc_save = Chef::DataBag.new
      vpc_save.name('vpc_resp')
      vpc_save.create
      end
    
      ditem = Hash.new
      ditem['id'] = bag_id
      temp = ditem.merge(item)    

      databag_item = Chef::DataBagItem.new
      databag_item.data_bag('vpc_resp')
      databag_item.raw_data = temp
      databag_item.save
    end

    def vpc_aws
      aws_control 
      @ec2_import = @ec2_detail.reservations
      @vpc_list = []
      @ec2_import.map do |vpc|
        vpc.instances.each do |id|
          v = id.vpc_id
          unless @vpc_list.include?(v)
            @vpc_list << id.vpc_id
          end  
        end
        @vpc = Hash.new
        @vpc[:id] = @vpc_list
      end
    end
  
    def vpc_add
      vpc_aws
      @vpc_h = {}
      @vpc_h[:reference] = @vpc
      bag_id_name = 'vpc_id'
      databg(@vpc_h, bag_id_name)
    end      

    def sub_aws
      aws_control
      @ec2_sub = @ec2_detail.reservations
      @ec2_vpc = @ec2_sub.each { |v| v.instances.each { |s| s.vpc_id}}
      @sub_l = []
      @ec2_sub.each do |sub|
        @sub_list = {}
        sub.instances.each do |s|
          @sub_list[:subnet_id] = s.subnet_id
          @sub_list[:vpc_id] = s.vpc_id
          unless @sub_l.include?(s.subnet_id)
            @sub_l << @sub_list
          end
        end
      end 
      @sub = @sub_l.uniq
    end

    def sub_add
      sub_aws
      @sub_all = {}
      @sub_all['subnet'] = @sub
      bag_id_name = 'subnet_id'
      databg(@sub, bag_id_name)
    end

    def ec2_inst
      aws_control
      @runn = []
      @ec2_detail.reservations.each do |ins|
        ins.instances.each do |i|
          @runn << i.instance_id
        end
      end
    end

    def ec2_collect
      ec2_inst
      ec2_hash = {}
      ec2_hash[:reference] = @runn
      bag_id = 'instance_count'
      databg(ec2_hash, bag_id)
    end
 
    def sg_check
      aws_control
      ec2_inst     
      @sg_count = Array.new
      @runn.each do |instance| 
        @sg = Aws::EC2::Instance.new(instance)
        @sg.security_groups.each do |g|
          @sg_count << g.group_id
        end
      end
      @sg_total = @sg_count.uniq
    end
 
    def sg_databag
      sg_check
      @sg_list = {}
      @sg_col = {}
      @sg_total.each do |sg|
        @sg_details = Aws::EC2::SecurityGroup.new(sg)
        @sg_port = []
        @sg_details.ip_permissions.each do |p|
          p.ip_ranges.each do |c|
            @sg_col['cidr'] = c.cidr_ip
          end
          @sg_port << p.from_port
        end
      @sg_list[sg] = @sg_port 
      @sg_list.merge(@sg_col)
      end  
      bag_id = 'security_group_lists'
      databg(@sg_list, bag_id)
    end

  end
end  

