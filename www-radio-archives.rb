#!/usr/bin/env ruby

# Web frontend to radio archives

require 'sinatra'

# Load supporting code and models
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file}
Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file}

get '/' do
  html = "<table>"
  Show.all.each do |s|
    html += "<tr>"
    html += "<td>#{s.title}</td><td>#{s.artist}</td>"
    html += "</tr>"
  end
  html += "</table>"
  return html
end

