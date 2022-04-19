# The `Logger` class provides a simple but sophisticated logging utility
# that you can use to output messages.
# Level verbosity from 0 - nothing and high with more traces.
# NOTE: Modified version of https://github.com/crystal-lang/logger.cr/blob/10dc2ef847e2f662abafb75f9e7dff21509adb85/src/logger.cr
#
# log = Logger.new(STDOUT, level: 0)

class Logger
  property level : Int8

  # Customizable `Proc` (with a reasonable default)
  # which the `Logger` uses to format and print its entries.
  #
  # Use this setter to provide a custom formatter.
  # The `Logger` will invoke it with the following arguments:
  #  - verbosity: `Int8` verbosity level
  #  - severity: a `Logger::Severity`
  #  - datetime: `Time`, the entry's timestamp
  #  - message: `String`, the body of a message
  #  - context: `Hash(String,String)`, a key value context to represent strucutured logs
  #  - io: `IO`, the Logger's stream, to which you must write the final output
  #
  # Example:
  #
  # ```
  # require "logger"
  #
  # logger = Logger.new(STDOUT)
  #
  # logger.info("Pod kube-system/kube-dns status was updated to ready.")
  # logger.info("Pod status was updated",
  #             {"pod"=>"kube-system/kube-dns", "status"=>"ready"})
  #
  # # Prints to the console:
  # # "I0528 19:15:22.737538   47512] Pod kube-system/kube-dns status was updated to ready
  # # "I0528 19:15:22.737538   47512] "Pod status was updated" pod="kube-system/kube-dns" status="ready"
  # ```
  #
  # # Explanation of header:
  # #
  # # ```
  # # Lmmdd hh:mm:ss.uuuuuu threadid file:line] msg...
  # #
  # # where the fields are defined as follows:
  # #   L                A single character, representing the log level (eg 'I' for INFO)
  # #   mm               The month (zero padded; ie May is '05')
  # #   dd               The day (zero padded)
  # #   hh:mm:ss.uuuuuu  Time in hours, minutes and fractional seconds
  # #   threadid         The space-padded thread ID as returned by GetTID()
  # #   msg              The user-supplied message
  # # ```
  #
  # logger.formatter = Logger::Formatter.new do |verbosity, severity, datetime, message, context, io|
  #   label = severity.unknown? ? "ANY" : severity.to_s
  #   io << label[0] << ", [" << datetime << " #" << Process.pid << "] "
  #   io << label.rjust(5) << " -- " << message
  # end
  #
  # logger.warn("Fear leads to anger. Anger leads to hate. Hate leads to suffering.")
  #
  # # Prints to the console:
  # # "W, [2017-05-06 18:00:41 -0300 #11927]  WARN --
  # #  Fear leads to anger. Anger leads to hate. Hate leads to suffering."
  #
  property formatter

  # A logger severity level.
  enum Severity
    # Low-level information for developers
    DEBUG

    # Generic (useful) information about system operation
    INFO

    # A warning
    WARN

    # A handleable error condition
    ERROR

    # An unhandleable error that results in a program crash
    FATAL

    UNKNOWN
  end

  alias Formatter = Int8, Severity, Time, String, Hash(String, String), IO ->

  private DEFAULT_FORMATTER = Formatter.new do |verbosity, severity, datetime, message, context, io|
    if verbosity == 0
      io << message
      next
    end
    label = severity.unknown? ? "ANY" : severity.to_s
    io << label[0] << datetime.to_s("%m%d %T.%6N") << "   " << Process.pid << "] "
    if context.size > 0
      context_text = context.reduce("") { |result, a| result += " #{a[0]}=#{a[1]}"}
      io << "\"" << message << "\"" << context_text
    else
      io << message
    end
  end

  private DEFAULT_VERBOSITY = 4_i8

  record Message,
    verbosity : Int8,
    severity : Severity,
    datetime : Time,
    message : String

  # Creates a new logger that will log to the given *io*.
  # If *io* is `nil` then all log calls will be silently ignored.
  def initialize(@io : IO?, @level : Int8 = 0_i8, @formatter = DEFAULT_FORMATTER)
    @closed = false
    @mutex = Mutex.new(:unchecked)
  end

  # Calls the *close* method on the object passed to `initialize`.
  def close
    return if @closed
    return unless io = @io
    @closed = true

    @mutex.synchronize do
      io.close
    end
  end

  {% for name in Severity.constants %}
    {{name.id}} = Severity::{{name.id}}

    # Logs *message* if the logger's current severity is lower or equal to `{{name.id}}`.
    # *progname* overrides a default progname set in this logger.
    def {{name.id.downcase}}(message : String, context : Hash(String, String) = Hash(String, String).new)
      log(DEFAULT_VERBOSITY, Severity::{{name.id}}, message, context)
    end

    # Logs *message* if the logger's current severity is lower or equal to `{{name.id}}`.
    # *progname* overrides a default progname set in this logger.
    def {{name.id.downcase}}(verbosity : Int, message : String, context : Hash(String, String) = Hash(String, String).new)
      log(verbosity.to_i8, Severity::{{name.id}}, message, context)
    end
  {% end %}

  # Logs *message* if *verbosity* is higher or equal with the logger's current
  # severity. *progname* overrides a default progname set in this logger.
  def log(verbosity, severity, message : String, context : Hash(String, String) = Hash(String, String).new)
    return if verbosity > level || !@io
    write(verbosity, severity, Time.local, message, context)
  end

  private def write(verbosity, severity, datetime, message : String, context : Hash(String, String))
    io = @io
    return unless io

    @mutex.synchronize do
      formatter.call(verbosity, severity, datetime, message, context, io)
      io.puts
      io.flush
    end
  end
end
