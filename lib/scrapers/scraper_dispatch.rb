module Scrapers
  class ScraperDispatch
    include Scrapers:ScraperLbc

    def initialize(website)
      @website = website
    end

    def get_listings_urls_and_prices(location)
      # Create empty hash for listings urls and prices
      all_urls_and_prices = {}
      case @website
      when 'lbc'
        scraper = Scrapers:ScraperLbc.new
        # Scrap first listings page (page number 1) and store listings urls in all_urls array
        page_1 = scaper.scrap_one_page_html({location: location, page: 1})
        all_urls_and_prices.merge!(get_listings_urls_and_prices(page_1))
        # Check if there are other pages and replicate process for each : scrapp page, extract listings urls
        get_all_pages_numbers(page_1).each do |n|
          all_urls_and_prices.merge!(get_listings_urls_and_prices(scrap_one_page_html({location: location, page: n})))
        end
      end
    end

    def scrap_one_listing(url)
      case @website
      when 'lbc'
        scraper = Scrapers:ScraperLbc.new
        listing = extract_listing_information(get_listing_html(url))
      end
      return listing
    end

  end
end
