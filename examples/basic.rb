#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$LOAD_PATH.unshift 'lib', '../lib'
require 'rlyeh'

class BasicServer < Rlyeh::Base
  use Rlyeh::DeepOnes::Logger
  use Rlyeh::DeepOnes::Auth::Basic, 'dankogai', 'kogaidan'

  set :server_name, 'basic-server'
  set :server_version, '1.0.0'

  on :privmsg do |env|
    puts "RECV: #{env.message}"
  end
end

Rlyeh.emerge BasicServer, :host => '0.0.0.0'
