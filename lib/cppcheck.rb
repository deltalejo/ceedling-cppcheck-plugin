require 'ceedling/plugin'

CPPCHECK_ROOT_NAME = 'cppcheck'.freeze
CPPCHECK_SYM       = CPPCHECK_ROOT_NAME.to_sym
CPPCHECK_BUILD_DIR = File.join(PROJECT_BUILD_ROOT, CPPCHECK_ROOT_NAME)

class Cppcheck < Plugin
  def setup
	
  end
end
