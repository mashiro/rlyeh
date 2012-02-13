#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$LOAD_PATH.unshift 'lib'
require 'rlyeh'

class MyApp < Rlyeh::Base
  on :privmsg do |env|
    p "MyApp1: #{env.message}"
  end

  on :privmsg do |env|
    p "MyApp2: #{env.message}"
  end
end

Rlyeh.run MyApp
