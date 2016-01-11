require 'open-uri'
require 'nokogiri'
require 'json'

$doc = nil

$EK="https://www.eerstekamer.nl"
$EK_url = "https://www.eerstekamer.nl/alle_leden"
$EK_file = "/Users/tom/Synology/Cloudstation/Dev/sg/EK_leden.html"
$EK_leden = []
$failed = []

$doc = Nokogiri::HTML(File.read($EK_file))
# $doc = Nokogiri::HTML(open($EK_url))
peeps = $doc.css("div.pasfoto_tekst_k1")
peeps.each do |p|
  anchors = p.css("a")
  $EK_leden << { naam: anchors[1].text, href: anchors[1].attr('href') }
end

def fixup(s)
  '"' + s.gsub('"','\"').gsub(/\s+/,' ').gsub(160.chr("UTF-8"),"").strip + '"'
end

File.open("./ek.csv","w") do |fd|
  fd.puts "naam, type, uri, functie"
  $EK_leden.each do |lid|
    puts "processing #{lid[:naam]}"
  
    begin
      $doc = Nokogiri::HTML(open($EK + lid[:href] )).css("div#main_article")

      opleidingen = $doc.css("div#tekst3")
      loopbaan = $doc.css("div#tekst4")
      nevenfuncties = $doc.css("div#tekst5")

      naam = lid[:naam]
      uri = $EK + lid[:href]

      count = 1

      opleidingen.css("div.opsomtekst").each do |t|
        fd.puts [naam, 'opleiding', uri+"##{count}", fixup(t.text)].join(",")
        count += 1
      end
      loopbaan.css("div.opsomtekst").each do |t|
        fd.puts [naam, 'loopbaan', uri+"##{count}", fixup(t.text)].join(",")
        count += 1
      end
      nevenfuncties.css("div.opsomtekst").each do |t|
        fd.puts [naam, 'nevenfuncties', uri+"##{count}", fixup(t.text)].join(",")
        count += 1
      end
    rescue
      $failed << [lid[:naam], $EK + lid[:href]]
    end
  end
end


File.open("./ek_failed.json","w") do |fd|
  fd.puts JSON.pretty_generate($failed)
end

