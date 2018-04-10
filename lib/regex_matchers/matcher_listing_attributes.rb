class RegexMatchers::MatcherListingAttributes
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
          "stationnemen",
          "places*(?:en| )*sous-sol"
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
          "balcon(?:de| )*@NUM_SQM@?",
          "[^A-Za-z0-9_]+@NUM_SQM@?[ ]?(?:de| )*balcon"
        ]
      },
      {
        field: :has_terrace,
        match_field: :size_terrace_sqm,
        regex: [
          "terrasse(?:de| )*@NUM_SQM@?",
          "terrace(?:de| )*@NUM_SQM@?",
          "terasse(?:de| )*@NUM_SQM@?",
          "terace(?:de| )*@NUM_SQM@?",
          "[^A-Za-z0-9_]+@NUM_SQM@?[ ]?(?:de| )*terrasse",
          "[^A-Za-z0-9_]+@NUM_SQM@?[ ]?(?:de| )*terrace",
          "[^A-Za-z0-9_]+@NUM_SQM@?[ ]?(?:de| )*terasse",
          "[^A-Za-z0-9_]+@NUM_SQM@?[ ]?(?:de| )*terace"
        ]
      },
      {
        field: :has_cellar,
        match_field: :size_cellar_sqm,
        regex: [
          "[, ]+cave(?:de| )*@NUM_SQM@?",
          "[^A-Za-z0-9_]+@NUM_SQM@?(?:de| )*cave"
        ]
      },
      {
        match_field: :appartment_floor,
        regex: [
          "au[ ]?@NUM_RANK@",
          "[^A-Za-z0-9_]+@NUM_RANK@(?:et dernier| )*[ée]tage",
        ]
      },
      {
        match_field: :num_floors,
        regex: [
          "[^A-Za-z0-9_]+@NUM_INT@[ ]?[ée]tages*",
          "[ée]tages[-: ]+([1-9]+)"
        ]
      },
      {
        match_field: :num_bedrooms,
        regex: [
          "[^A-Za-z0-9_]+@NUM_RANK@?[ ]?chambres*",
          "chambres*[-: ]+([1-9]+)[^A-Za-z0-9_]",
          "[^A-Za-z0-9_]+@NUM_LIT@[ ]?chambres*",
          "chambres*[-: ]+@NUM_LIT@[^A-Za-z0-9_]",
        ]
      },
      {
        match_field: :num_bathrooms,
        regex: [
          "[^A-Za-z0-9_]+@NUM_RANK@?[ ]?salles*(?:de| )?bains*",
          "salles*(?:de| )?bains*[-: ]+@NUM_INT@[^A-Za-z0-9_]",
          "sdb[-: ]+@NUM_INT@[^A-Za-z0-9_]",
          "[^A-Za-z0-9_]+@NUM_RANK@?[ ]?sdb",
          "[^A-Za-z0-9_]+@NUM_LIT@[ ]?salles*(?:de| )?bains*",
          "salles*(?:de| )?bains*[-: ]+@NUM_LIT@[^A-Za-z0-9_]",
          "sdb[-: ]+@NUM_LIT@[^A-Za-z0-9_]",
          "[^A-Za-z0-9_]+@NUM_LIT@[ ]?sdb"
        ]
      },
      {
        match_field: :agent_commission,
        regex: [
          "NUM_FLOAT[ ]?%"
        ]
      }
    ]
    # Match groups for numbers
    @match_groups = {
      num_int: "([1-9]+)",
      num_float: "([1-9]+[1-9,. ]*)",
      num_rank: "([1-9]+)[ ]?(?:e|er|ere|ère|è|nd|eme|ème|me|°|#)",
      num_lit: "(une|deux|trois|quatre|cinq|six|sept|huit|neuf|dix|(?:prem|deux|trois|quatr|cinq|six|sept|huit|neuv|dix)(?:ie|ier|iere|ière|ieme|ième))",
      num_sqm: "([1-9]+[1-9,. ]*)?[ ]?(?:m|M|mètre|metre)s?[2²]?"
    }
  end

  def enrich_listing_attributes(listing)
    s = "#{listing.name} #{listing.description}"
    @fields.each do |f|
      result = match_fields(s, f)
      if result
        if f[:field]
          p "writing #{f[:field]} = true"
          listing.write_attribute(f[:field], true)
        end
        if f[:match_field] && result > 0
          p "writing #{f[:match_field]} = #{result}"
          listing.write_attribute(f[:match_field], result)
        end
      end
    end
    listing.need_to_enrich_attributes = false
  end

  def match_fields(s, f)
    match_array = []
    f[:regex].each do |r|
      m = s.scan(/#{insert_match_group(r)}/i)
      if m.first
        p "Found match - #{f[:field] || f[:match_field]} : #{m} - REGEXP : #{insert_match_group(r)}"
        match_array << m
      end
    end
    if match_array.length != 0
      return get_highest_match(match_array.flatten.uniq)
    else
      return nil
    end
  end

  def insert_match_group(r)
    match_group = '@([A-Z_]+)@'
    m = r.match(/#{match_group}/)
    if m
      fragment = @match_groups[m[1].downcase.to_sym]
      return r.gsub(/#{match_group}/, fragment)
    else
      return r
    end
  end

  def get_highest_match(match_array)
    high_match = []
    match_array.each do |m|
      m.nil? ? (high_match << 1) : (high_match << to_float(m.strip.downcase.gsub(/,/, ".")))
    end
    return high_match.flatten.uniq.max
  end

  def to_float(s)
    if s.to_f != 0
      return s.to_f
    else
      case s
      when 'un'
        return 1
      when 'une'
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
        return 10
      else
        return 1
      end
    end
  end
end
