class Scrapers::ScraperDispatch

  def initialize(website)
    @website = website
  end

  def get_listings_urls_and_prices(options)
    # Create empty hash for listings urls and prices
    all_urls_and_prices = {}
    case @website
    when 'lbc'
      scraper = Scrapers::ScraperLbc.new
      # Scrap first listings page (page number 1) and store listings urls in all_urland_prices array
      page_1 = scraper.scrap_one_page_html(options.merge({ page: 1 }))
      all_urls_and_prices.merge!(scraper.get_listings_urls_and_prices(page_1))
      # Check if there are other pages and replicate process for each : scrapp page, extract listings urls
      # scraper.get_all_pages_numbers(page_1).each do |n|
      #   all_urls_and_prices.merge!(scraper.get_listings_urls_and_prices(scraper.scrap_one_page_html(options.merge({ page: n }))))
      # end
    end
    return all_urls_and_prices
  end

  def scrap_one_listing(url)
    p 'hello from scrap_one_listing ---------------------'
    case @website
    when 'lbc'
      scraper = Scrapers::ScraperLbc.new
      listing = scraper.extract_listing_information(scraper.get_listing_html(url))
    end
    return listing
  end

end
