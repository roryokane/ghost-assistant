require 'logger'

LOGGER = Logger.new(STDOUT)
LOGGER.formatter = proc do |severity, datetime, progname, msg|
	"[#{datetime}]  #{msg}\n"
end
LOGGER.level = Logger::WARN
