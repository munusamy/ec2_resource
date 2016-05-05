#This creates a data_bag_item with list of security_group id's and inbound/outbound port details.

include_recipe 'aws_resource::default'

::Chef::Recipe.send(:include, Vpc::Helpers)

sg_databag
