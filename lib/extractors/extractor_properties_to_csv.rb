class Extractors::ExtractorPropertiesToCsv
  def initialize
  end

  def extract_properties_to_csv(properties)
    column_names = properties.first.attributes
    CSV.generate do |csv|
        csv << column_names
        properties.each do |property|
          csv << properties.attributes.values_at(*column_names)
        end
      end
    end
  end
end

