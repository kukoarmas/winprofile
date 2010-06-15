require 'helper'
require 'fileutils'

class TestWinProfile < Test::Unit::TestCase

  context "WinProfile" do
    should 'raise exception when invalid profile given' do
      assert_raise RuntimeError do
        @winprofile=WinProfile.new("test")
      end
    end
    should 'raise exception when invalid profile given in late initialization' do
      assert_raise RuntimeError do
        @winprofile=WinProfile.new()
        @winprofile.user="NONEXISTENT"
      end
    end
    should 'return WinProfile object when valid profile given' do
      @winprofile=WinProfile.new("sample_profile","test")
      assert_instance_of WinProfile, @winprofile
    end
    should "be able to set profile after object created" do
      @winprofile=WinProfile.new()
      @winprofile.profiles="test"
      @winprofile.user="sample_profile"
      assert_equal "test/sample_profile/NTUSER.DAT",@winprofile.file
    end
    should "return same object when both initialize methods are used with same parameters" do
      @winprofile=WinProfile.new()
      @winprofile.profiles="test"
      @winprofile.user="sample_profile"
      @winprofile2=WinProfile.new("sample_profile","test")
      assert @winprofile2.file == @winprofile.file
    end
  end
  
  context "a WinProfile instance" do

    setup do
      File.copy "test/sample_profile/NTUSER.DAT","test/NTUSER.DAT"
      @winprofile=WinProfile.new("sample_profile","test")
      @winprofile.verbose=false
    end

    should "initialize folders same as FOLDER_DEFAULTS" do
      assert_same_elements WinProfile::FOLDER_DEFAULTS,@winprofile.folders
    end    

    context "when asked for the 'Personal' folder key" do
      should 'return "%USERPROFILE%\Mis documentos"' do
        assert_equal '%USERPROFILE%\Mis documentos',@winprofile.show_folder('Personal')
      end
    end

    context "when asked for a non_existent folder" do
      should "return nil" do
        assert_nil @winprofile.show_folder('non-existent')
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

    #context "when initializing profile folders" do
    #  setup do
    #    FileUtils.rm_rf("test/tmp/sample_profile")
    #  end

      #should "get correct folders" do
      #  @winprofile.init_folders("test/tmp/sample_profile")
      #  Dir.chdir("test/sample_profile")
      #  @sample_profile=Dir.glob("*/")
      #  Dir.chdir("../..")
      #  assert_same_elements @sample_profile,Dir.entries("test/tmp/sample_profile")
      #end
    #end

    context "when moving profile folders" do
      setup do
        # Remove orig
        FileUtils.rm_rf("test/tmp/orig_profile")
        # Remove dest
        FileUtils.rm_rf("test/tmp/dest_profile")
        # Copy test profile
        FileUtils.cp_r("test/sample_profile","test/tmp/orig_profile")
      end

      should "get same directories" do
        @before=Dir.entries("test/tmp/orig_profile")
        @winprofile.move_folders("test/tmp/orig_profile","test/tmp/dest_profile")
        assert_same_elements @before,Dir.entries("test/tmp/dest_profile")
      end
    end
  end
end

