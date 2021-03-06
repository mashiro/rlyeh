#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$:.unshift 'lib', '../lib'
require 'rlyeh'

class BasicServer < Rlyeh::Base
  use Rlyeh::DeepOnes::Logger
  use Rlyeh::DeepOnes::Auth::Basic, 'dankogai', 'kogaidan'
  use Rlyeh::DeepOnes::CTCP::Parser
  use Rlyeh::DeepOnes::Channels

  set :server_name, 'basic-server'
  set :server_version, '1.0.0'
  #set :store, :memory

  on :privmsg do |env|
    puts "RECV: #{env.message}"
  end
end

Rlyeh.emerge BasicServer, :host => '0.0.0.0'
