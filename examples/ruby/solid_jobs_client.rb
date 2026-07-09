require 'net/http'
require 'json'
require 'uri'

class SolidJobsClient
  CAMPAIGN_RE = /\A[a-z0-9-]{1,64}\z/.freeze

  def initialize(base_url: 'https://solid.jobs', api_version: '1.0', max_retries: 3)
    @base_url = base_url
    @api_version = api_version
    @max_retries = max_retries
  end

  def get_offers(division, campaign, **query)
    raise ArgumentError, 'Invalid campaign format' unless CAMPAIGN_RE.match?(campaign)

    url = build_url(division, campaign, query)
    body = request_with_retry(url)
    JSON.parse(body)
  end

  def get_all_offers(division, campaign, **query)
    page_index = query.fetch(:page_index, 0)
    all = []

    loop do
      page = get_offers(division, campaign, **query.merge(page_index: page_index))
      all.concat(page['jobs'])
      page_index += 1
      break if page['jobs'].empty? || page_index >= page['totalPages']
    end

    all
  end

  def get_market_statistics(scope_kind, scope_key, campaign, fields: nil)
    raise ArgumentError, 'Invalid campaign format' unless CAMPAIGN_RE.match?(campaign)

    params = [['campaign', campaign]]
    params << ['fields', Array(fields).join(',')] if fields && !fields.empty?

    query_string = URI.encode_www_form(params)
    url = "#{@base_url}/public-api/market-statistics/#{scope_kind}/#{scope_key}?#{query_string}"
    body = request_with_retry(url)
    JSON.parse(body)
  end

  private

  def request_with_retry(url)
    uri = URI(url)

    (0..@max_retries).each do |attempt|
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        req = Net::HTTP::Get.new(uri)
        req['X-Api-Version'] = @api_version
        http.request(req)
      end

      unless response.code == '429' && attempt < @max_retries
        raise "HTTP #{response.code}: #{response.body}" unless response.code == '200'
        return response.body
      end

      delay = response['Retry-After']&.to_i || (2**attempt)
      warn "Rate limited (429). Retrying in #{delay}s..."
      sleep(delay)
    end
  end

  def build_url(division, campaign, query)
    params = [['campaign', campaign]]

    params << ['pageIndex', query[:page_index]] if (query[:page_index] || 0) > 0
    params << ['pageSize', query[:page_size]] if query[:page_size]

    if query[:sort_active]
      params << ['sortActive', query[:sort_active]]
      params << ['sortDirection', query[:sort_direction] || 'asc']
    end

    params << ['search.cities', query[:cities].join(',')] if query[:cities]&.any?

    { categories: 'search.categories', sub_categories: 'search.subCategories',
      experiences: 'search.experiences', search_terms: 'search.searchTerm' }.each do |key, param|
      (query[key] || []).each { |v| params << [param, v] }
    end

    params << ['search.minimumSalary', query[:minimum_salary]] if query[:minimum_salary]

    query_string = URI.encode_www_form(params)
    "#{@base_url}/public-api/offers/#{division}?#{query_string}"
  end
end
