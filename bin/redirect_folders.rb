#!/usr/bin/ruby
#
# Redirect a user profile's folders
#
# We use the following defaults
# Personal -> U:/Mis Documentos
# ALL THE REST -> U:\.windows_settings\


require 'rubygems'
require 'winprofile'

require 'optparse'
require 'fileutils'

# Samba profiles defaults
@profiles="/home/samba/profiles"
# User homes default
@homes="/home"

@verbose=false
@debug=false

# Command
@cmd="show"

def redirect
	p=WinProfile.new("#{@profiles}/#{@user}/NTUSER.DAT")
	p.debug=true
	p.verbose=true

	puts "Redirecting Desktop"
	p.redirect_folder('Desktop','U:\\.windows_settings\\Escritorio')
	puts "Redirecting AppData"
	p.redirect_folder('AppData','U:\\.windows_settings\\Datos de programa')
	puts "Redirecting Personal"
	p.redirect_folder('Personal','U:\\Mis documentos')
end

def move
	puts "Creating #{@homes}/#{@user}/.windows_settings"
	FileUtils.makedirs "#{@homes}/#{@user}/.windows_settings"
	puts "Moving dirs"
	puts "#{@homes}/samba/profiles/#{@user}/Mis\ documentos -> #{@homes}/#{@user}/Mis\ documentos"
	FileUtils.mv "#{@homes}/samba/profiles/#{@user}/Mis\ documentos","#{@homes}/#{@user}/Mis\ documentos"

	puts "#{@homes}/samba/profiles/#{@user}/Escritorio -> #{@homes}/#{@user}/.windows_settings/Escritorio"
	FileUtils.mv "#{@homes}/samba/profiles/#{@user}/Escritorio","#{@homes}/#{@user}/.windows_settings/Escritorio"

	puts "#{@homes}/samba/profiles/#{@user}/Datos de programa -> #{@homes}/#{@user}/.windows_settings/Datos de programa"
	FileUtils.mv "#{@homes}/samba/profiles/#{@user}/Datos de programa","#{@homes}/#{@user}/.windows_settings/Datos de programa"
end

app = Hash.new

options = OptionParser.new do |opts|
  opts.on("--debug", "Debug. No action. (verbose=true)") do |opt|
    @noop=true
    @verbose=true
    @debug=true
  end
  opts.on("--verbose", "Be verbose") do |opt|
    @verbose=true
  end
  opts.on("--user [ARG]", "User profile to change") do |opt|
    @user=opt
  end
  opts.on("--profiles [ARG]", "User profiles directory (default: /home/samba/profiles)") do |opt|
    @profiles=opt
  end
  opts.on("--homes [ARG]", "User homes (default: /home)") do |opt|
    @homes=opt
  end
  opts.on("--version", "Print version and exit") do |opt|
    puts "version #{winprofile::VERSION}"
    exit 0
  end
end
options.parse!(ARGV)
if ARGV.length != 1
  puts "Missing command argument"
  puts "Available commands"
  puts "   show: show folder status"
  puts "   redirect: redirect folders (only in registry)"
  puts "   move: move folders"
  exit 1
end
@cmd=ARGV.shift

if ! @user
  puts "ERROR: You need to specify e user with --user option"
  exit 1
end

case @cmd
	when "show"
    puts "Reading from #{@profiles}/#{@user}" if @debug
		p=WinProfile.new("#{@profiles}/#{@user}/NTUSER.DAT")
		puts "Personal Folders for #{@user}"
		p.verbose=true
		p.show_folders
	when "redirect"
		redirect
	when "move"
		move
	else
	   puts "Unknown command: #{@cmd}"
end

#FileUtils.cp_r "#{@profiles}/#{@user}","#{@home}/#{@user}/.windows_settings", :preserve=>true

# FIXME: Move Mis Documentos

#p=WinProfile.new("#{@home}/#{@user}/.windows_settings/NTUSER.DAT")
#p.show_folders
#p.redirect_folders('U:\\.windows_settings')
#p.redirect_folders('U:\\.windows_settings')
#p.redirect_folder('Personal','U:\\Mis documentos')

