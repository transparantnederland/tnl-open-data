require 'text'
require 'json'

class Person
  attr_reader :p
  
  @@adel = %w{ jhr baron barones }
  @@sexm = %w{ heer dhr hr jhr baron }
  @@sexf = %w{ ms mw mvr mevrouw mevr barones }
  @@etitles = %w{ MBA MA MSC BSC MS BS MPA MCM MPM BED Bc MEM BBA EMSD RA RC MBA-H MHA MJur CMA CPC RO EMTP AC EMPM CGEIT MMAS MCM}
  @@titles = %w{ mr ds dr drs ing ir prof arts }
  @@ranks  = %w{ ltgenmarns lkolmarns lgen ltgen ltz1 majmarns ltz sgtlda ktzar ltza wmr1 sgt1 sgt ltkolmarns adj aoo bgen cdr cdra cdre sbn ritm maj ltzsd ltz2oc ltkol lkol ktza ktz kolmarns kol ltkolmarnsl kltze kltzar kltza kltz kap genmaj genm gen elnt }
  @@tussenvoegsels = ["van den", "van der", "van de", "van", "der", "den", "ten", "de", "v.d.", "vd", "à", "'t"]  
  # Köseoglu
  
  
  def to_hash
    @r = @p.dup
    @r.delete(:input)
    @r
  end
  
  def name
    res = ""
    if @p[:titles].length > 0
      res = @p[:titles].join(" ")
    end
    if @p[:initials].length > 0
      res += " " + @p[:initials].join(". ") + "."
    elsif @p[:firstnames]
      res += " " + @p[:firstnames].join(" ")
    end
    res = res + " #{@p[:tussenv].join(' ')}" if @p[:tussenv].length > 0
    res = res + " #{@p[:name]}"
    res
  end
  
  def doInitials(n)
    loop do 
      b = true
      if n =~ /^([[:alpha:]])\.?\(([[:alpha:]]+)\)\W/i
        @p[:initials] << $1.upcase
        @p[:firstnames] << $2.downcase.capitalize
        n = n.gsub(/^[[:alpha:]]\.?\([[:alpha:]]+\)\.?/i,'').strip
        b = false
      elsif n =~ /^([[:alpha:]])[^[:alpha:]]/i
        @p[:initials] << $1.upcase
        n = n.gsub(/^([[:alpha:]])[^[:alpha:]]/i,'').strip
        b = false
      elsif n =~ /^(th|tj|ij|joh|ph|ch)\W/i
        @p[:initials] << $1[0].upcase
        n = n.gsub(/^(th|tj|ij|joh|ph|ch)\.?/i,'').strip
        b = false
      end
      break if b
    end
    if n=~ /\((.+)\).+/
      @p[:firstnames] << $1.downcase.capitalize
      n = n.gsub(/^\(.*\)/,'').strip
    end
    n
  end
  
  def doSexes(n)
    @@sexm.each do |s|
      if n =~ /^#{s}\W/i
        n = n.gsub(/^#{s}\.?/i,'').strip 
        @p[:sex] = 'm'
        break
      end
      if n =~ /,\s*#{s}\.?$/i
        n = n.gsub(/,\s*#{s}\.?$/i,'').strip 
        @p[:sex] = 'm'
        break
      end
    end
    @@sexf.each do |s|
      if n =~ /^#{s}\W/i
        n = n.gsub(/^#{s}\.?/i,'').strip
        @p[:sex] = 'f'
        break
      end
      if n =~ /,\s*#{s}\.?$/i
        n = n.gsub(/,\s*#{s}\.?$/i,'').strip 
        @p[:sex] = 'f'
        break
      end
    end
    n
  end
  
  def doAdel(n)
    @@adel.each do |s|
      if n =~ /^#{s}[^[:alpha:]]/i
        n = n.gsub(/^#{s}\.?/i,'').strip
        @p[:titles] << s
        break
      end
    end
    n
  end
  
  def doETitles(n)
    loop do
      b = true
      @@etitles.each do |t|
        if n =~ /\s+#{t},?$/i
          n = n.gsub(/\s+#{t},?$/i,'').strip
          @p[:etitles] << t
          b = false
        end
      end
      break if b
    end
    n
  end
  
  
  def doTusenvoegsels(n)
    @@tussenvoegsels.each do |t|
      if n =~ /^#{t}\s+/i
        n = n.gsub(/^#{t}/i,'').strip
        @p[:tussenv] << t =~ /(v.d.)|(vd)/ ? 'van der' : t
      elsif n =~ /,\s*#{t}$/i
        n = n.gsub(/,\s*#{t}$/i,'').strip
        @p[:tussenv] << t =~ /(v.d.)|(vd)/ ? 'van der' : t
      end
    end
    n
  end
  
  def doRanksTitles(n)
    loop do
      b = true
      @@titles.each do |t|
        if n =~ /^#{t}\W/i
          b = false
          n = n.gsub(/^#{t}\.?/i,'').strip
          @p[:titles] << t
        end

        if n =~ /,\s*#{t}\.?$/i
          n = n.gsub(/,\s*#{t}\.?$/i,'').strip 
          @p[:titles] << t
          b = false
        end
        
      end
  
      @@ranks.each do |r|
        
        if n =~ /^#{r}\W/i
          b = false
          n = n.gsub(/^#{r}\.?/i,'').strip
          @p[:rank] << r.dup
          if n =~ /^([0-9])/
            @p[:rank][-1] << $1
            n = n.gsub(/^[0-9]/,'').strip
          end
          n = n.gsub(/^\(.*\)/,'').strip if n =~ /^\(.*\)/
        end
      end
      break if b
    end
    n
  end
  
  
  
  def breakDown()
    
    begin 
      
      n = @p[:input].dup

      n = doSexes(n)
      n = doAdel(n)
      n = doRanksTitles(n)
      n = doETitles(n)
      n = doInitials(n)
      n = doTusenvoegsels(n)
      
      n = n.gsub(/\(.*\)$/,'').strip

      @p[:name] = n.strip.gsub(/\s+/,' ')
    
    rescue Exception => e
      $stderr.puts(e.message)
      $stderr.puts("#{@p[:fullname]}")
    end

  end
  
  def initialize(n)
    @p = {
      sex: 'u',
      rank: [],
      titles: [],
      etitles: [],
      initials: [],
      tussenv: [],
      firstnames: []
    }
    @p[:input] = n.dup.strip
    breakDown
  end
  
  def to_s
    JSON.pretty_generate(@p)
  end

  def [](s)
    return @p[s]
  end
  
  def can_name
    (@p[:tussenv].join('') + @p[:name]).downcase.gsub(/[^[:alpha:]]/,'')
  end
  
  def similar(right)
    
    @@weights = {
      sex: 100,
      levenshtein: 30,
      initials: 25,
      firstnames: 35,
      titles: 10
    }
    
    score = 0
    canl = can_name
    canr = right.can_name
    
    if @p[:sex] != 'u' and right[:sex] != 'u'
      score += @@weights[:sex] if @p[:sex] != right[:sex] 
    end
    
    score += @@weights[:levenshtein]  * Text::Levenshtein.distance(canr, canl)

    if @p[:initials].length and right[:initials].length
      @p[:initials].each do |i|
        score += @@weights[:initials] if not right[:initials].include?(i)
      end
      right[:initials].each do |i|
        score += @@weights[:initials] if not @p[:initials].include?(i)
      end
    end
    
    if @p[:titles].length and right[:titles].length
      @p[:titles].each do |i|
        score += @@weights[:titles] if not right[:titles].include?(i)
      end
      right[:titles].each do |i|
        score += @@weights[:titles] if not @p[:titles].include?(i)
      end
    end
    
    if @p[:firstnames].length and right[:firstnames].length
      @p[:firstnames].each do |i|
        score += @@weights[:firstnames] if not right[:firstnames].include?(i)
      end
      right[:firstnames].each do |i|
        score += @@weights[:firstnames] if not @p[:firstnames].include?(i)
      end
    end
    
    
    score
  end

end
