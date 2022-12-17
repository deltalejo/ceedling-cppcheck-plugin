require 'ceedling/plugin'

CPPCHECK_ROOT_NAME  = 'cppcheck'.freeze
CPPCHECK_TASK_ROOT  = CPPCHECK_ROOT_NAME + ':'
CPPCHECK_SYM        = CPPCHECK_ROOT_NAME.to_sym

CPPCHECK_BUILD_PATH = File.join(PROJECT_BUILD_ROOT, CPPCHECK_ROOT_NAME)

class Cppcheck < Plugin
  def setup
    @config = @ceedling[:setupinator].config_hash[CPPCHECK_SYM]
    @tool = @ceedling[:setupinator].config_hash[:tools][CPPCHECK_SYM]
    @config[:addons].each do |addon|
      @tool[:arguments] << "--addon=#{addon}"
    end
    @config[:defines].each do |define|
      @tool[:arguments] << "-D#{define}"
    end
    @config[:undefines].each do |undefine|
      @tool[:arguments] << "-U#{undefine}"
    end
    @config[:options].each do |option|
      @tool[:arguments] << option
    end
    @tool[:arguments] << '${1}'
  end
end
