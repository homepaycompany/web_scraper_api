class RemoveDuplicatePropertiesWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 1

  def perform
    duplicates = 0
    Property.where(need_to_check_for_duplicates: true).each do |property|
      begin
        prop = Property.check_for_duplicate(property)
        property.update(need_to_check_for_duplicates: false)
        if prop
          duplicates += 1
          update_and_destroy_properties(property, prop)
        end
      rescue
        p 'Issue encountered while searching for duplicate'
      end
    end
    p "#{duplicates} duplicates found and destroyed"
  end

  def update_and_destroy_properties(property_1, property_2)
    # check which property is the latest, and add its information to the oldes one
    if property_1.posted_on < property_2.posted_on
      property_1.update_listing(property_2.attributes.except("distance", "bearing"))
      p "destroying #{property_2.name}"
      property_2.destroy
    else
      property_2.update_listing(property_1.attributes.except("distance", "bearing"))
      p "destroying #{property_1.name}"
      property_1.destroy
    end
  end
end
