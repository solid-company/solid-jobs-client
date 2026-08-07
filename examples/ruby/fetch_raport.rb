require_relative 'solid_jobs_client'

CAMPAIGN = 'ruby-raport'.freeze
ROLE = 'ManualTester'.freeze

# ─────────────────────────────────────────────────────────────────────────────
#  Printing helpers — walk every field the endpoint can return.
# ─────────────────────────────────────────────────────────────────────────────

def print_bucket(label, bucket, total)
  puts format('    %-16s %5d offers  (%d%% of %d)', label, bucket['count'], bucket['percentage'], total)
end

def print_seniority_node(label, node)
  puts format('    %-16s %5d offers  (%d%% of seniority.total)', label, node['count'], node['percentage'])
  # Nested contractType has its own independent total — not the seniority level's count.
  contract = node['contractType']
  print_bucket('  b2bOnly', contract['b2bOnly'], contract['total'])
  print_bucket('  permanentOnly', contract['permanentOnly'], contract['total'])
  print_bucket('  both', contract['both'], contract['total'])
end

def print_salary_band(label, band)
  # Zero fields mean this seniority has no salary data that year — the object is still present.
  puts "    #{label.ljust(14)} median=#{band['medianLower']}..#{band['medianUpper']}  " \
       "average=#{band['averageLower']}..#{band['averageUpper']}  ranges=#{band['salaryRangeCount']}"
end

def print_salary(label, salary)
  # salaryB2B / salaryUoP are omitted entirely when the year has no data at all for that contract type.
  return puts "    #{label}: (no data for this year)" if salary.nil?

  print_salary_band("#{label} junior", salary['junior'])
  print_salary_band("#{label} regular", salary['regular'])
  print_salary_band("#{label} senior", salary['senior'])
end

def print_year(year)
  puts "\n[#{year['year']}]  offerCount=#{year['offerCount']}"

  # NOTE: every `total` below is an independent denominator — none of them equal `offerCount`
  # or each other. Offers proposing neither B2B nor a permanent contract fall outside
  # contractType, and offers with no declared experience level fall outside seniority.
  contract = year['contractType']
  puts "  contractType (total=#{contract['total']}, offerCount=#{year['offerCount']}):"
  print_bucket('b2bOnly', contract['b2bOnly'], contract['total'])
  print_bucket('permanentOnly', contract['permanentOnly'], contract['total'])
  print_bucket('both', contract['both'], contract['total'])

  seniority = year['seniority']
  puts "  seniority (total=#{seniority['total']}, offerCount=#{year['offerCount']}):"
  print_seniority_node('junior', seniority['junior'])
  print_seniority_node('regular', seniority['regular'])
  print_seniority_node('senior', seniority['senior'])

  puts '  salary (PLN, per seniority — lower..upper band):'
  print_salary('B2B', year['salaryB2B'])
  print_salary('UoP', year['salaryUoP'])

  top_skills = year['topSkills']
  puts "  topSkills (#{top_skills.length}):"
  top_skills.first(10).each { |skill| puts "    #{skill['name'].ljust(20)} #{skill['count']} offers" }
end

client = SolidJobsClient.new

# Yearly market report for a single role — up to 3 calendar years, oldest first.
# There is no `fields` parameter here: the report always comes back whole.
raport = client.get_market_raport(ROLE, CAMPAIGN)

puts "Role:         #{raport['scopeKey']}"
puts "Generated at: #{raport['generatedAt']}"
puts "Years:        #{raport['years'].length}"

raport['years'].each { |year| print_year(year) }
