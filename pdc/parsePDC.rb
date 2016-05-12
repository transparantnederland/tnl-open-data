require_relative 'namenPDC'
require_relative 'xDatum'

def xPosition(s)
  sa = s.gsub(/(plaatsvervangend|waarnemend|adjunct|tijdelijk|substituut|deeltijd|parttime|interim)\W+/,'')
  sb = sa.gsub(/\W/,'')

  return 'tnl:commissioner' if sa =~ /^commissaris/i
  return 'tnl:lobbyist' if sa =~ /lobbyist/i
  return 'tnl:advisor' if sa =~ /adviseur|advisor|adviserend|formateur|verkenner|bemiddelaar/i
  return 'tnl:boardmember' if sa =~ /partner|bestuur|secretaris|directeur|voorzitter|directie|dijkgraaf|eigenares|eigenaar|penningmeester|minister|korpschef|korpsbeheerder/i
  return 'tnl:boardmember' if sb =~ /commissarisvandekoning|wethouder|president|generaal|managingdirector|burgemeester|politiekleider|rector|director|decaan/i
  return 'tnl:employee' if sb =~ /projectcordinator|werkzaambij|werkzaamin|medewerker|assistent|verpleegkundige|universitairdocent|assistant|redacteur|cordinator/i
  return 'tnl:employee' if sa =~ /^(senior|hoofd|chef)/i
  return 'tnl:employee' if sa =~ /griffier|commandant|onderwijzer|leraar|lerares|lector|journalist|inspecteur|administrat|professor|fellow|scientist|rechter/i
  return 'tnl:employee' if sb =~ /officiervanjustitie|teamleider|teamhoofd|maatschappelijkwerk|werkzaamop|werkzaamvoor|diversefuncties|presentatrice/i
  return 'tnl:employee' if sa =~ /bedrijfsjurist|columnist|ambtenaar|projectleider|manager|programmamaker|presentator|medewerkster|programmaleider|docent|staflid|staffunctionaris|hoogleraar/i
  
  return 'tnl:employee' if sa =~ /politiek\s+(analist|commentator|verslaggever|columnist)/i
  return 'tnl:spokesperson' if sa =~ /woordvoerder/i

  return 'tnl:member' if sa =~ /^lid/i
  return 'tnl:member' if sa =~ /\Wlid$/i
  return 'tnl:member' if sa =~ /\Wlid\W/i


  # return 'tnl:related' if sa =~ /ambassadeur|vrijwill|onderzoeker|consultant|jury|freelance/i
  # return 'tnl:related' if sb =~ /belastmet|actiefin|vertegenwoordiger|externdeskundige|betrokkenbij|afgevaardigde/i
  # return 'tnl:related' if sb =~ /^(gast|bescherm)/i
  #
  # return s

  return 'tnl:related'

end


def xWaarde(s)
  s = s.sub(/ˆ;od\s+/,'')
  s = s.sub(/\(.*\)/,'')
  s = s.gsub(/\s+/,' ')

  return nil if s =~ /op grond van artikel X10/i || s == ''

  
  s = s.sub(/N\.V\.\s+(.*)/,'\1 N.V.')
  s = s.sub(/B\.V\.\s+(.*)/,'\1 B.V.')
  
  s = s.sub(/Gedeputeerde\s+Staten\s+van/i,'Provincie')

  s = s.sub('lid (en voorzitter)','voorzitter')
  s = s.sub(/(\W)provincie(\W)/,'\1Provincie\2')
  s = s.sub(/ChristenUnie,? gemeenteraad van/, 'lid')

  s = s.sub(/CDA[-, ]*fractie/i, 'lid')
  s = s.sub(/CDA[-, ]*gemeenteraad van/, 'lid')
  s = s.sub(/CDA Provincie/i,'Provincie')
  s = s.sub(/CDA Provinciale Staten van/i,'Provincie')

  s = s.sub(/VVD[-, ]*fractie/i, 'lid')
  s = s.sub(/VVD[-, ]*gemeenteraad van/, 'lid')
  s = s.sub(/VVD Provincie/i,'Provincie')
  s = s.sub(/VVD Provinciale Staten van/i,'Provincie')

  s = s.sub(/GPV[-, ]*fractie/i, 'lid')
  s = s.sub(/GPV[-, ]*gemeenteraad van/, 'lid')
  s = s.sub(/GPV Provincie/i,'Provincie')
  s = s.sub(/GPV Provinciale Staten van/i,'Provincie')

  s = s.sub(/SP[-, ]*fractie/i, 'lid')
  s = s.sub(/SP[-, ]*gemeenteraad van/, 'lid')
  s = s.sub(/SP Provincie/i,'Provincie')
  s = s.sub(/SP Provinciale Staten van/i,'Provincie')

  s = s.sub(/SGP[-, ]*gemeenteraad van/i, 'lid')
  s = s.sub(/SGP Provincie/i,'Provincie')
  s = s.sub(/SGP Provinciale Staten van/i,'Provincie')

  s = s.sub(/PVDA[-, ]*fractie/i, 'lid')
  s = s.sub(/PVDA[-, ]*gemeenteraad van/i, 'lid')
  s = s.sub(/PVDA Provincie/i,'Provincie')
  s = s.sub(/PVDA Provinciale Staten van/i,'Provincie')

  s = s.sub(/PVV[-, ]*fractie/i, 'lid')
  s = s.sub(/PVV[-, ]*gemeenteraad van/i, 'lid')
  s = s.sub(/PVV Provincie/i,'Provincie')
  s = s.sub(/PVV Provinciale Staten van/i,'Provincie')

  s = s.sub(/Groenlinks[-, ]*fractie/i, 'lid')
  s = s.sub(/Groenlinks[-, ]*gemeenteraad van/i, 'lid')
  s = s.sub(/Groenlinks Provincie/i,'Provincie')
  s = s.sub(/Groenlinks Provinciale Staten van/i,'Provincie')
  
  
  s = s.sub(/Academisch Ziekenhuis te (\w+)/,'Academisch Ziekenhuis \1')
  s = s.sub(/Rijksuniversiteit te (\w+)/,'Rijksuniversiteit \1')
  s = s.sub(/Technische Hogeschool te (\w+)/,'Technische Hogeschool \1')
  s = s.sub(/Vrije Universiteit te (\w+)/,'Vrije UniversiteitCatharina Ziekenhuis \1')
  s = s.sub(/Catharina Ziekenhuis te (\w+)/,'Catharina Ziekenhuis \1')
  s = s.sub(/Shell International Oil Products te (\w+)/,'Shell International Oil Products \1')


  if s =~ /\s+te\s+([A-Z][A-Za-z-]+)$/
    $steden << $1
    # $waarden << s
    s = s.gsub(/\s+te\s+[A-Z][A-Za-z-]+$/,'')
  end


  if s =~ /(lid|voorzitter)?\s* Raad van (Commissaris|Commisaris|Commmisaris)/i
    s = s.gsub(/(lid|voorzitter)?\s* Raad van (Commissaris|Commisaris|Commmisaris)\w*/i,'commissaris')
  end
  
  if s =~ /(lid|voorzitter)?\s* Raad van Bestuur/i
    s = s.gsub(/(lid|voorzitter)?\s* Raad van Bestuur/i,'bestuur')
  end
  
  if s =~ /^Stichtingsbestuur/i
    s = s.gsub(/^Stichtingsbestuur/i,'bestuur')
  end
  
  if s =~ /(lid|voorzitter)?\s* Raad van Toezicht/i
    s = s.gsub(/(lid|voorzitter)?\s* Raad van Toezicht/i,'commissaris')
  end
  
  if s =~ /(lid|voorzitter)?\s*Raad van Advies/i
    s = s.gsub(/(lid|voorzitter)?\s* Raad van Advies/i,'adviseur')
  end
  
  return s[0].downcase + s[1..-1] if 
    s =~ /^Nederlandse (bewindvoerder|afgevaardigde)/ ||
    s =~ /^Nederlands (sectiehoofd|ambassadeur|vertegenwoordiger|afgevaardigde)/ ||
    s =~ /^Permanent Vertegenwoordiger/ ||
    s =~ /^IT\W/ ||
    s =~ /^VVD\W/ ||
    s =~ /^VVV\W/ ||
    s =~ /^Fullbright/ ||
    s =~ /^Commissaris/
    
  return s
end

$parties = [ "fnv", "cnv", "50plus", "aov", "arp", "chu", "cd", "cda", 
             "wilders", "christenunie", "d66", "gpv", "groenlinks", "lpf", 
             "leefbaar nederland", "osf", "pvv", "pvda", "pvdd", 
             "psp", "ppr", "rpf", "sgp", "sp", "unie 55+", "vvd" ]

def xType(a)
  
  return 'tnl:Public' if $steden.include?(a)
  
  ar = a.split(/\W/)

  return 'tnl:PoliticalParty' if ( $parties.include?(ar[0].downcase) and !['fnv','cnv'].include?(ar[0].downcase) )
  return 'tnl:PoliticalParty' if ( $parties.include?(ar[-1].downcase) and !['fnv','cnv'].include?(ar[-1].downcase) )

  return 'tnl:Public' if a =~ /Regionaal|Regionale|Samenwerkingsverband|Staatscommissie|Stuurgroep|Taskforce|Waterschap|Provinciale Raad|Provinciale Staten|gemeente|provincie|ministerie|ambassade|delegatie|Bibliotheek|Vertegenwoordiging|Platform|Programmaraad/i
  return 'tnl:Public' if a =~ /Burgerlijke Stand|Begeleidingscommissie|Raadgevende|Raad voor|Raad van|Provinciale|Parlementaire|Staten Generaal/i
  return 'tnl:Public' if a =~ /^onderzoek|onderwijs|Nederlandse Antillen/i
  return 'tnl:Commercial' if a =~ /(B\.V\.)|(N\.V\.)/i
  return 'tnl:Commercial' if a =~ /Productschap/i
  return 'tnl:NonProfit' if a =~ /SOS-|SOS |Hogeschool|Universiteit|Vrienden van|stichting|Adviesraad|Adviesgroep|Vereniging|Overleg|Instituut|Werkgroep/i
  return 'tnl:NonProfit' if a =~ /^Sociaal-|Sociale |Ziekenhuis/i
  
  
  return 'tnl:Organization'
end



def xOrgs(a)
  return nil if a.blank?
  return nil if a == 'Free Lance'
  return nil if a =~ /^Tweede Kamerlid/
  
  a.sub!('V&D (Vroom en Dreesman)','Vroom en Dreesman')
  a.sub!('V& D (Vroom en Dreesman)','Vroom en Dreesman')
  a.sub!('V&D','Vroom en Dreesman')
  a.sub!('V& D','Vroom en Dreesman')
  
  a.sub!(/^(.*)[ ,(]+belast met.*/) do |m|
    $1
  end

  a.sub!(/Stichting Ondersteuning,\s*(.*)/) do |m|
    "Stichting Ondersteuning #{$1}"
  end
  
  a.sub!('Verenigde Naties','VN')
  a.sub!('fractie-assistentie','fractieassistentie')
  
  return "Eerste Kamer der Staten Generaal" if a =~ /^Eerste\s+Kamer.*/
  return "Tweede Kamer der Staten Generaal" if a =~ /^Tweede\s+Kamer.*/
  
  return "KNMG" if a =~ /^KNMG.*/
  
  return "Provincie #{$1}" if a =~ /Koning in ([^\s]+)/i
  return "Provincie #{$1}" if a =~ /Koningin in ([^\s]+)/i
  
  return 'Vrije Universiteit' if a =~ /^Vrije Universiteit.*/i
  return 'Ministerie van VWS' if a =~ /Volksgezondheid.*Welzijn.*Sport.*/

  return 'Ministerie van Sociale Zaken en Werkgelegenheid' if a =~ /^Sociale Zaken en Werkgelegenheid.*/i

  return 'Ministerie van Ontwikkelingssamenwerking' if a =~ /^Ontwikkelingssamenwerking.*/i
  return 'Ministerie van Onderwijs en Wetenschappen' if a =~ /Onderwijs en Wetenschap.*/i
  return 'Ministerie van Binnenlandse Zaken' if a =~ /Binnenlandse Zaken.*/i
  return 'Ministerie van Buitenlandse Zaken' if a =~ /Buitenlandse Zaken.*/i
  return 'Ministerie van Economische Zaken' if a =~ /Economische Zaken.*/i
  return 'Ministerie van Algemene Zaken' if a =~ /Algemene Zaken.*/i
  return 'Ministerie van Justitie' if a =~ /Justitie/i

  return a if a.sub!(/.*ministerie van\s*([\w\s]+)/i) do |m|
    "Ministerie van #{$1}"
  end
  
  return $1 if a =~ /(\w+)-Tweede Kamerlid.*/
  return $1 if a =~ /.*(Rijksuniversiteit .*)/i
  return $1 if a =~ /.*(Academisch Ziekenhuis .*)/i
  return $1 if a =~ /^(.*)[ ,]+Eerste|Tweede Kamer der Staten-Generaal/

  return a if a.sub!(/.+Provincie\s+([\w-]+)/i) do |m|
    "Provincie #{$1}"
  end

  a
end

$orgsMapping = {}

def mapOrgs
  skip = []
  temp=[]
  $orgs = $orgs.compact.sort.uniq
  $orgs.each do |o|
    t = o.normalize
    $orgsMapping[t] = [] if $orgsMapping[t].nil?
    $orgsMapping[t] << o
  end 
  
  $orgsMapping.each do |k,v|
    v = v.sort {|a,b| a.length <=> b.length}
    # if v.length > 1
    #   puts ""
    #   v.each {|o| puts o}
    # end
  end
  
  STDERR.puts "Total Organizations: #{$orgs.length} / after mapping: #{$orgsMapping.keys.length}"
  
end    



def repairOrgsString(org)

  

  if org
    
    if org.scan(/["]/).count == 1
      org.sub!(/["]/,'')
    end
  
    if org.scan(/[']/).count == 1
      org.sub!(/[']/,'')
    end
  
    if org.scan(/[\(\)]/).count == 1
      org.sub!(/[\(\)]/,'')
    end
  
    org.gsub!(/\s+/,' ')
  
    org = org.sub(/^[ ,-]+(.*)/,'\1').sub(/(.*)[ ,-]+$/,'\1')

  end
  org
end


# --------------------------- start here -----------------------

$position = []
$pbodies = []
$orgs = []
$final = []
$orgsMap = {}
$steden = []
$waarden = []
$datums = []
$dlFact = 0.20

namen = NamenParser.new
STDERR.puts "parsing 'details.csv'..."

csv2arr("details.csv",{}).each do |r|
  
  if ( Integer(r[:rubriek]).between?(3130,3135) or Integer(r[:rubriek]) >= 3500 )

    TNLDate.xDatum(r)
    
    r[:validSince] = '' if r[:validSince].nil?
    r[:validUntil] = '' if r[:validUntil].nil?
    
    # next if r[:datum].blank?
    
    w = xWaarde(r[:waarde])
    next if w.nil?
    
    n = (w =~ /[A-Z]/ )
    if n 
      
      pbody = (w[0..n-1] || '').strip
      org   = (w[n..-1] || '').strip

      if pbody.scan(/"/).count == 1
        pbody.sub!('"','')
      end
      
      
      org = repairOrgsString(xOrgs(org))
      next if org.nil?
      r[:pbody] = pbody

      r[:tnl_name] = namen.namen[ r[:b1nummer] ] 
      r[:tnl_same] = namen.ids[ r[:b1nummer] ]
      r[:tnl_postition] = xPosition(pbody)
      r[:tnl_organization] = org
      r[:tnl_id] = (r[:b1nummer] + '_' + r[:waarde].nhash(8))
      
      $position << r[:tnl_postition]
      $pbodies << pbody
      $orgs << org
      $final << r.deepCopy
    end 
  end
end



$steden = $steden.compact.sort.uniq

STDERR.puts "mapping organizations..."
mapOrgs

# $pits = []
# $rels = []
#
# File.open("pits.ndjson", "r").each_line { |l| $pits << l }
# File.open("relations.ndjson", "r").each_line { |l| $rels << l }

pits_ndj = namen.pits_ndj
rels_ndj = namen.rels_ndj

$orgsCSV = []

STDERR.puts "generate relations..."
$final.each do |f|
  o = $orgsMapping[f[:tnl_organization].normalize][0]
  pits_ndj << JSON.pretty_generate(
    { 
      name: o, 
      id: o.gsub(/\W/,'').downcase,
      type: Integer(f[:rubriek]).between?(3130,3135) ? 'tnl:PoliticalParty' : xType(o) 
    }
  ).gsub(/\s+/, ' ')
  $orgsCSV << [o.gsub('\"','""'), Integer(f[:rubriek]).between?(3130,3135) ? 'tnl:PoliticalParty' : xType(o) , o.gsub(/\W/,'').downcase]
end


STDERR.puts "generate pits..."
$final.each do |f|
  
  p = { 
      name: f[:tnl_name], 
      id: f[:tnl_id],
      type: 'tnl:Person',
      data: {
        b1nummer: f[:b1nummer],
        datum: f[:datum],
        waarde: f[:waarde],
        rubriek: f[:rubriek]
      }
  }
  p[:validSince] = f[:validSince] if not f[:validSince].blank?
  p[:validUntil] = f[:validUntil] if not f[:validUntil].blank?

  pits_ndj << JSON.pretty_generate(p).gsub(/\s+/, ' ')
  rels_ndj << JSON.pretty_generate(
    { 
      from: f[:tnl_id], 
      to:   f[:tnl_same],
      type: 'tnl:same'
    }
  ).gsub(/\s+/, ' ')

  rels_ndj << JSON.pretty_generate(
    { 
      from: f[:tnl_id], 
      to:   $orgsMapping[f[:tnl_organization].normalize][0].gsub(/\W/,'').downcase,
      type: f[:tnl_postition]
    }
  ).gsub(/\s+/, ' ')
  
end


STDERR.puts "write pits..."
pits_ndj = pits_ndj.compact.sort.uniq
File.open("pdc.pits.ndjson","w") do |fd|
  pits_ndj.each { |p| fd.puts(p) }
end

STDERR.puts "write relations..."
rels_ndj = rels_ndj.compact.sort.uniq
File.open("pdc.relations.ndjson","w") do |fd|
  rels_ndj.each { |p| fd.puts(p) }
end


File.open("organisaties.csv","w") do |fd|
  fd.puts("naam, type, id")
  $orgsCSV.sort.uniq.each do |o|
    fd.puts('"'+o[0]+'",'+o[1]+','+o[2])
  end
end


#
#
#
# File.open("details_transformed.json","w") do |fd|
#   fd.puts( JSON.pretty_generate($final) )
# end
#
#
# $pbodies = $pbodies.compact.sort.uniq
# $position = $position.compact.sort.uniq
#

# File.open("position.json","w") do |fd|
#   fd.puts( JSON.pretty_generate($position) )
# end

# File.open("steden.json","w") do |fd|
#   fd.puts( JSON.pretty_generate($steden) )
# end
#
# File.open("waarden.json","w") do |fd|
#   fd.puts( JSON.pretty_generate($waarden) )
# end
#
#
# File.open("eqv_organisaties.txt","w") do |fd|
#   $orgsMapping.each do |k,v|
#     if v.length > 1
#       v.each { |vv| fd.puts vv }
#       fd.puts
#     end
#   end
# end


#
#
# File.open("organisaties.csv","w") do |fd|
#   fd.puts "name,type"
#   $orgsMap.values.sort.uniq.each do |o|
#     type = xType(o)
#     o.gsub('"','""')
#     fd.puts "\"#{o}\",#{type}" # if not ['tnl:PoliticalParty','tnl:Public','tnl:NonProfit'].include?(type)
#   end
# end
#

