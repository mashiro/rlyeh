#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$:.unshift 'lib', '../lib'
require 'rlyeh'
require 'logger'

class MyMiddleware
  include Rlyeh::Dispatcher

  on :privmsg do |env|
    p "Middleware: #{env.message}"
  end

  def initialize(app)
    @app = app
  end

  def call(env)
    super env
    @app.call env
  end
end

class MyApp < Rlyeh::Base
  use Rlyeh::DeepOnes::Logger
  use MyMiddleware

  on :privmsg do |env|
    p "MyApp1: #{env.message}"
  end

  on :privmsg do |env|
    p "MyApp2: #{env.message}"
  end
end

Rlyeh.run MyApp
