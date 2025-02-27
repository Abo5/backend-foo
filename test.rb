#!/usr/bin/env ruby
require 'net/http'
require 'uri'
require 'json'

BASE_URL = 'http://localhost:3000'

GREEN   = "\e[32m"
RED     = "\e[31m"
YELLOW  = "\e[33m"
BLUE    = "\e[34m"
RESET   = "\e[0m"

def make_http_request(uri, req)
  Net::HTTP.start(uri.hostname, uri.port) do |http|
    puts "#{YELLOW}Sending #{req.method} request to #{uri}#{RESET}"
    puts "#{YELLOW}Headers: #{req.to_hash}#{RESET}"
    puts "#{YELLOW}Body: #{req.body}#{RESET}" if req.body
    response = http.request(req)
    puts "#{YELLOW}Response Headers: #{response.to_hash}#{RESET}"
    response
  end
end

def login(email, password)
  uri = URI("#{BASE_URL}/login")
  req = Net::HTTP::Post.new(uri)
  req['Content-Type'] = 'application/json'
  req['Accept'] = 'application/json'
  req.body = {
    user: {
      email: email,
      password: password
    }
  }.to_json

  res = make_http_request(uri, req)
  puts "#{BLUE}Login Response Code: #{res.code}#{RESET}"
  puts "#{BLUE}Login Response Body: #{res.body}#{RESET}"
  
  body = JSON.parse(res.body) rescue {}
  token = res['Authorization']&.split(' ')&.last || body['token']
  cookies = res.get_fields('set-cookie')
  cookie_string = cookies&.join('; ') || ""
  
  { token: token, cookie_string: cookie_string, body: body }
end

def refresh(token, cookie_string)
  uri = URI("#{BASE_URL}/login/refresh")
  req = Net::HTTP::Post.new(uri)
  req['Content-Type'] = 'application/json'
  req['Accept'] = 'application/json'
  req['Authorization'] = "Bearer #{token}"
  req['Cookie'] = cookie_string

  res = make_http_request(uri, req)
  puts "#{BLUE}Refresh Response Code: #{res.code}#{RESET}"
  puts "#{BLUE}Refresh Response Body: #{res.body}#{RESET}"
  
  body = JSON.parse(res.body) rescue {}
  new_token = res['Authorization']&.split(' ')&.last || body['token']
  new_cookies = res.get_fields('set-cookie')
  new_cookie_string = new_cookies&.join('; ') || cookie_string
  
  { token: new_token, cookie_string: new_cookie_string, body: body }
end

def logout(token, cookie_string)
  uri = URI("#{BASE_URL}/logout")
  req = Net::HTTP::Delete.new(uri)
  req['Content-Type'] = 'application/json'
  req['Accept'] = 'application/json'
  req['Authorization'] = "Bearer #{token}"
  req['Cookie'] = cookie_string

  res = make_http_request(uri, req)
  puts "#{BLUE}Logout Response Code: #{res.code}#{RESET}"
  puts "#{BLUE}Logout Response Body: #{res.body}#{RESET}"
  
  body = JSON.parse(res.body) rescue {}
  { body: body }
end

def validate_response(response, operation)
  success = !response[:body].empty? && response[:body]['error'].nil?
  status = success ? 'succeeded' : 'failed'
  message = !response[:body].empty? ? response[:body].to_s : 'Empty response'
  puts "#{success ? GREEN : RED}#{operation} #{status}: #{message}#{RESET}"
  success
end

# بيانات الاختبار
email = "aszda33@gmail.com"
password = "password!123321;wldkjnfbman[[Abood88%^&]]"

puts "\n#{GREEN}Starting Authentication Tests#{RESET}"

puts "\n#{GREEN}1. Testing Login#{RESET}"
login_result = login(email, password)
validate_response(login_result, 'Login')

if login_result[:token]
  token = login_result[:token]
  cookie_string = login_result[:cookie_string]
  
  puts "\n#{GREEN}2. Testing Token Refresh#{RESET}"
  refresh_result = refresh(token, cookie_string)
  validate_response(refresh_result, 'Refresh')
  
  puts "\n#{GREEN}3. Testing Invalid Token Refresh#{RESET}"
  invalid_refresh = refresh("invalid_token", cookie_string)
  validate_response(invalid_refresh, 'Invalid token refresh')
  
  puts "\n#{GREEN}4. Testing Logout#{RESET}"
  logout_result = logout(token, cookie_string)
  validate_response(logout_result, 'Logout')
  
  puts "\n#{GREEN}5. Testing Second Logout (should fail)#{RESET}"
  second_logout = logout(token, cookie_string)
  validate_response(second_logout, 'Second logout')
else
  puts "#{RED}Login failed, skipping remaining tests#{RESET}"
end