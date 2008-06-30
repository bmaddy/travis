# $Id: console.rb 88 2008-02-08 18:47:36Z tim_pease $

require Logging.libpath(*%w[logging appenders io])

module Logging::Appenders

  # This class provides an Appender that can write to STDOUT.
  #
  class Stdout < ::Logging::Appenders::IO

    # call-seq:
    #    Stdout.new
    #    Stdout.new( :layout => layout )
    #
    # Creates a new Stdout Appender. The name 'stdout' will always be used
    # for this appender.
    #
    def initialize( name = nil, opts = {} )
      name ||= 'stdout'
      super(name, STDOUT, opts)
    end
  end  # class Stdout

  # This class provides an Appender that can write to STDERR.
  #
  class Stderr < ::Logging::Appenders::IO

    # call-seq:
    #    Stderr.new
    #    Stderr.new( :layout => layout )
    #
    # Creates a new Stderr Appender. The name 'stderr' will always be used
    # for this appender.
    #
    def initialize( name = nil, opts = {} )
      name ||= 'stderr'
      super(name, STDERR, opts)
    end
  end  # class Stderr

end  # module Logging::Appenders

# EOF
