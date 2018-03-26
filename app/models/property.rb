class Property < ApplicationRecord
  require 'fuzzy_match'
  geocoded_by :location
  after_validation :geocode, if: :will_save_change_to_location?

  # Gets a hash of listings structured as an url and a price and returns a hash with 3 arrays
  # new: array with hashs of urls to scrap
  # updated: array with hashs of properties to update structured as their ids and prices
  # closed: array with hashs of properties to close structured as their ids
  def self.filter_listings(listings_hash, options = {})
    n = [] # Instantiate empty array for new listings
    u = [] # Instantiate empty array for listings that have been updated
    l = self.listings_open_urls_prices_and_ids(options) # Get list of all listings still opened in DB - format : {url: {id, price}}
    c = l.keys.map { |u| l[u][:id] } # Create array with ids of all opened listings in DB, from which we will remove those still opened
    listings_hash.each do |k,v| # Iterate over each listing in the params
      if l.keys.include?(k) # Check if the url is already in DB, by looking if its url is already stored
        c.delete(l[k][:id]) # If the listing is already in DB, remove it from the Opened listings array
        if l[k][:price] != v # And check if price has changed, if yes store the listing ID and New Price in the updated listings array
          u << { id: l[k][:id], price: v }
        end
      else
        n << {url: k} # If the listing is not already in DB store its url in the new listings array
      end
    end
    return { new: n, updated: u, closed: c.map { |i| { id: i } } }
  end

  def self.listings_open_urls_prices_and_ids(options = {})
    a = {}
    self.all.select{ |l| l.status != 'closed' }.each do |l|
      l.urls_array.each do |u|
        a[u] = {price: l.price, id: l.id}
      end
    end
    return a
  end

  def urls_array
    if self.urls.match(',')
      return self.urls.split(',')
    else
      return [self.urls]
    end
  end

  # Perform check on a new listing : if already in DB then store the URL, if not then create a new Property
  def self.save_new_listing(options = {})
    if options[:price] && options[:location] && options [:property_type] && options [:livable_size_sqm]
      temp = Property.new(options.merge({all_prices: options[:price], all_updates: "c-#{options[:posted_on]}"}))
      p = self.check_for_duplicate(temp)
      if p
        p '!! Duplicate found !!'
        temp.destroy
        p.urls += ",#{options[:url]}"
        if p.price != options[:price] || p.status == 'closed'
          p.price = options[:price]
          p.status = "updated"
          p.all_prices += ",#{options[:price]}"
          p.all_updates += "u-#{options[:posted_on]}"
        end
        p.update(urls: p.urls, price: p.price, status: p.status, all_prices: p.all_prices, all_updates: p.all_updates)
      else
        temp.save
      end
    else
      p 'Creating incomplete property'
      Property.create(options.merge({
                                all_prices: options[:price],
                                all_updates: "c-#{options[:posted_on]}",
                                status: 'incomplete'}))
    end
  end

  private

  # Gets a listing and check wether it already exists in DB by performing checks on its price,
  # location and description, and if not then saves it in DB
  def self.check_for_duplicate(property)
    # Get relevant property attributes to be passed as options for the WHERE portion of the search
    l = Property.near([property.latitude, property.longitude], 10)
    options = {
      property_type: property.property_type,
      livable_size_sqm: property.livable_size_sqm*0.9..property.livable_size_sqm*1.1
    }
    a = l.where(options)
    r = FuzzyMatch.new(a, :read => :description).find(property.description)
    return r
  end
end
