require 'ceedling/plugin'
require 'cppcheck_defaults'

CPPCHECK_ROOT_NAME           = 'cppcheck'.freeze
CPPCHECK_TASK_ROOT           = CPPCHECK_ROOT_NAME + ':'
CPPCHECK_SYM                 = CPPCHECK_ROOT_NAME.to_sym
CPPCHECK_HTMLREPORT_SYM      = (CPPCHECK_ROOT_NAME + '_htmlreport').to_sym

CPPCHECK_BUILD_PATH          = File.join(PROJECT_BUILD_ROOT, CPPCHECK_ROOT_NAME)
CPPCHECK_ARTIFACTS_PATH      = File.join(PROJECT_BUILD_ARTIFACTS_ROOT, CPPCHECK_ROOT_NAME)

CPPCHECK_ARTIFACTS_FILE_TEXT = File.join(CPPCHECK_ARTIFACTS_PATH, 'CppcheckResults.txt')
CPPCHECK_ARTIFACTS_FILE_XML  = File.join(CPPCHECK_ARTIFACTS_PATH, File.basename(CPPCHECK_ARTIFACTS_FILE_TEXT, '.*') + '.xml')
CPPCHECK_ARTIFACTS_FILE_HTML = File.join(CPPCHECK_ARTIFACTS_PATH, File.basename(CPPCHECK_ARTIFACTS_FILE_TEXT, '.*') + '.html')

class Cppcheck < Plugin
  def setup
    project_config = @ceedling[:setupinator].config_hash
    cppcheck_defaults = {
      :tools => {
        :cppcheck => DEFAULT_CPPCHECK_TOOL,
        :cppcheck_htmlreport => DEFAULT_CPPCHECK_HTMLREPORT_TOOL
      }
    }
    @ceedling[:configurator_builder].populate_defaults(project_config, cppcheck_defaults)
    
    @config = project_config[CPPCHECK_SYM]
    @cppcheck = project_config[:tools][CPPCHECK_SYM]
    @cppcheck_htmlreport = project_config[:tools][CPPCHECK_HTMLREPORT_SYM]
    
    @config[:text_artifact_filename] ||= CPPCHECK_ARTIFACTS_FILE_TEXT
    @config[:xml_artifact_filename] ||= CPPCHECK_ARTIFACTS_FILE_XML
    @config[:html_artifact_filename] ||= CPPCHECK_ARTIFACTS_FILE_HTML
    
    unless @config[:platform].nil? || @config[:platform].empty?
      @cppcheck[:arguments] << "--platform=#{@config[:platform]}"
    end
    
    unless @config[:template].nil? || @config[:template].empty?
      @cppcheck[:arguments] << "--template=#{@config[:template]}"
    end
    
    unless @config[:standard].nil? || @config[:standard].empty?
      @cppcheck[:arguments] << "--std=#{@config[:standard]}"
    end
    
    @cppcheck[:arguments] << "--inline-suppr" if @config[:inline_suppressions] == true
    
    unless @config[:enable_checks].nil? || @config[:enable_checks].empty?
      @cppcheck[:arguments] << "--enable=#{@config[:enable_checks].join(',')}"
    end
    
    unless @config[:disable_checks].nil? || @config[:disable_checks].empty?
      @cppcheck[:arguments] << "--disable=#{@config[:disable_checks].join(',')}"
    end
    
    @config[:addons]&.each do |addon|
      @cppcheck[:arguments] << "--addon=#{addon}"
    end
    
    @config[:includes]&.each do |include|
      @cppcheck[:arguments] << "--include=#{include}"
    end
    
    @config[:libraries]&.each do |library|
      @cppcheck[:arguments] << "--library=#{library}"
    end
    
    @config[:rules]&.each do |rule|
      @cppcheck[:arguments] << "--rule=#{rule}"
    end
    
    @config[:suppressions]&.each do |suppression|
      @cppcheck[:arguments] << "--suppress=#{suppression}"
    end
    
    @config[:defines]&.each do |define|
      @cppcheck[:arguments] << "-D#{define}"
    end
    
    @config[:undefines]&.each do |undefine|
      @cppcheck[:arguments] << "-U#{undefine}"
    end
    
    @config[:options]&.each do |option|
      @cppcheck[:arguments] << option
    end
    
    @cppcheck[:arguments] << '${1}'
    
    @cppcheck_htmlreport[:arguments] << "--file=#{@config[:xml_artifact_filename]}"
    @cppcheck_htmlreport[:arguments] << "--report-dir=#{File.join(CPPCHECK_ARTIFACTS_PATH, 'html')}"
    @cppcheck_htmlreport[:arguments] << "--source-dir=#{PROJECT_ROOT}"
    unless @config[:html_title].nil? || @config[:html_title].empty?
      @cppcheck_htmlreport[:arguments] << "--title=#{@config[:html_title]}"
    end
    
    tools = {
      :cppcheck => @cppcheck,
      :cppcheck_htmlreport => @cppcheck_htmlreport
    }
    @ceedling[:configurator].build_supplement(project_config, {:cppcheck => @config, :tools => tools})
  end
end
