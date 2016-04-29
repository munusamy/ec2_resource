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
      @ec2_vpc = @ec2.describe_instances()
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
      @ec2_import = @ec2_vpc.reservations
      @vpc_list = []
      @vpc_h = {}
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
      @vpc_h[:reference] = @vpc

      bag_id_name = 'vpc_id'
      databg(@vpc_h, bag_id_name)
    end      

  end
end  

