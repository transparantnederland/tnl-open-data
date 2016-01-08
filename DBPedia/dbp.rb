require 'sparql/client'
require 'csv'

$bestuur = /.*(Burgemeester|Bestuurs|Commissaris van de Koningin|Dijkgraaf|voorzitter|Gedeputeerde|Minister|Staatssecretaris|Wethouder|directeur).*/i

$header = '
PREFIX dcterms:  <http://purl.org/dc/terms/>
PREFIX categorie: <http://nl.dbpedia.org/resource/Categorie:>
PREFIX sjabloon: <http://nl.dbpedia.org/resource/Sjabloon:>
PREFIX dbpedia: <http://nl.dbpedia.org/property/>

'

$partyQ = '
select distinct ?partij ?partijuri where {
  { ?dburi dcterms:subject categorie:Eerste_Kamerlid } 
    UNION {?dburi dcterms:subject categorie:Tweede_Kamerlid} 
    UNION {?dburi dcterms:subject categorie:Nederlands_bestuurder} 
    UNION {?dburi dcterms:subject categorie:Nederlands_staatssecretaris} .
  ?dburi dbpedia-owl:party ?partijuri .
  ?partijuri rdfs:label ?partij .
  OPTIONAL { ?dburi prop-nl:overleden ?overleden }
  FILTER ( !BOUND(?overleden) )
} 
'

$peepleQ = '
select distinct ?naam ?vnaam  ?partij ?functie ?dburi ?abstract where {
  { ?dburi dcterms:subject categorie:Eerste_Kamerlid } 
    UNION {?dburi dcterms:subject categorie:Tweede_Kamerlid} 
    UNION {?dburi dcterms:subject categorie:Nederlands_bestuurder} 
    UNION {?dburi dcterms:subject categorie:Nederlands_staatssecretaris} .
  ?dburi prop-nl:naam ?naam .
  ?dburi dbpedia-owl:party <<partijuri>> .
  <<partijuri>> rdfs:label ?partij .
  ?dburi dbpedia-owl:abstract ?abstract .
  ?dburi prop-nl:functie ?functie .
  OPTIONAL { ?dburi prop-nl:volledigeNaam ?vnaam }  
  OPTIONAL { ?dburi prop-nl:overleden ?overleden }
  FILTER ( !BOUND(?overleden) )
} 
ORDER BY ?naam
'

$labelQ = 'select distinct ?label where { <<uri>> rdfs:label ?label }'


$sparql = SPARQL::Client.new("http://nl.dbpedia.org/sparql")

def peopleFromParty(party)
  return $sparql.query($header + $peepleQ.gsub('<partijuri>',"#{party}"))
end


$allParties = []
r = $sparql.query($header + $partyQ)
r.each do |p|
  $allParties << [p[:partij].to_s,p[:partijuri].to_s]
end

$functies = []


def extrFunctie(f)
  return nil if f =~ /http:\/\/nl.dbpedia.org\/resource\/Lijst_van_.*/
  if f =~ /http:\/\/nl.dbpedia.org\/resource\/.*/
    r = $sparql.query($header + $labelQ.gsub('<uri>',"#{f}"))
    r.each do |l|
      f = l[:label]
      break
    end
  end
  f
end

def consolidate(r)
  people = {}
  r.each do |m|
    uri = m[:dburi]
    people[uri] = {} if people[uri].nil?
    people[uri][:naam] = m[:naam]
    people[uri][:vnaam] = m[:vnaam]
    people[uri][:dburi] = m[:dburi]
    people[uri][:partij] = m[:partij]
    people[uri][:abstract] = m[:abstract]
    people[uri][:functie] = [] if people[uri][:functie].nil?
    f = extrFunctie(m[:functie])
    if f
      people[uri][:functie] << f 
      $functies << f
    end
  end
  return people
end

filename = 
CSV.open("dbpedia_sg_#{Time.now.strftime("%Y-%m-%d")}.csv", "wb") do |csv|
  csv << ["naam", "volledige naam", "partij", "functie", "db-uri", "abstract"]
  $allParties.each do |p|
    $stderr.puts "Get & Process #{p[0]}"
    r = consolidate( peopleFromParty(p[1]) )
    r.each do |k,v|
      v[:vnaam] = v[:naam] if v[:vnaam].nil? # 'volledige naam' is  optional in dbp
      csv << [ v[:naam], v[:vnaam], v[:partij], v[:functie].join(";"), v[:dburi], v[:abstract] ] 
    end
  end
end


File.open("parties.json","w") do |fd|
  fd.puts JSON.pretty_generate($allParties)
end

File.open("functies.json","w") do |fd|
  fd.puts JSON.pretty_generate($functies.uniq.sort)
end



