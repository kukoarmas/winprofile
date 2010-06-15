
require 'rubygems'
require 'winreg'

#
# WinProfile
#
class WinProfile
  attr_accessor :file, :debug, :verbose, :homes, :profiles
  attr_reader :folders

  # Base regkey for folder redirection
  FOLDERS_BASE='Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'

  # List of user folder redirection regkeys
  FOLDER_DEFAULTS=[
          {:name => "AppData", :dir => 'Datos de programa' },
          {:name => "Desktop", :dir => 'Escritorio' },
          {:name => "Favorites", :dir => 'Favoritos' },
          {:name => "NetHood", :dir => 'Entorno de red' },
          {:name => "Personal", :dir => 'Mis documentos' },
          {:name => "PrintHood", :dir => 'Impresoras' },
          {:name => "Programs", :dir => 'Menú Inicio\Programas' },
          {:name => "SendTo", :dir => 'SendTo' },
          {:name => "Start Menu", :dir => 'Menú Inicio' },
          {:name => "Startup", :dir => 'Menú Inicio\Programas\Inicio' },
          {:name => "Templates", :dir => 'Plantillas' },
          {:name => "Local Settings", :dir => 'Configuración Local' },
          {:name => "Local AppData", :dir => 'Configuración Local\Datos de programa' },
          {:name => "Cache", :dir => 'Configuración Local\Archivos temporales de Internet' },
          {:name => "Cookies", :dir => 'Cookies' },
          {:name => "Recent", :dir => 'Reciente' },
          {:name => "History", :dir => 'Configuración Local\Historial' },
          ] 


  def initialize(user=nil,profiles="/home/samba/profiles",homes="/home")
    # Defaults
    @profiles = profiles
    @homes = homes
    @folders = FOLDER_DEFAULTS

    # If user=nil don't check existence, late initialization
    if user != nil
      # HKLU hive file
      @file = "#{@profiles}/#{user}/NTUSER.DAT"
      raise "Invalid profile: #{@file}" unless File.exists? @file
    end
  end

  # Set the user whose profile we want to change
  def user=(user)
    # HKLU hive file
    @file = "#{@profiles}/#{user}/NTUSER.DAT"

    raise "Invalid profile: #{@file}" unless File.exists? @file
  end

  # Show folder redirection status for a given folder
  def show_folder(folder)
    @location=nil

    w=WinReg.new(@file)
    w.debug=@debug

    FOLDER_DEFAULTS.each do |key|
      if key[:name] == folder
        @location = w.read_key(FOLDERS_BASE+'\\'+key[:name])
        puts "#{key[:name]} -> #{@location}" if @verbose
      end
    end
    @location
  end

  # Show folder redirection status for all folders
  def show_folders

    w=WinReg.new(@file)
    w.debug=@debug

    FOLDER_DEFAULTS.each do |key|
      @location = w.read_key(FOLDERS_BASE+'\\'+key[:name])
      puts "#{key[:name]} -> #{@location}" if @verbose
    end
  end

  # Redirects a given user folders to a dir
  def redirect_folder(folder,dir)

    w=WinReg.new(@file)
    w.debug=@debug

    w.write_key(FOLDERS_BASE+'\\'+folder,dir)

  end

  # Redirects all user folders to given dir
  def redirect_folders(dir)

    w=WinReg.new(@file)
    w.debug=@debug
    FOLDER_DEFAULTS.each do |key|
      w.write_key(FOLDERS_BASE+'\\'+key[:name],dir+'\\'+key[:dir])
    end
  end

  # Initialize a roving profile directory structure in the given directory
  def init_folders(dir)

    FOLDER_DEFAULTS.each do |key|
      @folder=dir+"/"+key[:dir]
      @folder.gsub!('\\','/')
      if not File.directory? @folder
        File.makedirs @folder
      end
    end

  end

  # Move ALL profile folders to a new destination
  def move_folders(orig,dest)
    
    puts "Moving #{orig} ->  #{dest}" if @verbose
    FileUtils.mv orig,dest
  end

  # Move a given profile folder to a new destination
  def move_folder(folder,orig,dest)
    
    puts "Moving #{orig}/#{key[:dir]} ->  #{dest}/#{key[:dir]}" if @verbose
    FileUtils.mv "#{orig}/#{key[:dir]}", "#{dest}/#{key[:dir]}"

  end

  # Reset profile to default folders
  def reset_default
    
    w=WinReg.new(@file)
    w.debug=@debug
    FOLDER_DEFAULTS.each do |key|
      w.write_key(FOLDERS_BASE+'\\'+key[:name],'%USERPROFILE%\\'+key[:dir])
    end
  end 

end

