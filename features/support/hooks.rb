Before('@aliasdir') do
  FileUtils.mkdir_p "tmp"
end

After('@aliasdir') do
  FileUtils.rm_rf "tmp"
end
