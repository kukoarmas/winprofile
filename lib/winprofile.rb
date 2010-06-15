
require 'rubygems'
require 'winreg'

class WinProfile
  attr_accessor :file, :debug, :verbose

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


  def initialize(file)
    @file = file
  end

  # Show folder redirection status for a given folder
  def show_folder(folder)
    @localtion=nil
    w=WinReg.new(@file)

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

    FOLDER_DEFAULTS.each do |key|
      @location = w.read_key(FOLDERS_BASE+'\\'+key[:name])
      puts "#{key[:name]} -> #{@location}" if @verbose
    end
  end

  # Redirects a given user folders to a dir
  def redirect_folder(folder,dir)
    w=WinReg.new(@file)

    w.write_key(FOLDERS_BASE+'\\'+folder,dir)


  end

  # Redirects all user folders to given dir
  def redirect_folders(dir)

    w=WinReg.new(@file)
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
        puts "FOOOD FIGHT!!" if @debug
        File.makedirs @folder
      end
    end

  end

  # Copy ALL profile folders to a new destination
  def copy_folders(orig,dest)
    
    FileUtils.cp_r orig,dest,:preserve=>true
  end

  # Copy a given profile folder to a new destination
  def copy_folder(folder,orig,dest)

    puts "Copying #{orig}/#{key[:dir]} ->  #{dest}/#{key[:dir]}" if @verbose

  end

  # Reset profile to default folders
  def reset_default
    
    w=WinReg.new(@file)
    FOLDER_DEFAULTS.each do |key|
      w.write_key(FOLDERS_BASE+'\\'+key[:name],'%USERPROFILE%\\'+key[:dir])
    end
  end 

end

