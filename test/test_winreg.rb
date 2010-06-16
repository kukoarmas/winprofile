require 'helper'
require 'ftools'

class TestWinReg < Test::Unit::TestCase
  FOLDERS_BASE='Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'

  should "raise exception when nonexistent file given" do
    assert_raise RuntimeError do
      @winreg=WinReg.new("NONEXISTENT")
    end
  end

  should 'return WinReg object when existent file given' do
    @winprofile=WinReg.new("test/NTUSER.DAT.SAFE")
    assert_instance_of WinReg, @winprofile
  end

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

    context 'when writing multiple keys at once' do
      setup do
        @data = [ { :name => FOLDERS_BASE+'\\'+'Personal', :value => 'SOME_DATA' }, 
                  { :name => FOLDERS_BASE+'\\'+'AppData', :value => 'SOME_MORE_DATA' } 
                ]
      end
      should 'return the written keys' do
        @winreg.write_keys(@data)
        assert_equal 'SOME_DATA',@winreg.read_key(FOLDERS_BASE+'\\'+'Personal')
        assert_equal 'SOME_MORE_DATA',@winreg.read_key(FOLDERS_BASE+'\\'+'AppData')
      end
    end

  end
end
