module RegexMatchers
  class RegexMatcher

    def initialize
      @fields = [
        {
          field: :has_elevator,
          regex:[
            "ascenseur",
            "assenceur",
            "ascenceur"
          ]
        },
        {
          field: :has_garage,
          regex: [
            "garage",
            "garag",
            "garrage"
          ]
        },
        {
          field: :has_parking,
          regex: [
            "parking",
            "parkin",
            "stationnement",
            "stationement",
            "stationnemen"
          ]
        },
        {
          field: :has_attic,
          regex: [
            "grenier",
            "grenié",
            "grennier",
            "comble",
            "combles",
          ]
        },
        {
          field: :has_pool,
          regex: [
            "piscine",
            "picine",
            "pissine"
          ]
        },
        {
          field: :sold_rented,
          regex: [
            "lou[ée]+"
          ]
        },
        {
          field: :has_balcony,
          match_field: :size_balcony_sqm,
          regex: [
            "balcon[(de)|| ]*([1-9]+,*[ ]*[1-9]*)*",
            "([1-9]+,*\.*[1-9]*)*[(de)|| ]*balcon"
          ]
        },
        {
          field: :has_terrace,
          match_field: :size_terrace_sqm,
          regex: [
            "terrasse[(de)|| ]*([1-9]+,*[ ]*[1-9]*)*",
            "terrace[(de)|| ]*([1-9]+,*[ ]*[1-9]*)*",
            "terasse[(de)|| ]*([1-9]+,*[ ]*[1-9]*)*",
            "terace[(de)|| ]*([1-9]+,*[ ]*[1-9]*)*",
            "([1-9]+,*\.*[1-9]*)*[(de)|| ]*terrasse",
            "([1-9]+,*\.*[1-9]*)*[(de)|| ]*terrace",
            "([1-9]+,*\.*[1-9]*)*[(de)|| ]*terasse",
            "([1-9]+,*\.*[1-9]*)*[(de)|| ]*terace"
          ]
        },
        {
          field: :has_cellar,
          match_field: :size_cellar_sqm,
          regex: [
            "[, ]+cave[(de)|| ]*([1-9]+,*[ ]*[1-9]*)*",
            "([1-9]+,*[ ]*[1-9]*)*[(de)|| ]*cave"
          ]
        },
        {
          match_field: :appartment_floor,
          regex: [
            "([1-9]+)[ ]*[e||è||(eme)||(ème)][^t]",
            "[é||e]tage[: ]*([1-9]+)"
          ]
        },
        {
          match_field: :num_floors,
          regex: [
            "([1-9]+)[ ]*[é||e]tages*",
            "[é||e]tages[: ]*([1-9]+)"
          ]
        },
        {
          match_field: :num_bedrooms,
          regex: [
            "([1-9]+)[ ]*chambres*",
            "chambres*[: ]*([1-9]+)",
            "(une||deux||trois||quatre||cinq||six||sept||huit||neuf||dix)[ ]*chambres*",
            "chambres*[: ]*(une||deux||trois||quatre||cinq||six||sept||huit||neuf||dix)",
          ]
        },
        {
          match_field: :num_bathrooms,
          regex: [
            "([1-9]+)[ ]*salles*[ ]*de[ ]*bains*",
            "salles*[ ]*de[ ]*bains*[: ]*([1-9]+)",
            "sdb[: ]*([1-9]+)",
            "([1-9]+)[ ]*sdb",
            "(une||deux||trois||quatre||cinq||six||sept||huit||neuf||dix)[ ]*salles*[ ]*de[ ]*bains*",
            "salles*[ ]*de[ ]*bains*[-: ]*(une||deux||trois||quatre||cinq||six||sept||huit||neuf||dix)",
            "sdb[: ]*(une||deux||trois||quatre||cinq||six||sept||huit||neuf||dix)",
            "(une||deux||trois||quatre||cinq||six||sept||huit||neuf||dix)[ ]*sdb"
          ]
        },
        {
          match_field: :agent_commission,
          regex: [
            "([1-9]+[\.,]*[1-9]*)[ ]*%"
          ]
        }
      ]
    end

    def enrich_listing_attributes(listing)
      s = "#{listing.name} #{listing.description}"
      @fields.each do |f|
        results = match_fields(s, f)
        if results
          if f[:field]
            listing.write_attribute(f[:field], true)
          end
          if f[:match_field] && results[1]
            listing.write_attribute(f[:match_field], to_float(results[1].strip.gsub(/,/, ".")))
          end
        end
      end
      listing.need_to_enrich_attributes = false
    end

    def match_fields(s, f)
      f[:regex].each do |r|
        m = s.match(/#{r}/i)
        if m
          p "Found match - #{f[:field] || f[:match_field]} : #{m} - REGEXP : #{r}"
          return m
        end
      end
      return nil
    end

    def to_float(s)
      if s.to_f != 0
        return s.to_f
      else
        case s
        when 'un'
          return 1
        when 'deux'
          return 2
        when 'trois'
          return 3
        when 'quatre'
          return 4
        when 'cinq'
          return 5
        when 'six'
          return 6
        when 'sept'
          return 7
        when 'huit'
          return 8
        when 'neuf'
          return 9
        when 'dix'
        end
      end
    end
  end
end
