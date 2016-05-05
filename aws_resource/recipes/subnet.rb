#This creates a data_bag_item with list of subnets on the region.

include_recipe 'aws_resource::default'

::Chef::Recipe.send(:include, Vpc::Helpers)

sub_add
