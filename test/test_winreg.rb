require 'helper'
require 'ftools'

class TestWinReg < Test::Unit::TestCase
  FOLDERS_BASE='Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'

  context "A WinReg instance" do
    setup do
      File.copy "test/NTUSER.DAT.SAFE","test/NTUSER.DAT"
      @winreg=WinReg.new("test/NTUSER.DAT")
    end
    
    context "when reading the 'Personal' folder key" do
      should 'return "%USERPROFILE%\Mis Documentos"' do
        assert_equal '%USERPROFILE%\Mis Documentos',@winreg.read_key(FOLDERS_BASE+'\\'+'Personal')
      end
    end
  
    context 'when writing the "Personal" folder key with "SOME_DATA"' do
      should 'return "SOME_DATA"' do
        @winreg.write_key(FOLDERS_BASE+'\\'+'Personal','SOME_DATA')
        assert_equal 'SOME_DATA',@winreg.read_key(FOLDERS_BASE+'\\'+'Personal')
      end
    end

  end
end
