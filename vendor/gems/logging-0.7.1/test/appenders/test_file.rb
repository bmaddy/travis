# $Id: test_file.rb 97 2008-02-13 00:32:18Z tim_pease $

require File.join(File.dirname(__FILE__), %w[.. setup])

module TestLogging
module TestAppenders

  class TestFile < Test::Unit::TestCase
    include LoggingTestCase

    NAME = 'logfile'

    def setup
      super
      ::Logging.init

      FileUtils.mkdir [File.join(TMP, 'dir'), File.join(TMP, 'uw_dir')]
      FileUtils.chmod 0555, File.join(TMP, 'uw_dir')
      FileUtils.touch File.join(TMP, 'uw_file')
      FileUtils.chmod 0444, File.join(TMP, 'uw_file')
    end

    def test_class_assert_valid_logfile
      log = File.join(TMP, 'uw_dir', 'file.log')
      assert_raise(ArgumentError) do
        ::Logging::Appenders::File.assert_valid_logfile(log)
      end

      log = File.join(TMP, 'dir')
      assert_raise(ArgumentError) do
        ::Logging::Appenders::File.assert_valid_logfile(log)
      end

      log = File.join(TMP, 'uw_file')
      assert_raise(ArgumentError) do
        ::Logging::Appenders::File.assert_valid_logfile(log)
      end

      log = File.join(TMP, 'file.log')
      assert ::Logging::Appenders::File.assert_valid_logfile(log)
    end

    def test_initialize
      log = File.join(TMP, 'file.log')
      appender = ::Logging::Appenders::File.new(NAME, 'filename' => log)
      assert_equal 'logfile', appender.name
      appender << "This will be the first line\n"
      appender << "This will be the second line\n"
      appender.flush
      File.open(log, 'r') do |file|
        assert_equal "This will be the first line\n", file.readline
        assert_equal "This will be the second line\n", file.readline
        assert_raise(EOFError) {file.readline}
      end
      cleanup

      appender = ::Logging::Appenders::File.new NAME, :filename => log
      assert_equal 'logfile', appender.name
      appender << "This will be the third line\n"
      appender.flush
      File.open(log, 'r') do |file|
        assert_equal "This will be the first line\n", file.readline
        assert_equal "This will be the second line\n", file.readline
        assert_equal "This will be the third line\n", file.readline
        assert_raise(EOFError) {file.readline}
      end
      cleanup

      appender = ::Logging::Appenders::File.new NAME, :filename => log,
                                                      :truncate => true
      assert_equal 'logfile', appender.name
      appender << "The file was truncated\n"
      appender.flush
      File.open(log, 'r') do |file|
        assert_equal "The file was truncated\n", file.readline
        assert_raise(EOFError) {file.readline}
      end
      cleanup
    end

    private
    def cleanup
      unless ::Logging::Appender[NAME].nil?
        ::Logging::Appender[NAME].close false
        ::Logging::Appender[NAME] = nil
      end
    end

  end  # class TestFile

end  # module TestAppenders
end  # module TestLogging

# EOF