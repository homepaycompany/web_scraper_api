class RegexMatchers::MatcherListingLocation
  require "i18n"

  def initialize
    @fields = {
      boulevard: [
        'boulevard','boulevar', 'boullevar', 'boullevard', 'bd', 'blv', 'bvd'
      ],
      rue: [
        'rue',"r"
      ],
      avenue: [
        'avenue', 'avenu', 'av', 'avn'
      ],
      place: [
        'place', 'plc', 'p', 'plasse'
      ],
      faubourg: [
        'faubourg', 'fauxbourg', 'faubour', 'fbg', 'fbr'
      ],
      allee: [
        'allee', 'alle', 'al', 'alee'
      ],
      impasse: [
        'impasse', 'imp', 'inpasse', 'impace', 'inpasse'
      ],
      voie: [
        'voie', 'voi', 'v', 'voix'
      ]
    }
  end

  def get_sanithized_string(string)
    s = I18n.transliterate(string).downcase
    s.gsub!(/[^a-z0-9 ]/, '')
    @fields.each do |k,v|
      v.each do |w|
        s.gsub(/\W#{w}\W/, k.to_s)
      end
    end
    return s
  end
end
