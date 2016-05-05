#This creates a data_bag_item with list of vpc's in the region.

include_recipe 'aws_resource::default'

::Chef::Recipe.send(:include, Vpc::Helpers)

vpc_aws
