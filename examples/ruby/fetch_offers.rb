require 'net/http'
require 'json'

uri = URI('https://solid.jobs/public-api/offers/IT')
params = { campaign: 'ruby-client', pageSize: 5 }
uri.query = URI.encode_www_form(params)

request = Net::HTTP::Get.new(uri)
request['X-Api-Version'] = '1.0'

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
data = JSON.parse(response.body)

puts "Znaleziono #{data['totalCount']} ofert."

data['jobs'].each do |job|
  salary = job['salary']
  puts "#{job['title']} @ #{job['company']} (#{salary['from']}-#{salary['to']} #{salary['currency']})"
end
