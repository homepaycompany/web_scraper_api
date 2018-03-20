class Property < ApplicationRecord
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
    return {new: n, updated: u, closed: c}
  end

  # Gets a listing and check wether it already exists in DB by performing checks on its price,
  # location and description, and if not then saves it in DB
  # def save_new_listing
  #   Property.where(location: self.location)
  # end

  private

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
end
