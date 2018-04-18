class Scrapers::ScraperDispatch
  # include Proxies

  def initialize(website)
    @proxy = Proxies::Proxy.new
    @website = website
    case @website
    when 'lbc'
      @scraper = Scrapers::ScraperLbc.new
    end
  end

  def get_listings_urls_and_prices(search_params)
    # Create empty hash for listings urls and prices
    all_urls_and_prices = {}
    # Scrap first page (page number 1) and store listings urls in all_url_and_prices array
    page_1_url = @scraper.build_listings_page_url(search_params.merge({ page: 1 }))
    page_1 = @proxy.open_url(page_1_url)
    if @scraper.has_listings?(page_1)
      all_urls_and_prices.merge!(@scraper.get_listings_urls_and_prices(page_1))
      pages_numbers = @scraper.get_all_pages_numbers(page_1, 1)
      while !pages_numbers.empty?
        # build url, scrap pages number and add to array if necessary, and merge page listings with prices & urls
        n = pages_numbers.first
        page_n_url = @scraper.build_listings_page_url(search_params.merge({ page: n }))
        page_n = @proxy.open_url(page_n_url)
        pages_numbers << @scraper.get_all_pages_numbers(page_n, n)
        all_urls_and_prices.merge!(@scraper.get_listings_urls_and_prices(page_n))
        pages_numbers.flatten!.uniq!
        pages_numbers.shift
      end

      return all_urls_and_prices
    end
  end

  def scrap_one_listing(url)
    listing = @scraper.extract_listing_information(@proxy.open_url(url))
    return listing
  end

  def is_add_removed?(url)
    return @scraper.is_add_removed?(@proxy.open_url(url))
  end

end
