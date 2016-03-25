# [
#   "/(omstreeks: DD-DD-DDDD)/",
#   "/(omstreeks: DD-DD-DDDD)/(DD-DD-DDDD)",
#   "/(omstreeks: DD-DD-DDDD)/(DD-DD-DDDD)/",
#   "/(omstreeks: DD-DD-DDDD)/DD-DD-DDDD",
#   "/DD-DD-DDDD",
#   "DD-DD-DDDD",
#   "DD-DD-DDDD/",
#   "DD-DD-DDDD/(DD-DD-DDDD)",
#   "DD-DD-DDDD/(DD-DD-DDDD)/",
#   "DD-DD-DDDD/DD-DD-DDDD"
# ]

module TNLDate

  MonthDays = ['31','28','31','30','31','30','30','31','30','31','30','31']

  def TNLDate.makeStart(d,m,y)
    d = '01' if d == '00' 
    m = '01' if m == '00' 
    "#{y}-#{m}-#{d}"
  end

  def TNLDate.makeEnd(d,m,y)
    m = '12' if m == '00' 
    d = MonthDays[m.to_i-1] if d == '00' 
    "#{y}-#{m}-#{d}"
  end
  
  def TNLDate.makeStartEind(d,m,y)
    if m == '00'
      return "#{y}-01-01", "#{y}-12-31"
    end
    return "#{y}-#{m}-01", "#{y}-#{m}-#{MonthDays[m.to_i-1]}"
  end

  def TNLDate.xDatum(r)
    r[:datum].sub!('05-67-1974','05-07-1974')
    
    case r[:datum]
    when /^\/\(omstreeks: (\d\d)-(\d\d)-(\d\d\d\d)\)\/\((\d\d)-(\d\d)-(\d\d\d\d)\)\/$/,
         /^\/\(omstreeks: (\d\d)-(\d\d)-(\d\d\d\d)\)\/\((\d\d)-(\d\d)-(\d\d\d\d)\)$/,
         /^\/\(omstreeks: (\d\d)-(\d\d)-(\d\d\d\d)\)\/(\d\d)-(\d\d)-(\d\d\d\d)$/,
         /^(\d\d)-(\d\d)-(\d\d\d\d)\/\((\d\d)-(\d\d)-(\d\d\d\d)\)\/$/,
         /^(\d\d)-(\d\d)-(\d\d\d\d)\/\((\d\d)-(\d\d)-(\d\d\d\d)\)$/,
         /^(\d\d)-(\d\d)-(\d\d\d\d)\/(\d\d)-(\d\d)-(\d\d\d\d)$/
      r[:validUntil]  = makeEnd($4,$5,$6)
      r[:validSince] = makeStart($1,$2,$3)
    when /^\/\(omstreeks: (\d\d)-(\d\d)-(\d\d\d\d)\)\/$/,
         /^\/(\d\d)-(\d\d)-(\d\d\d\d)$/,
         /^(\d\d)-(\d\d)-(\d\d\d\d)$/
        r[:validSince], r[:validUntil]  = makeStartEind($1,$2,$3)
    when  /^(\d\d)-(\d\d)-(\d\d\d\d)\/$/
      r[:validSince] = makeStart($1,$2,$3)
      r[:validUntil] = "2099-12-31"
    end
  end

end