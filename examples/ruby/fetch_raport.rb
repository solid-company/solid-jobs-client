require_relative 'solid_jobs_client'

CAMPAIGN = 'ruby-raport'.freeze
ROLE = 'ManualTester'.freeze

# ─────────────────────────────────────────────────────────────────────────────
#  Printing helpers — walk every field the endpoint can return.
# ─────────────────────────────────────────────────────────────────────────────

def print_bucket(label, bucket, total)
  puts format('    %-16s %5d offers  (%d%% of %d)', label, bucket['count'], bucket['percentage'], total)
end

def print_salary(label, salary)
  # salaryB2B / salaryUoP are omitted entirely when the year has no data for that contract type.
  return puts "    #{label}: (no data for this year)" if salary.nil?

  puts "    #{label}: median=#{salary['median']}  average=#{salary['average']}  ranges=#{salary['salaryRangeCount']}"
end

def print_year(year)
  puts "\n[#{year['year']}]  offerCount=#{year['offerCount']}"

  # NOTE: `total` is the denominator of every `percentage` below — and it is NOT `offerCount`.
  # Offers proposing neither B2B nor a permanent contract fall outside contractType, and offers
  # with no declared experience level fall outside seniority.
  contract = year['contractType']
  puts "  contractType (total=#{contract['total']}, offerCount=#{year['offerCount']}):"
  print_bucket('b2bOnly', contract['b2bOnly'], contract['total'])
  print_bucket('permanentOnly', contract['permanentOnly'], contract['total'])
  print_bucket('both', contract['both'], contract['total'])

  seniority = year['seniority']
  puts "  seniority (total=#{seniority['total']}, offerCount=#{year['offerCount']}):"
  print_bucket('junior', seniority['junior'], seniority['total'])
  print_bucket('regular', seniority['regular'], seniority['total'])
  print_bucket('senior', seniority['senior'], seniority['total'])

  puts '  salary (monthly, PLN):'
  print_salary('B2B', year['salaryB2B'])
  print_salary('UoP', year['salaryUoP'])
end

client = SolidJobsClient.new

# Yearly market report for a single role — up to 3 calendar years, oldest first.
# There is no `fields` parameter here: the report always comes back whole.
raport = client.get_market_raport(ROLE, CAMPAIGN)

puts "Role:         #{raport['scopeKey']}"
puts "Generated at: #{raport['generatedAt']}"
puts "Years:        #{raport['years'].length}"

raport['years'].each { |year| print_year(year) }
