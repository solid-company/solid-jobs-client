def format_salary(salary)
  if salary['from'].nil? && salary['to'].nil?
    "no range (#{salary['currency']})"
  else
    "#{salary['from']}-#{salary['to']} #{salary['currency']}/#{salary['period']}"
  end
end
