require_relative 'solid_jobs_client'

def print_band(band)
  if band.nil?
    puts '    (no offers with a declared salary)'
    return
  end
  puts "    min=#{band['min']}  p25=#{band['p25']}  median=#{band['median']}  p75=#{band['p75']}  max=#{band['max']}"
end

def print_contract_salary(label, stat)
  if stat.nil?
    puts "    #{label}: (no precomputed data)"
    return
  end
  puts "    #{label}: median=#{stat['median']}  average=#{stat['average']}  offers=#{stat['offerCount']}"
end

def print_buckets(buckets)
  (buckets || []).each do |b|
    printf "    %-24s %5d offers  (%d%%)\n", b['label'], b['offerCount'], b['percentage']
  end
end

def print_statistics(stats)
  puts "Scope:            #{stats['scopeKind']} / #{stats['scopeKey']}"
  puts "Generated at:     #{stats['generatedAt']}"
  puts "Included sections: #{stats['includedSections'].join(', ')}"

  if (demand = stats['demand'])
    puts "\n[demand]"
    puts "  activeOffers=#{demand['activeOffers']}  distinctEmployers=#{demand['distinctEmployers']}" \
         "  remoteOffers=#{demand['remoteOffers']}  remotePercentage=#{demand['remotePercentage']}%"
    puts '  offerTrend (quarterly):'
    demand['offerTrend'].each do |point|
      puts "    #{point['period']}: #{point['offerCount']} offers"
    end
  end

  if (salary = stats['salary'])
    puts "\n[salary] currency=#{salary['currency']}"
    puts '  overall (live percentiles):'
    print_band(salary['overall'])
    print_contract_salary('b2b       ', salary['b2b'])
    print_contract_salary('permanent ', salary['permanent'])
  end

  if stats.key?('experience')
    puts "\n[experience]"
    print_buckets(stats['experience'])
  end

  if stats.key?('topLocations')
    puts "\n[topLocations]"
    print_buckets(stats['topLocations'])
  end

  if stats.key?('topSkills')
    puts "\n[topSkills]"
    print_buckets(stats['topSkills'])
  end
end

client = SolidJobsClient.new
campaign = 'ruby-stats'

# 1) Full snapshot — every section available for the React specialization
full = client.get_market_statistics('subcategory', 'React', campaign)
print_statistics(full)

# 2) Partial fetch — ask only for `demand` and `salary` using the `fields` filter.
#    `includedSections` in the response confirms exactly what came back.
puts "\n───────────────────────────────────────────────"
puts 'Partial fetch with fields=demand,salary:'
partial = client.get_market_statistics('subcategory', 'React', campaign, fields: %w[demand salary])
puts "Included sections: #{partial['includedSections'].join(', ')}"
