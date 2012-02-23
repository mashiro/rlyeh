#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$LOAD_PATH.unshift 'lib', '../lib'
require 'rlyeh'

class MyApp < Rlyeh::Base
  use Rlyeh::Middlewares::Logger, :level => 0
  use Rlyeh::Middlewares::Auth do |auth|
    auth.nick if [auth.nick, auth.pass] == ['dankogai', 'kogaidan']
  end

  on :privmsg do |env|
    puts "RECV: #{env.message}"
  end
end

Rlyeh.run MyApp, :host => '0.0.0.0'
