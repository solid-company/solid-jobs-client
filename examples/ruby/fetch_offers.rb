require 'net/http'
require 'json'

uri = URI('https://solid.jobs/public-api/offers/IT')
params = { :campaign => 'ruby-client', :pageSize => 5 }
uri.query = URI.encode_www_form(params)

response = Net::HTTP.get_response(uri)
data = JSON.parse(response.body)

puts "Znaleziono #{data['totalCount']} ofert."

data['jobs'].each do |job|
  salary = job['salary']
  puts "#{job['title']} @ #{job['company']} (#{salary['from']}-#{salary['to']} #{salary['currency']})"
end