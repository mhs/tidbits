class Aliases
  FILE = Etc.getpwuid.dir + '/.aliasdir'

  class << self
    def dump(format)
      delimiter = format == :shell ? ';' : "\n"
      aliases.to_a.sort_by{ |arr| arr.first }.map{|arr| "alias #{arr.first}='cd #{arr.last}'"}.join(delimiter)
    end
    
    def [](the_alias)
      aliases[the_alias]
    end
  
    def []=(the_alias, target)
      contents = aliases.merge(the_alias => target.gsub(/([\s\!\?])/, '\\\\\1')).to_yaml
      File.open(FILE, 'w') do |file|
        file.write contents
      end
    end
  
    private

    def aliases
      File.exists?(FILE) ? YAML.load(IO.read(FILE)) : Hash.new
    end
  end
end
