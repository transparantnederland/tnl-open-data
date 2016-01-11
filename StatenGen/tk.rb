require 'open-uri'
require 'nokogiri'
require 'json'

$doc = nil
$TK = "http://www.tweedekamer.nl"

$TK_url = "https://www.eerstekamer.nl/alle_leden"
$TK_file = "/Users/tom/Synology/Cloudstation/Dev/sg/TK_leden.html"
$TK_leden = []
$failed = []

$doc = Nokogiri::HTML(File.read($TK_file))
peeps = $doc.css("tr.member-detail-container")
peeps.each do |p|
  m = p.next.css("div.member-info")
  $TK_leden << { naam: m.css("h2").text, href: m.css("a").attr('href') }
end


def fixup(s)
  '"' + s.gsub('"','\"').gsub(/\s+/,' ').gsub(160.chr("UTF-8"),"").strip + '"'
end

File.open("./tk.csv","w") do |fd|
  fd.puts "naam, type, uri, functie"
  $TK_leden.each do |lid|
    puts "processing #{lid[:naam]}"
    begin
      $doc = Nokogiri::HTML(open($TK + lid[:href] + "/biografie" )).css("div#content-container").css("div.article").css("ul")
      opleidingen = $doc[0]
      loopbaan = $doc[1]
      count = 1
      naam = lid[:naam]
      uri = $TK + lid[:href]

      opleidingen.css("li").each do |t|
        fd.puts [naam, 'opleiding', uri+"##{count}", fixup(t.text)].join(",")
        count += 1
      end
      loopbaan.css("li").each do |t|
        fd.puts [naam, 'loopbaan', uri+"##{count}", fixup(t.text)].join(",")
        count += 1
      end
    rescue Exception => e
      puts e.message
      $failed << [e.message, lid[:naam], $TK + lid[:href] + "/biografie"]
    end
  end
end

File.open("./tk_failed.json","w") do |fd|
  fd.puts JSON.pretty_generate($failed)
end

