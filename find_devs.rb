#!/usr/bin/env ruby

require 'yaml'
require 'octokit'
require 'pry'

api_key   = ENV["API_KEY"]
repos     = YAML.load_file("repos.yml")
locations = YAML.load_file("locations.yml").map(&:downcase)
client    = Octokit::Client.new(:access_token => api_key)

def is_location_in_locations(locations, location)
  ret = false

  locations.each do |loc|
    if location.include?(loc)
      ret = true
      break;
    end
  end

  ret
end

repos.each do |name|
  repo = client.repo(name)

  rel = repo.rels[:contributors]

  contributors = rel.get.data

  contributors.each do |user|
    user     = client.user(user[:login])
    location = user.location.downcase rescue ""

    if is_location_in_locations(locations, location)
      puts "#{ name }: #{ user[:login] }, #{ user[:html_url] }"
    end

    sleep(1)
  end

sleep(1)
end


