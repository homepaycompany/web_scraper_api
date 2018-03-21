class Property < ApplicationRecord
  require 'fuzzy_match'
  geocoded_by :location
  after_validation :geocode, if: :will_save_change_to_location?
  searchkick locations: [:location]

  def search_data
    attributes.except("id").merge(location: {lat: latitude, lon: longitude})
  end
  # Gets a hash of listings structured as an url and a price and returns a hash with 3 arrays
  # new: array with hashs of urls to scrap
  # updated: array with hashs of properties to update structured as their ids and prices
  # closed: array with hashs of properties to close structured as their ids
  def self.filter_listings(listings_hash)
    # Instantiate empty array for new listings
    n = []
    # Instantiate empty array for listings that have been updated
    u = []
    # Get list of all listings still opened in DB - format : {url: {id, price}}
    l = self.listings_open_urls_prices_and_ids
    # Create array with ids of all opened listings in DB, from which we will remove those still opened
    c = l.keys.map { |u| l[u][:id] }
    # Iterate over each listing in the params
    listings_hash.each do |k,v|
      # Check if the url is already in DB, by looking if its url is already stored
      if l.keys.include?(k)
        # If the listing is already in DB, remove it from the Opened listings array
        c.delete(l[k][:id])
        # And check if price has changed, if yes store the listing ID and New Price in the updated listings array
        if l[k][:price] != v
          u << {id:l[k][:id], price:l[k][:price]}
        end
      else
        # If the listing is not already in DB store its url in the new listings array
        n << {url: k}
      end
    end
    return { new: n, updated: u, closed: c.map { |i| { id: i } } }
  end

  def self.listings_open_urls_prices_and_ids
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
    if options['price'] && options['location'] && options ['property_type'] && options ['livable_size_sqm']
    temp = Property.new(options.merge({all_prices: options['price'], all_updates: options['posted_on']}))
      p = self.check_for_duplicate(temp)
      if p
        temp.destroy
        p.urls += ",#{options[:url]}"
        p.update(urls: p.urls)
      else
        temp.save
      end
    end
  end

  private

  # Gets a listing and check wether it already exists in DB by performing checks on its price,
  # location and description, and if not then saves it in DB
  def self.check_for_duplicate(property)
    p 'checking for duplicates'
    # Get relevant property attributes to be passed as options for the WHERE portion of the search
     options = {
      # location: {near: {lat: property.latitude, lon: property.longitude}, within: "20km"},
      property_type: property.property_type,
      price: property.price*0.9..property.price*1.1,
      livable_size_sqm: property.livable_size_sqm*0.9..property.livable_size_sqm*1.1
     }
    a = Property.where(options)
    r = FuzzyMatch.new(a, :read => :description).find(property.description)
    return r
  end
end















