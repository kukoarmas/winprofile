#!/usr/bin/ruby
#
# Redirect a user profile's folders
#
# We use the following defaults
# Personal -> U:/Mis Documentos
# ALL THE REST -> U:\.windows_settings\


require 'lib/winprofile'

require 'optparse'
require 'fileutils'

# Samba profiles defaults
@profiles="/home/samba/profiles"
# User homes default
@home="/home"

# Command
@cmd="show"

def redirect
	p=WinProfile.new("#{@profiles}/#{@user}/NTUSER.DAT")
	p.debug=true
	p.verbose=true

	puts "Redirecting Desktop"
	p.redirect_folder('Desktop','U:\\.windows_settings\\Escritorio')
	p.redirect_folder('Desktop','U:\\.windows_settings\\Escritorio')
	puts "Redirecting AppData"
	p.redirect_folder('AppData','U:\\.windows_settings\\Datos de programa')
	p.redirect_folder('AppData','U:\\.windows_settings\\Datos de programa')
	puts "Redirecting Personal"
	p.redirect_folder('Personal','U:\\Mis documentos')
	p.redirect_folder('Personal','U:\\Mis documentos')
end

def move
	puts "Creating #{@home}/#{@user}/.windows_settings"
	FileUtils.makedirs "#{@home}/#{@user}/.windows_settings"
	puts "Moving dirs"
	puts "#{@home}/samba/profiles/#{@user}/Mis\ documentos -> #{@home}/#{@user}/Mis\ documentos"
	FileUtils.mv "#{@home}/samba/profiles/#{@user}/Mis\ documentos","#{@home}/#{@user}/Mis\ documentos"

	puts "#{@home}/samba/profiles/#{@user}/Escritorio -> #{@home}/#{@user}/.windows_settings/Escritorio"
	FileUtils.mv "#{@home}/samba/profiles/#{@user}/Escritorio","#{@home}/#{@user}/.windows_settings/Escritorio"

	puts "#{@home}/samba/profiles/#{@user}/Datos de programa -> #{@home}/#{@user}/.windows_settings/Datos de programa"
	FileUtils.mv "#{@home}/samba/profiles/#{@user}/Datos de programa","#{@home}/#{@user}/.windows_settings/Datos de programa"
end

app = Hash.new

options = OptionParser.new do |opts|
  opts.on("--debug", "Debug. No action. (verbose=true)") do |opt|
    $noop=true
    $verbose=true
    $expect_verbose=true
  end
  opts.on("--verbose", "Be verbose") do |opt|
    $verbose=true
  end
  opts.on("--user [ARG]", "User profile to change") do |opt|
    @user=opt
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

