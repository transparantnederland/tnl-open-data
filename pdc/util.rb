# coding: utf-8
require 'json'
require 'i18n'
require 'digest'

class String
  Stopwoorden = %w{ n.v. b.v. nv bv aan afd als bij dat de den der des deze die dit dl door dr ed een en enige enkele enz et etc haar het hierin hoe hun ik in inzake is je met na naar nabij niet no nu of om onder ons onze ook oorspr op over pas pres  prof publ sl st te tegen ten ter tot uit uitg vakgr van vanaf vert vol voor voortgez voortz wat wie zijn }
  UnAccented = "AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz"
  Accented = "ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž"
  def remove_non_ascii
    self.gsub(/\P{ASCII}/, '')
  end

  def starts_with?(aString)
    index(aString) == 0
  end

  def nhash(n)
    Digest::MD5.hexdigest(self)[0...n]
  end

  def normalize
    self.tr(Accented,UnAccented)
        .split(/\s+/).map { |a| 
          Stopwoorden.include?(a.downcase) ? nil : a.downcase.gsub(/\W/,'') 
        }.compact.sort.join('')
  end

end


class FixNum
  def strip 
    return self
  end
end

class Float
  def strip 
    return self
  end
end


class Object
  def deepCopy
    Marshal.load(Marshal.dump(self))
  end
  def blank?
    return false if self.class == Symbol
    self.nil? or (self.class==String and self.strip == '') or (self.respond_to?(:empty?) ? self.empty? : false)
  end
end

def parse_json(str)
  begin
    return str.blank? ? {} : JSON.parse(str, symbolize_names: true)
  rescue Exception => e
    raise Exception.new("#{e.message}; input: #{str}")
  end
end





# for debugging purposes...

def jsp(s)
  JSON.pretty_generate(s)
end

def jsonlog(o)
  File.open("log.log","a") do |fd|
    fd.puts JSON.pretty_generate({ o.class.to_s => o })
  end
end

def log(o)
  File.open("log.log","a") do |fd|
    fd.puts o
  end
end

