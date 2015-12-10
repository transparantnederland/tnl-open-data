require 'ox'
require 'zlib'
require_relative 'person'

$plurals = {
  :organisatie => :organisaties, 
  :functie => :functies, 
  :medewerker => :medewerkers,
  :gemeente => :gemeenten,
  :contactpagina => :contactpaginas
}

$orgs = []
$mwrk = []
$edges = []
$all = {}

def addr2string(a)
  return a ? "#{a[:adres][:postbus] ? a[:adres][:postbus] : a[:adres][:straat]}; #{a[:adres][:postcode]}; #{a[:adres][:plaats]}" : ''
end

$parties = {}

def parseFuncties(f,orgId)
  functie = f[:naam].strip
    .gsub(/wr?nd\.?/i,'Waarnemend')
    .gsub(/plv\.?/i,'Plaatsvervangend')
    
  if (f[:medewerkers] and (f[:medewerkers].length > 0))
    f[:medewerkers].each do |m|

		$edges << rel = {
	      type: 'tnl:related',
	      from: m[:systemId],
	      to: orgId
	    }
      
		m[:functie] = functie
		m[:postAdres] = addr2string(m[:contact][:postAdres])
		m[:bezoekAdres] = addr2string(m[:contact][:bezoekAdres])
		m[:internet] = m[:contact][:internet]
		m[:emailadres] = m[:contact][:emailadres]
    if m[:partij]
      $parties[m[:partij]] = [] if $parties[m[:partij]].nil?
      $parties[m[:partij]] << m[:systemId]
    end
    m[:person] = Person.new(m[:naam])
		m.delete(:contact)
		$mwrk << m
    end
  end
end

def recurseOrg(type,o,sID)
  o[:parentId] = sID
  if (o[:organisaties] and (o[:organisaties].length > 0))
    o[:organisaties].each do |oo|
      recurseOrg(type,oo,o[:systemId])
    end
  end
  o.delete :organisaties

  if (o[:functies] and (o[:functies].length > 0))
    o[:functies].each do |f|
      parseFuncties(f,o[:systemId])
    end
  end
  o.delete :functies

  o[:type] = type
  o[:postAdres] = addr2string(o[:contact][:postAdres])
  o[:bezoekAdres] = addr2string(o[:contact][:bezoekAdres])
  o[:internet] = o[:contact][:internet]
  o[:emailadres] = o[:contact][:emailadres]
  o.delete(:contact)
  $orgs << o
end

class LibHandler < ::Ox::Sax

  def name2sym(n)
    if n =~ /^p\:/
      return (n.to_s.split(':')[1]).to_sym  
    end
    nil
  end

  def initialize
    @names = []
    @structs = []
    @h = $all
    @symb = nil
  end

  def start_element(name)

    return unless (name = name2sym(name))
    @names << name
    # $stderr.puts "SE: #{name}"
    
    case name 
      when :organisaties, :functies, :medewerkers, :gemeenten, :contactpaginas
        @h[name] = []
        @structs << @h
        @h = {}
      when :overheidsorganisaties, :contact, :bezoekAdres, :adres, :postAdres
        @structs << @h
        @h = {}
      when :organisatie, :gemeente, :medewerker, :functie, :contactpagina
        @h = {}
      else
        @symb = name
    end
  end

  def end_element(name)
    return unless (name = name2sym(name))
    # $stderr.puts "EE: #{name}"
    
    case name
    when :overheidsorganisaties, :contact, :bezoekAdres, :adres, :postAdres
      n = @structs.pop
      n[name] = @h
      @h = n
    when :organisaties, :functies, :medewerkers, :gemeenten, :contactpaginas
      @h = @structs.pop
    when :organisatie, :functie, :medewerker, :gemeente, :contactpagina
      arr = $plurals[name]
      n = @structs[-1]
      
      if n[arr]
        n[arr] << @h
      else
        $stderr.puts "Unopened ARRAY: #{arr}"
        $stderr.puts JSON.pretty_generate(n)
        exit!
      end
      @h = {}
    end
    @symb = @names.pop
  end

  def attr(name, value)
    # $stderr.puts "ATTR: #{name} => #{value}"
  end

  def text(value)
    @h[@symb] = value
  end

end


if not File.exists? ARGV[0]
  $stderr.puts "usage: ruby parseOO.rb <xml file>"
  exit(0)
end


$stderr.puts "Parsing '#{ARGV[0]}'"
handler = LibHandler.new
Ox.sax_parse(handler, File.open(ARGV[0]))

$stderr.puts "Writing json file"
File.open "oo.json","w" do |f|
  f.puts JSON.pretty_generate( $all )
end

$stderr.puts "Extracting organisations"
$all[:overheidsorganisaties][:organisaties].each do |o|
  recurseOrg(:overheidsorganisatie,o,-1)
end

$stderr.puts "Extracting municipalities"
$all[:overheidsorganisaties][:gemeenten].each do |o|
  recurseOrg(:gemeente, o,-1)
end


$names = {}
$orgs.each do |o|
  if $names[o[:naam]]
    $edges << {
      type: 'tnl:same',
      from: o[:systemId],
      to: $names[o[:naam]]
    }
  else
    $names[o[:naam]] = o[:systemId]
  end
  $edges << {
    type: 'tnl:parent',
    from: o[:systemId],
    to: o[:parentId]
  } if ( o[:parentId] && o[:parentId].to_i != -1)
end
$names = {}
$mwrk.each do |o|
  if $names[o[:naam]]
    $edges << {
      type: 'tnl:same',
      from: o[:systemId],
      to: $names[o[:naam]]
    }
  else
    $names[o[:naam]] = o[:systemId]
  end
end


$parties.each_key do |p|
  o = {}
  o[:type] = :politicalparty
  o[:naam] = p
  o[:systemId] = "pp_#{Zlib::crc32(p)}"
  $orgs << o
  $parties[p].each do |m|
    $edges << {
      type: 'tnl:member',
      from: m,
      to: o[:systemId]
    }
  end
end



# $stderr.puts "Writing names"
# File.open "names.txt","w" do |f|
#   $mwrk.each do |m|
#     f.puts m[:person][:name]
#   end
# end
#
#
# $stderr.puts "Writing functies"
# $functies = []
# $mwrk.each do |m|
#   $functies << m[:functie].capitalize
# end
# File.open "functies.txt","w" do |f|
#   $functies = $functies.uniq.sort
#   $functies.each do |u|
#     f.puts u
#   end
# end
#
# $stderr.puts "Writing organisaties.json"
# File.open "organisaties.json","w" do |f|
#   f.puts JSON.pretty_generate( $orgs )
# end
#
# $stderr.puts "Writing mensen.json"
# File.open "mensen.json","w" do |f|
#   f.puts JSON.pretty_generate( $mwrk )
# end
#
#

$stderr.puts "Writing nodes"

File.open "./overheidsorganisaties/overheidsorganisaties.pits.ndjson", "w" do |f|
  $orgs.each do |o|
    node = {}
    node[:name] = o[:naam]
    node[:id] = o[:systemId]
    node[:type] = (o[:type] == :politicalparty) ? 'tnl:PoliticalParty' : 'tnl:Public'
    node[:data] = o
    s = JSON.pretty_generate(node)
    f.puts s.gsub(/\s+/,' ')
  end

  $mwrk.each do |o|
    node = {}
    node[:name] = o[:person].name
    node[:id] = o[:systemId]
    node[:type] = 'tnl:Person'
    node[:data] = o[:person].to_hash
    s = JSON.pretty_generate(node)
    f.puts s.gsub(/\s+/,' ')
  end
end


# mwk1 = 0
# while mwk1 < $mwrk.length  do
#   if $mwrk[mwk1][:seen].nil?
#     o = $mwrk[mwk1][:person]
#     puts ""
#     puts $mwrk[mwk1][:naam] + " (#{mwk1}/#{$mwrk.length})"
#     mwk2 = mwk1 + 1
#     while mwk2 < $mwrk.length  do
#       if o.similar($mwrk[mwk2][:person]) < 20
#         puts "\t\t#{$mwrk[mwk2][:naam]}"
#         $edges << {
#           type: 'same',
#           source: o[:systemId],
#           target: $mwrk[mwk2][:systemId]
#         }
#         $mwrk[mwk2][:seen] = true
#       end
#       mwk2 += 1
#     end
#   end
#   mwk1 += 1
# end


$stderr.puts "Writing edges"

File.open "./overheidsorganisaties/overheidsorganisaties.relations.ndjson", "w" do |f|
  $edges.each do |e|
    f.puts e.to_json
  end

  $orgs.each do |o|
    if o[:parentId] && o[:parentId] != -1
      rel = {
        type: 'tnl:parent',
        from: o[:systemId],
        to: o[:parentId]
      }
      f.puts rel.to_json
    end
  end
end



