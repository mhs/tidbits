#!/usr/bin/env ruby

# This file can be installed as a TextMate command to make the selected text an Evernote
# note. It supports textile, markdown, and text. If you make a textile or markdown
# document an evernote note, it will convert the text to HTML using RedCloth or BlueCloth.
#
# == Dependencies
# * RedCloth if you want textile support
# * BlueCloth if you want markdown support
# * CocoaDialog (this should be shipped with your TextMate distribution)
#
# == Installing in TextMate
# I set it up as the following in TextMate's bundle editor, feel free to tweak
# or change:
#  Command name: evernote-clipper
#  Save: Nothing
#  Command(s): The contents of this file
#  Input: Selected Text or Document (although Document is failing for me on Snow Leopard)
#  Output: Discard
#  Key Equivalent: Ctrl-Option-Command E
#  Scope Selector: <nothing>
#
# If the above doesn't work for you then try to change the Output to something besides
# Discard to debug.
#
# == Author
# * Zach Dennis (zdennis@mutuallyhuman.com, zach.dennis@gmail.com)
module Evernote
  class Clipper
    def initialize(options={})
      @options = options
    end
    
    def as_text!
      create_note :text => text
    end
    
    def as_html_from_textile!
      require 'rubygems'
      require 'redcloth'
      create_note :html => RedCloth.new(text).to_html
    end
    
    def as_html_from_markdown!
      require 'rubygems'
      require 'bluecloth'
      create_note :html => BlueCloth.new(text).to_html
    end
    
    private
    
    def create_note(options={})
      require 'tempfile'
      if content=options[:text]
        create_how = "from file"
        filepath =  "/tmp/evernote-clipping.txt"
        location = filepath
      elsif content=options[:html]
        create_how = "from url"
        filepath =  "/tmp/evernote-clipping.html"
        location = "file://#{filepath}"
      end
      File.open(filepath, "w") { |f| f.puts content }
      # tags currently hangs Evernote so they aren't used, ie: tags "apple, bananas"
      cmd = %{osascript -e 'tell application "Evernote" to create note #{create_how} "#{location}" title "#{title}" notebook "#{notebook}"'}
      system cmd
    end
    
    def text ; @options[:text] ; end
    def tags ; @options[:tags] ; end
    def title
      @title ||= (
        _title = @options[:title] 
        count = how_many_notes_exist?(_title)
        _title = "#{_title} ##{count+1}" if count > 0
        _title)
    end
    def notebook ; @options[:notebook]; end
    
    def how_many_notes_exist?(title)
      cmd = %{osascript -e 'tell application "Evernote" to find notes "intitle:#{title} notebook:#{notebook}"'}
      results = `#{cmd}`
      results.split(/,/).size
    end

  end
end

def ask(question, options={})
  title = options[:title] || ""
  ok_text = options[:ok_text] || "Okay"
  cancel_text = options[:cancel_text] || "Cancel"
  cmd =<<-BASH
    res=$(#{ENV["TM_APP_PATH"]}/Contents/SharedSupport/Support/bin/CocoaDialog.app/Contents/MacOS/CocoaDialog inputbox --title "#{title}" \
        --informative-text "#{question}:" \
        --button1 "#{ok_text}" --button2 "#{cancel_text}")

    [[ $(head -n1 <<<"$res") == "2" ]] && exit_discard

    res=$(tail -n1 <<<"$res")
    echo "$res"
  BASH
  answer = `#{cmd}`.to_s
end

title = ask("What is the title of this note?", :title => "Evernote Note").chomp
notebook = ask("What notebook would you like to place this note in?")
# When no notebook is supplied Evernote returns "1\n"
notebook = "Unfiled" if notebook.empty? || notebook =~ /^1/
clip = Evernote::Clipper.new(
  :text => ENV["TM_SELECTED_TEXT"],
  :title => title,
  # :tags => ask("Tags for this note (comma-separated)?", :title => "Evernote Note"),
  :notebook => notebook
)

case ENV["TM_MODE"]
when /textile/i
  clip.as_html_from_textile!
when /markdown/i
  clip.as_html_from_markdown!
else
  clip.as_text!
end

