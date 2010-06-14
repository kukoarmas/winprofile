require 'helper'
require 'fileutils'

class TestWinProfile < Test::Unit::TestCase
  
  context "a WinProfile instance" do

    setup do
      File.copy "test/sample_profile/NTUSER.DAT","test/NTUSER.DAT"
      @winprofile=WinProfile.new("test/NTUSER.DAT")
      @winprofile.verbose=true
    end
    
    context "when asked for the 'Personal' folder key" do
      should 'return "%USERPROFILE%\Mis documentos"' do
        assert_equal '%USERPROFILE%\Mis documentos',@winprofile.show_folder('Personal')
      end
    end

    context "when asked for a non_existent folder" do
      should "return nil" do
        assert_equal nil,@winprofile.show_folder('non-existent')
      end
    end

    context "when reset to defaults" do
      setup do
        @winprofile.reset_default
      end
      context "reading the 'Personal' folder" do
        should 'return "%USERPROFILE%\Mis documentos"' do
          assert_equal '%USERPROFILE%\Mis documentos',@winprofile.show_folder('Personal')
        end
      end
      context "reading all folders" do
        should "return DEFAULT_FOLDERS constant" do
          @winprofile.show_folders
          assert_equal WinProfile::FOLDER_DEFAULTS,@winprofile.show_folders
        end
      end
    end

    context "when initializing profile folders" do
      setup do
        FileUtils.rm_rf("test/tmp/test_profile")
      end

      should "get correct folders" do
        @winprofile.init_folders("test/tmp/test_profile")
        assert_same_elements Dir.entries("test/sample_profile"),Dir.entries("test/tmp/test_profile")
      end
    end

    context "when copying profile folders" do
      setup do
        # Remove orig
        FileUtils.rm_rf("test/tmp/test_profile")
        # Remove dest
        FileUtils.rm_rf("test/tmp/dest_profile")
        # Initialize origin
        @winprofile.init_folders("test/tmp/test_profile")
        # Copy user hive to origin
        File.cp("test/NTUSER.DAT","test/tmp/test_profile")
      end

      should "get same directories" do
        @winprofile.copy_folders("test/tmp/test_profile","test/tmp/dest_profile")
        assert_same_elements Dir.entries("test/tmp/test_profile"),Dir.entries("test/tmp/dest_profile")
      end
    end
  end
end

