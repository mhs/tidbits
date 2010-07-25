#!/usr/bin/env ruby

# == TextMate Evernote Clipper 
#
# This file is a Evernote clipper for TextMate. It allows you to create a note in Evernote
# based on the currently selected text in TextMate. 
#
# This supports textile, markdown, and plain text clippings.
#
# === Textile Clippings 
# 
# If you clip text from a textile document in TextMate (denoted by the TextMate mode Textile)
# then the selected text will be ran through a textile preprocesser and inserted as a note
# in Evernote as an HTML document. This relies on the RedCloth ruby library being installed.
#
# === Markdown Clippings
#
# If you clip text from a markdown document in TextMate (denoted by the TextMate mode 
# Markdown) then the selected text will be ran through a textile preprocesser and inserted as
# a note in Evernote as an HTML document. This relies on the BlueCloth ruby library being 
# installed.
#
# === Plain Text Clippings
#
# The fallback clipping mechanism is to treat the selected text as plain text. This will
# work for any TextMate mode. 
#
# === Installation in TextMate
#
# This is how I set it up in TextMate using it's BundleEditor. Feel free to tweak or change
# to suit your needs:
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
# === Author
#
# * Zach Dennis (zdennis@mutuallyhuman.com, zach.dennis@gmail.com)
#
module Evernote
  class Clipper
    def initialize(options={})
      @options = options
    end
    
    def as_text!
      create_note :text => text
    end
    
    def as_html_from_textile!
      begin
        require 'rubygems'
        require 'redcloth'
        raise "foo"
        create_note :html => RedCloth.new(text).to_html
      rescue
        as_text!
      end
    end
    
    def as_html_from_markdown!
      begin
        require 'rubygems'
        require 'bluecloth'
        create_note :html => BlueCloth.new(text).to_html
      rescue
        as_text!
      end
    end
    
    private
    
    def create_note(options={})
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
    
    def notebook ; @options[:notebook]; end
    def tags ; @options[:tags] ; end
    def text ; @options[:text] ; end
    def title
      _title = @options[:title] 
      count = how_many_notes_exist?(_title)
      _title = "#{_title} ##{count+1}" if count > 0
      _title
    end
    
    def how_many_notes_exist?(title)
      cmd = %{osascript -e 'tell application "Evernote" to find notes "intitle:#{title} notebook:#{notebook}"'}
      results = `#{cmd}`.chomp
      return 0 if results =~ /^\s*$/
      return 1 if !results.include?(",")
      results.scan(/,/).size + 1
    end

  end
end

def ask(question, options={})
  title = options[:title] || ""
  ok_text = options[:ok_text] || "Okay"
  cancel_text = options[:cancel_text] || "Cancel"
  cmd =<<-BASH
    res=$(#{ENV["TM_APP_PATH"]}/Contents/SharedSupport/Support/bin/CocoaDialog.app/Contents/MacOS/CocoaDialog inputbox --title "#{title}" \
        --informative-text "#{question}:" --string-output\
        --button1 "#{ok_text}" --button2 "#{cancel_text}")

    [[ $(head -n1 <<<"$res") == "2" ]] && exit_discard

    res=$(tail -n1 <<<"$res")
    echo "$res"
  BASH
  answer = `#{cmd}`.to_s
end

def cancel?(str)
  ["2", "Cancel"].include?(str.chomp)
end

def okay?(str)
  ["1", "Okay"].include?(str.chomp)
end


title = ""
loop do
  answer = ask("What is the title of this note? (required)", :title => "Evernote Note").chomp
  exit if cancel?(answer)
  if !answer.empty? && !okay?(answer)
    title = answer
    break
  end
end


notebook = ask("What notebook would you like to place this note in? (Unfiled by default)")
exit if cancel?(notebook)
notebook = "Unfiled" if okay?(notebook)

clip = Evernote::Clipper.new(
  :text => ENV["TM_SELECTED_TEXT"],
  :title => title,
  :notebook => notebook
  # :tags => ask("Tags for this note (comma-separated)?", :title => "Evernote Note")
)

case ENV["TM_MODE"]
when /textile/i
  clip.as_html_from_textile!
when /markdown/i
  clip.as_html_from_markdown!
else
  clip.as_text!
end

