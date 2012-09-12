#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$:.unshift 'lib', '../lib'
require 'rlyeh'

class Echo < Rlyeh::Base
  def call(env)
    conn = env.connection
    conn.send env.message
  end
end

Rlyeh.emerge Echo
