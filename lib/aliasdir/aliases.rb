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

    def remove(the_alias)
      old = aliases
      if old[the_alias]
        sanatized_contents = File.readlines(FILE).reject { |aliaz| aliaz[/^#{the_alias}$/i] }  
        File.open(FILE, 'w') { |file|  file.write sanatized_contents.join("") }
        "Removed alias [#{the_alias}] => [#{old[the_alias]}]"
      else
        "Could not find the alias [#{the_alias}] that you wish to remove."
      end
    end

    private

    def aliases
      File.exists?(FILE) ? YAML.load(IO.read(FILE)) : Hash.new
    end
  end
end
