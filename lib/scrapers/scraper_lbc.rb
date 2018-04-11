class Scrapers::ScraperLbc
  require 'nokogiri'

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
          700000 => 21,
          800000 => 22,
          900000 => 23,
          1000000 => 24
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
          700000 => 21,
          800000 => 22,
          900000 => 23,
          1000000 => 24
        }
      },
      property_type: {
        query: 'ret',
        scale: {'house' => 1,
          'appartment' => 2}
      },
      search_location: {
        query: 'location'
      },
      user_type: {
        query: 'f',
        scale: {
          'owner' => 'p',
          'v' => 'c'
        }
      },
      page: {
        query: 'o'
      },
      search_query: {
        query: 'q'
      }
    }

  end

  def build_listings_page_url(search_params = {})
    query = "?"
    search_params.each do |k, v|
      if @query_params[k].nil?
      elsif @query_params[k][:scale]
        if k.to_s == 'property_type'
          v.each do |t|
            query += "&#{@query_params[k][:query]}=#{@query_params[k][:scale][t]}"
          end
        else
          query += "&#{@query_params[k][:query]}=#{@query_params[k][:scale][v]}"
        end
      elsif k.to_s == 'search_query'
        query += "&#{@query_params[k][:query]}=#{URI.escape(v)}"
      else
        query += "&#{@query_params[k][:query]}=#{v}"
      end
    end
    url = @base_search_url + query
  end

  def has_listings?(html_doc)
    !html_doc.search(@listing_class).nil?
  end

  def get_all_pages_numbers(html_doc, page_number)
    pages_container = html_doc.search('.pagination_links_container')
    pages = []
    if pages_container.first
      pages_container.first.search('a').each do |a|
        pages << a.text.to_i if a.text.to_i > page_number
      end
    end
    return pages
  end

  def get_listings_urls_and_prices(html_doc)
    if html_doc
      listing_urls_and_prices = {}
      html_doc.search(@listing_class).each do |l|
        listing_urls_and_prices["https:#{l.attribute('href').value}"] = l.search('h3').attribute('content').value.to_i
      end
      return listing_urls_and_prices
    end
  end

  def is_add_removed?(html_doc)
    h1 = html_doc.search('h1').first.text
    if h1 == 'Cette annonce est désactivée' || h1 == 'listing removed'
      return true
    else
      return false
    end
  end

  def extract_listing_information(html_doc)
    if html_doc
      listing = {}
      html_doc.search('script').each do |s|
        if s.text.match(/(window.FLUX_STATE = )({.*})$/ )
          ad = JSON.parse(s.text.match(/[window.FLUX_STATE = ]({.*})$/ )[1])['adview']
          get_name!(listing, ad)
          get_desc!(listing, ad)
          get_price!(listing, ad)
          get_attributes!(listing, ad)
          get_city!(listing, ad)
          get_location!(listing, ad)
        end
      end
      return listing
    end
  end

  private

  def get_name!(listing, ad)
    begin
      listing[:name] = ad['subject']
    rescue
      p 'Error - no title'
    end
  end

  def get_desc!(listing, ad)
    begin
      listing[:description] = ad['body']
    rescue
      p 'Error - no description'
    end
  end

  def get_price!(listing, ad)
    begin
      listing[:price] = ad['price'][0]
    rescue
      p 'Error - no price'
    end
  end

  def get_postage_date!(listing, ad)
    begin
      listing[:posted_on] = ad['first_publication_date']
    rescue
      p 'Error - no postage date'
    end
  end

  def get_attributes!(listing, ad)
    begin
      ad['attributes'].each do |a|
        if a['key'] == 'real_estate_type'
          begin
            property_type = a['value_label']
            if property_type.match(/maison/i)
              listing[:property_type] = 'house'
            elsif property_type.match(/appartement/i)
              listing[:property_type] = 'appartment'
            elsif property_type.match(/terrain/i)
              listing[:property_type] = 'terrain'
            elsif property_type.match(/immeuble/i)
              listing[:property_type] = 'building'
            end
          rescue
            p 'Error - no property type'
          end
        elsif a['key'] == 'rooms'
          begin
            listing[:num_rooms] = a['value']
          rescue
            p 'Error - no number of rooms'
          end
        elsif a['key'] == 'square'
          begin
            listing[:livable_size_sqm] = a['value']
          rescue
            p 'Error - no livable size'
          end
        end
      end
    rescue
      p 'Error - no attributes'
    end
  end

  def get_city!(listing, ad)
    begin
      listing[:city] = ad['location']['city_label']
    rescue
      p 'Error - no city'
    end
  end

  def get_location!(listing, ad)
    begin
      if ad['location']['source'] == 'user'
        listing[:latitude] = ad['location']['lat']
        listing[:longitude] = ad['location']['lng']
        listing[:location_type] = 'address'
      else
        listing[:address] = ad['location']['city_label']
        listing[:location_type] = 'city'
      end
    rescue
      p 'Error - no coordinates'
    end
  end

  def get_user_type!(listing, ad)
    begin
      if ad['owner']['type'] == 'pro'
        listing[:user_type] = 'professional'
      else
        listing[:user_type] = 'owner'
      end
    rescue
      p 'Error - no user type'
    end
  end
end
