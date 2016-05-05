#
# Cookbook Name:: aws_resource
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#


chef_gem 'aws-sdk' do 
  version node['aws']['sdk']
  action :install
end

cookbook_file '/etc/chef/encrypted_data_bag_secret' do
  source 'encrypted_data_bag_secret'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end
::Chef::Recipe.send(:include, Vpc::Helpers)

#vpc_aws
#sub_aws
#sub_add
#ec2_inst
