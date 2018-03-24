class Scrapers::ScraperDispatch

  def initialize(website)
    @website = website
    case @website
    when 'lbc'
      @scraper = Scrapers::ScraperLbc.new
    end
  end

  def get_listings_urls_and_prices(options)
    # Create empty hash for listings urls and prices
    all_urls_and_prices = {}
    # Scrap first listings page (page number 1) and store listings urls in all_urland_prices array
    page_1 = @scraper.scrap_one_page_html(options.merge({ page: 1 }))
    all_urls_and_prices.merge!(@scraper.get_listings_urls_and_prices(page_1))
    # Check if there are other pages and replicate process for each : scrap page, extract listings urls
    p @scraper.get_all_pages_numbers(page_1)
    @scraper.get_all_pages_numbers(page_1).each do |n|
      all_urls_and_prices.merge!(@scraper.get_listings_urls_and_prices(@scraper.scrap_one_page_html(options.merge({ page: n }))))
    end
    return all_urls_and_prices
  end

  def scrap_one_listing(url)
    listing = @scraper.extract_listing_information(@scraper.get_listing_html(url))
    return listing
  end

  def is_add_removed?(url)
    return @scraper.is_add_removed?(@scraper.get_listing_html(url))
  end

end
