#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$LOAD_PATH.unshift 'lib', '../lib'
require 'rlyeh'

class Simple < Rlyeh::Base
  use Rlyeh::DeepOnes::Logger
  use Rlyeh::DeepOnes::Auth::Basic, 'dankogai', 'kogaidan'
  
  set :server_name, 'Simple'
  set :server_version, '1.0.0'

  on :privmsg do |env|
    puts "RECV: #{env.message}"
  end
end

Rlyeh.emerge Simple, :host => '0.0.0.0'
