class Property < ApplicationRecord
  require 'fuzzy_match'
  require 'amatch'
  has_many :property_alerts
  before_create :calculate_price_per_sqm!
  include PgSearch
  FuzzyMatch.engine = :amatch
  geocoded_by :address
  reverse_geocoded_by :latitude, :longitude
  pg_search_scope :search_by_description,
    against: [ :name, :description],
    using: {
      tsearch: { prefix: true }
  }

  # Gets a hash of listings structured as an url and a price and returns a hash with 3 arrays
  # new: array with hashs of urls to scrap
  # updated: array with hashs of properties to update structured as their ids and prices
  # closed: array with hashs of properties to close structured as their ids
  def self.filter_listings(listings_hash, search_params = {})
    n = [] # Instantiate empty array for new listings
    u = [] # Instantiate empty array for listings that have been updated
    l = self.listings_open_urls_prices_and_ids(search_params) # Get list of all listings still opened in DB - format : {url: {id, price}}
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

  def self.listings_open_urls_prices_and_ids(search_params = {})
    a = {}
    self.all.select{ |l|
      l.status != 'closed' &&
      l.search_location == search_params[:search_location] &&
      (search_params[:min_price]..search_params[:max_price]).include?(l.price)
      }.each do |l|
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
  def self.save_new_listing(search_params = {})
    if search_params[:price] && search_params[:location_type] && search_params [:property_type] && search_params [:livable_size_sqm]
      temp = Property.new(search_params.merge({ all_prices: search_params[:price], all_updates: "c-#{search_params[:posted_on]}" }))
      if temp[:location_type] == 'address'
        temp.reverse_geocode
      end
      prop = self.check_for_duplicate(temp)
      if prop
        p '-- Duplicate found'
        prop.update_listing(temp.attributes)
      else
        if temp.location_type == "address"
          temp.need_to_enrich_location = false
        end
        temp.save
      end
    else
      p '-- Creating incomplete property'
      Property.create(search_params.merge({
        all_prices: search_params[:price],
        all_updates: "c-#{search_params[:posted_on]}",
        status: 'incomplete'}))
    end
  end

  def update_listing(search_params = {})
    search_params.each do |k,v|
      if self.send(k).nil? && v
        self.write_attribute(k,v)
      end
    end
    if search_params[:price] && search_params[:price]!= self.price
      self.price = search_params[k]
      self.all_prices = self.all_prices + ",#{search_params[:price]}"
      self.status = 'updated'
      self.all_updates = self.all_updates + "u-#{search_params[:posted_on] || Time.now.strftime('%d/%m/%Y')}"
    end
    if search_params[:url] && !self.urls_array.include?(search_params[:url])
      self.urls = self.urls + ",#{search_params[:url]}"
    end
    if self.save
      p 'record updated'
    end
  end

  def close_listing
    self.all_updates = self.all_updates + ",c-#{Time.now.strftime("%d/%m/%Y")}"
    self.status = 'closed'
    self.removed_on = Time.now.strftime("%d/%m/%Y")
    self.all_updates = all_updates
    if self.save
      p 'record updated'
    end
  end

  def self.to_csv(properties)
    attributes = properties.first.attributes.keys
    CSV.generate(headers: true, col_sep: ';', force_quotes: true, quote_char: '"' ) do |csv|
      csv << attributes
      properties.each do |property|
        property.name = property.name.gsub(/[,"\n]/,'').force_encoding('UTF-8')
        property.description = property.description.gsub(/[,"\n]/,'').force_encoding('UTF-8')
        csv << property.attributes.values
      end
    end
  end

  private

  # Gets a listing and check wether it already exists in DB by performing checks on its price,
  # location and description, and if not then saves it in DB
  def self.check_for_duplicate(property)
    # Get relevant property attributes to be passed as search_params for the WHERE portion of the search
    l = Property.near([property.latitude, property.longitude], 10)
    search_params = {
      property_type: property.property_type,
      livable_size_sqm: (property.livable_size_sqm - 1)..(property.livable_size_sqm + 1),
      price: property.price*0.8..property.price*1.2
    }
    a = l.where(search_params)
    r = FuzzyMatch.new(a, :read => :description).find(property.description)
    if r
      m = Amatch::PairDistance.new("#{r.description}")
      q = m.match(property.description)
      if q > 0.95
        return r
      end
    end
    return nil
  end

  def calculate_price_per_sqm!
    self.price_per_sqm = self.price / self.livable_size_sqm unless self.livable_size_sqm.nil? || self.livable_size_sqm == 0
  end
end
