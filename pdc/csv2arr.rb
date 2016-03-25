require 'csv'
require './util.rb'
require 'charlock_holmes'

def guessColSep(f)
  a = f.gets
  b = f.gets
  c = f.gets
  [";","\t","|"].each do |s|
    return s if (a.split(s).length == b.split(s).length) and (a.split(s).length == c.split(s).length) and b.split(s).length > 1
  end
  ','
end

def csv2arr(path, workspace={})
  content = ''
  
  begin
    File.open(path, "r:bom|utf-8") do |fd|
      content = fd.read
    end
    unless workspace[:utf8_fixed]
      detect = CharlockHolmes::EncodingDetector.detect(content)
      content =	CharlockHolmes::Converter.convert(content, detect[:encoding], 'UTF-8') if detect
    end
    content = content.force_encoding('utf-8')
    content= content.gsub(/\r\n?/, "\n").gsub('\"','"""')
    workspace[:colsep] = guessColSep(StringIO.new(content)) unless workspace[:colsep]
    csv = CSV.new(content, :col_sep => workspace[:colsep], :skip_blanks =>true, :headers => true, :header_converters => :symbol)
    a = csv.to_a.map {|row| row.to_hash }
    workspace[:keys] = a[0].keys.dup
    return a
  rescue Exception => e
    $stderr.puts "Exception: #{e.message}"
    throw(e)
  end
end


if __FILE__ == $0
  a = csv2arr(ARGV[0],{})
  puts( JSON.pretty_generate(a) )
end

