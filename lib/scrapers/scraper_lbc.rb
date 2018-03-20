require 'open-uri'
require 'nokogiri'
class Scrapers::ScraperLbc

  def initialize
    @base_search_url = 'https://www.leboncoin.fr/ventes_immobilieres/offres/'
    @listing_class = '.tabsContent ul li a'
    @query_params = {
      min_price: {
        query:'ps',
        scale: {
          100000 => 4,
          125000 => 5,
          150000 => 6,
          175000 => 7,
          200000 => 8,
          225000 => 9,
          250000 => 10,
          275000 => 11,
          300000 => 12,
          325000 => 13,
          350000 => 14,
          400000 => 15,
          450000 => 16,
          500000 => 17,
          550000 => 18,
          600000 => 19,
          650000 => 20,
          700000 => 21
        }
      },
      max_price: {
        query: 'pe',
        scale: {
          100000 => 4,
          125000 => 5,
          150000 => 6,
          175000 => 7,
          200000 => 8,
          225000 => 9,
          250000 => 10,
          275000 => 11,
          300000 => 12,
          325000 => 13,
          350000 => 14,
          400000 => 15,
          450000 => 16,
          500000 => 17,
          550000 => 18,
          600000 => 19,
          650000 => 20,
          700000 => 21
        }
      },
      property_type: {
        query: 'ret',
        scale: {house: 1,
          appartment: 2}
      },
      location: {
        query: 'location'
      },
      user_type: {
        query: 'f',
        scale: {
          owner: 'p',
          professionals: 'c',
          all: ''
        }
      },
      page: {
        query: 'o',
        scale: {
          1 => '',
          2 => 2,
          3 => 3,
          4 => 4,
          5 => 5,
          6 => 6,
          7 => 7,
          8 => 8,
          9 => 9,
          10 => 10
        }
      }
    }

  end

  def scrap_one_page_html(options = {})
    query = "?"
    options.each do |k, v|
      if k.to_s == "location"
        query += "&#{@query_params[k][query]}=#{v}"
      elsif @query_params[k][:scale][v] != ''
        if k.to_s == 'property_type'
          v.each do |t|
            query += "&#{@query_params[k][:query]}=#{@query_params[k][:scale][v]}"
          end
        else
          query += "&#{@query_params[k][:query]}=#{@query_params[k][:scale][v]}"
        end
      end
    end

    url = @base_search_url + query
    html_file = open(url).read
    html_doc = Nokogiri::HTML(html_file)
  end

  def get_all_pages_numbers(html_doc)
    pages_container = html_doc.search('.pagination_links_container')
    pages = []
    if pages_container
      pages_container.first.search('a').each do |a|
        pages << a.text.to_i
      end
    end
    return pages
  end

  def get_listings_urls_and_prices(html_doc)
    listing_urls_and_prices = {}
    html_doc.search(@listing_class).each do |l|
      listing_urls_and_prices["https:#{l.attribute('href').value}"] = l.search('h3').attribute('content').value
    end
    return listing_urls_and_prices
  end

  def get_listing_html(url)
    p 'hello from get_listing_html ---------------------'
    listing_html_file = open(url).read
    listing_html_doc = Nokogiri::HTML(listing_html_file)
  end

  def extract_listing_information(html_doc)
    p 'hello from extract_listing_info ---------------------'
    listing = {}
    begin
      listing[:name] = html_doc.search('h1').first.text
    rescue
      p 'Error - no title'
    end
    begin
      listing[:price] = html_doc.search('div[data-qa-id="adview_price"]').first.text.match(/([\d+\s*]+\d)/)[1].gsub(/\s/, "")
    rescue
      p 'Error - no price'
    end
    begin
      listing[:posted_on] = html_doc.search('div[data-qa-id="adview_date"]').first.text
    rescue
      p 'Error - no postage date'
    end
    begin
      listing[:property_type] = html_doc.search('div[data-qa-id="criteria_item_real_estate_type"]').first.children.last.text
    rescue
      p 'Error - no property type'
    end
    begin
      listing[:num_rooms] = html_doc.search('div[data-qa-id="criteria_item_rooms"]').first.children.last.text
    rescue
      p 'Error - no number of rooms'
    end
    begin
      listing[:livable_size_sqm] = html_doc.search('div[data-qa-id="criteria_item_square"]').first.children.last.text.match(/(\d+)/)[1]
    rescue
      p 'Error - no livable size'
    end
    begin
      listing[:description] = html_doc.search('div[data-qa-id="adview_description_container"] span').first.text
    rescue
      p 'Error - no description'
    end
    begin
      listing[:location] = html_doc.search('div[data-qa-id="adview_location_container"] span').first.text
    rescue
      p 'Error - no location'
    end
    return listing
  end
end
