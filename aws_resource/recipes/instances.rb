#This creates a data_bag_item with list of instances on the region.

include_recipe 'aws_resource::default'

::Chef::Recipe.send(:include, Vpc::Helpers)

ec2_collect
