
require 'expect'
require 'pty'

$expect_verbose = false

class WinReg
  attr_accessor :file, :debug, :verbose

  def initialize(file,debug=false)
    @file = file
    @debug = debug
    # Check that file exists
    if not File.exists? @file
      raise "ERROR: File #{@file} does not exist"
    end
    # FIXME: Check that we have the chntpw command
  end

  # Read a key from hive
  def read_key(key)
    @value = nil

    PTY.spawn("chntpw -e #{@file}") do |read,write,pid|
      $expect_verbose = @debug
      write.sync = true

      # If 30 seconds pass and the expected text is not found, the
      # response object will be nil.
      read.expect(/^>/, 5) do |response|
        raise unless response
        write.print "cat " + key + "\n" if response
      end

      read.expect(/^>/, 5) do |response|
        raise unless response
        write.print "q" + "\n" if response
        # response is a string array
        @found=false
        response[0].split(/\r\n/).each do |line|
          if @found
            @value=line
            break
          end
          @found = true if line =~ /^Value/
        end
      end
    end

    return @value
  end

  # Write a key, value pair to hive
  def write_key(key,value)

    PTY.spawn("chntpw -e #{@file}") do |read,write,pid|
      $expect_verbose = @debug
      write.sync = true

      # If 30 seconds pass and the expected text is not found, the
      # response object will be nil.
      read.expect(/^>/, 5) do |response|
        raise unless response
        write.print "ed " + key + "\n" if response
      end

      read.expect(/^->/, 5) do |response|
        raise unless response
        write.print value + "\n" if response
      end

      read.expect(/^>/, 5) do |response|
        raise unless response
        write.print "q" + "\n" if response
      end

      read.expect(/^Write hive files?/, 5) do |response|
        raise unless response
        write.print "y" + "\n" if response
      end
    end
  end

  # Write an array of key,value pairs to hive
  def write_keys(pairs)

    PTY.spawn("chntpw -e #{@file}") do |read,write,pid|
      $expect_verbose = @debug
      write.sync = true

      pairs.each do |key|
        # If 30 seconds pass and the expected text is not found, the
        # response object will be nil.
        read.expect(/^>/, 5) do |response|
          raise unless response
          write.print "ed " + key[:name] + "\n" if response
        end

        read.expect(/^->/, 5) do |response|
          raise unless response
          write.print key[:value] + "\n" if response
        end
      end

      read.expect(/^>/, 5) do |response|
        raise unless response
        write.print "q" + "\n" if response
      end

      read.expect(/^Write hive files?/, 5) do |response|
        raise unless response
        write.print "y" + "\n" if response
      end
    end
  end


end

