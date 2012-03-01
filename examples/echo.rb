#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$LOAD_PATH.unshift 'lib', '../lib'
require 'rlyeh'

class Echo < Rlyeh::Base
  def call(env)
    conn = env.connection
    conn.send_data env.message
  end
end

Rlyeh.emerge Echo
