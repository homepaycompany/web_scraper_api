class Scrapers::ScraperDispatch
  include Proxies

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
    # Scrap first page (page number 1) and store listings urls in all_urland_prices array
    page_1_url = @scraper.build_listings_page_url(search_params.merge({ page: 1 }))
    page_1 = @proxy.open_url(page_1_url)
    if @scraper.has_listings?(page_1)
      all_urls_and_prices.merge!(@scraper.get_listings_urls_and_prices(page_1))
      # Check if there are other pages and replicate process for each : scrap page, extract listings urls
      @scraper.get_all_pages_numbers(page_1).each do |n|
        page_url = @scraper.build_listings_page_url(search_params.merge({ page: n })
        all_urls_and_prices.merge!(@scraper.get_listings_urls_and_prices(@proxy.open_url(page_url)))
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
