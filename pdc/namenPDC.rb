require_relative 'csv2arr'

# pdc/tweedekamer
# pdc/eerstekamer

class NamenParser
  attr_reader :ids, :namen, :pits_ndj, :rels_ndj
  
  Posten_in_kabinetten = {
   "Algemene Zaken" => "Ministerie van Algemene Zaken",
   "belast met coördinatie van aangelegenheden de Nederlandse Antillen en Aruba betreffend en met de zorg voor aan de Nederlandse Antillen en Aruba te verlenen hulp en bijstand" => "Ministerie van Binnenlandse Zaken",
   "Binnenlandse Zaken" => "Ministerie van Binnenlandse Zaken",
   "Buitenlandse Zaken" => "Ministerie van Buitenlandse Zaken",
   "Binnenlandse Zaken en Koninkrijksrelaties" => "Ministerie van Binnenlandse Zaken",
   "Defensie" => "Ministerie van Defensie",
   "Economische Zaken" => "Ministerie van Economische Zaken",
   "Economische Zaken, Landbouw en Innovatie" =>  "Ministerie van Economische Zaken",
   "Financiën" => "Ministerie van Financiën",
   "Infrastructuur en Milieu" => "Ministerie van Infrastructuur en Milieu",
   "Justitie" => "Ministerie van Justitie", 
   "Landbouw, Natuur en Voedselkwaliteit" => "Ministerie van Landbouw, Natuurbeheer en Visserij",
   "Landbouw, Natuurbeheer en Visserij" => "Ministerie van Landbouw, Natuurbeheer en Visserij",
   "minister voor Bestuurlijke vernieuwing en Koninkrijksrelaties" => "Ministerie van Binnenlandse Zaken",
   "minister voor Buitenlandse Handel en Ontwikkelingssamenwerking" => "Ministerie van Buitenlandse Zaken",
   "minister voor Grotesteden- en Integratiebeleid" => "Ministerie van Grotesteden- en Integratiebeleid",
   "minister voor Immigratie en Asiel" => "Ministerie van Justitie", 
   "minister voor Immigratie, Integratie en Asiel" => "Ministerie van Justitie", 
   "minister voor Integratie, Preventie, Jeugdbescherming en Reclassering" => "Ministerie van Justitie", 
   "minister voor Jeugd en Gezin" => "Ministerie van Volksgezondheid, Welzijn en Sport", 
   "minister voor Ontwikkelingssamenwerking" => "Ministerie van Ontwikkelingssamenwerking", 
   "minister voor Vreemdelingenzaken en Integratie" => "Ministerie van Justitie", 
   "minister voor Wonen en Rijksdienst" => "Ministerie van Binnenlandse Zaken",
   "minister voor Wonen, Wijken en Integratie" => "Ministerie van Binnenlandse Zaken",
   "Minister-President" => "Ministerie van Algemene Zaken",
   "Onderwijs, Cultuur en Wetenschap" => "Ministerie van Onderwijs, Cultuur en Wetenschap",
   "Onderwijs, Cultuur en Wetenschap(pen)" => "Ministerie van Onderwijs, Cultuur en Wetenschap",
   "Sociale Zaken en Werkgelegenheid" => "Ministerie van Sociale Zaken en Werkgelegenheid",
   "Veiligheid en Justitie" => "Ministerie van Justitie", 
   "Verkeer en Waterstaat" => "Ministerie van Verkeer en Waterstaat", 
   "Viceminister-president" => "Ministerie van Algemene Zaken",
   "Volksgezondheid, Welzijn en Sport" => "Ministerie van Volksgezondheid, Welzijn en Sport",
   "Volkshuisvesting, Ruimtelijke Ordening en Milieubeheer" => "Ministerie van VROM"
  }

  Functie = {
    "1e kamerlid" => {type: "tnl:member", to: "eerstekamer"},
    "2e kamerlid"  => {type: "tnl:member", to: "tweedekamer"},
    "voorzitter Eerste Kamer der Staten-Generaal"  => {type: "tnl:boardmember", to: "eerstekamer"},
    "voorzitter Tweede Kamer der Staten-Generaal"  => {type: "tnl:boardmember", to: "tweedekamer"},

    "minister" => {type: "tnl:boardmember"},
    "staatssecretaris" =>  {type: "tnl:boardmember"}
  }

  def self.functie(s)
    s = Functie[s] 
    s = s.deepCopy if s
    s 
  end

  def self.naam(row)
   (row[:roepnaam] + ' ' + row[:prepositie] + ' ' + row[:achternaam]).gsub(/\s+/,' ')
  end

  def self.id(row)
   h = naam(row) + row[:partijenfracties] + row[:functie] + row[:bijzondere_functies] + row[:posten_in_kabinetten] + row[:begin_periode] + row[:einde_periode]
   row[:b1nummer] + '_' + h.nhash(8)
  end


  def initialize
    
    @previous = {}
    @rels = []
    @pits = []
    @orgs = ['Eerste Kamer der Staten Generaal', 'Tweede Kamer der Staten Generaal']
    @parties = []
    
    @namen = {}
    @ids = {}
    @pits_ndj = []
    @rels_ndj = []
    
    if not ( File.exists?("./namen.csv") and File.exists?("./details.csv") )
      STDERR.puts "need both 'namen.csv' and 'details.csv' to do anything.."
      exit(-1)
    end


    STDERR.puts "parsing 'namen.csv'..."
    namen = csv2arr("namen.csv",{})
    namen.each do |i|
      org = ''
      
      @ids[i[:b1nummer]] = NamenParser.id(i)
      @namen[i[:b1nummer]] = NamenParser.naam(i)
      
      e = Hash.new
      e[:name] = @namen[i[:b1nummer]]
      e[:id] = @ids[i[:b1nummer]]
      e[:type] = 'tnl:Person'
      e[:validSince] = i[:begin_periode]
      e[:validUntil] = i[:einde_periode]
      e[:validUntil] = "2099-12-31" if e[:validUntil].blank?
      e[:data] = i.deepCopy
      e[:data].delete(:begin_periode)
      e[:data].delete(:einde_periode)

      @pits << e
  
      if @previous[i[:b1nummer]]
        @rels << {from: e[:id], to: @previous[i[:b1nummer]], type: 'tnl:same' }
      else
        @previous[i[:b1nummer]] = e[:id]
      end
  
      if not i[:partijenfracties].blank?
         @parties << i[:partijenfracties]
         @rels << {from: e[:id], to: i[:partijenfracties].gsub(/\W/,'').downcase, type: 'tnl:member' }
      end
  
  
      if not i[:posten_in_kabinetten].blank?
        org = Posten_in_kabinetten[ i[:posten_in_kabinetten] ]
        @orgs << org
      end
  
      rel = NamenParser.functie(i[:functie])
      if rel
        rel[:from] = e[:id]
        if rel[:to].blank?
          rel[:to] = org.gsub(/\W/,'').downcase
        end
        @rels << rel
      end
    end

    @pits.each do |p|
      @pits_ndj << JSON.pretty_generate(p).gsub(/\s+/,' ')
    end

    @orgs = @orgs.sort.uniq
    @orgs.each do |o|
      p = {name: o, id: o.gsub(/\W/,'').downcase, type: 'tnl:Public' }
      @pits_ndj << JSON.pretty_generate(p).gsub(/\s+/,' ')
    end

    @parties = @parties.sort.uniq

    @parties.each do |o|
      p = {name: o, id: o.gsub(/\W/,'').downcase, type: 'tnl:PoliticalParty' }
      @pits_ndj << JSON.pretty_generate(p).gsub(/\s+/,' ')
    end
    
    @rels.each do |p|
      @rels_ndj << JSON.pretty_generate(p).gsub(/\s+/,' ')
    end

  end

end # class

