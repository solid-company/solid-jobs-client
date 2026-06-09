require_relative 'solid_jobs_client'
require_relative 'helpers'

client = SolidJobsClient.new
campaign = 'ruby-client'

# 1) Basic listing — first page of IT offers
first_page = client.get_offers('IT', campaign, page_size: 5)
puts "Found #{first_page['totalCount']} offers (pages: #{first_page['totalPages']})."

first_page['jobs'].each do |job|
  puts "#{job['title']} @ #{job['company']} [#{job['experienceLevel']}] (#{format_salary(job['salary'])})"
end

# 2) Filtering + sorting — Senior Java in Warsaw, highest salary first
senior_java = client.get_offers('IT', campaign,
  search_terms: ['java'],
  cities: ['Warszawa'],
  sub_categories: ['Java'],
  experiences: ['Senior'],
  minimum_salary: 15_000,
  sort_active: 'salaryTo',
  sort_direction: 'desc',
  page_size: 10
)

puts "\nSenior Java in Warsaw: #{senior_java['totalCount']} offers"
senior_java['jobs'].each do |job|
  puts "- #{job['title']} (#{format_salary(job['salary'])})"
end

# 3) Iterate all .NET offers
puts "\nAll .NET offers:"
all_dotnet = client.get_all_offers('IT', campaign, sub_categories: ['DotNet'])
all_dotnet.each_with_index do |job, i|
  printf "%3d. %s @ %s\n", i + 1, job['title'], job['company']
end
puts "Total: #{all_dotnet.size}"
