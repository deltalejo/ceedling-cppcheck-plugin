require 'ceedling/plugin'
require 'cppcheck_defaults'

CPPCHECK_ROOT_NAME          = 'cppcheck'.freeze
CPPCHECK_TASK_ROOT          = CPPCHECK_ROOT_NAME + ':'
CPPCHECK_SYM                = CPPCHECK_ROOT_NAME.to_sym
CPPCHECK_HTMLREPORT_SYM     = CPPCHECK_ROOT_NAME + '_htmlreport'

CPPCHECK_BUILD_PATH         = File.join(PROJECT_BUILD_ROOT, CPPCHECK_ROOT_NAME)
CPPCHECK_ARTIFACTS_PATH     = File.join(PROJECT_BUILD_ARTIFACTS_ROOT, CPPCHECK_ROOT_NAME)

CPPCHECK_ARTIFACTS_FILE     = File.join(CPPCHECK_ARTIFACTS_PATH, 'CppcheckResults.txt')
CPPCHECK_ARTIFACTS_FILE_XML = File.join(CPPCHECK_ARTIFACTS_PATH, File.basename(CPPCHECK_ARTIFACTS_FILE, '.*') + '.xml')

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
    @tool = project_config[:tools][CPPCHECK_SYM]
    @htmlreport_tool = project_config[:tools][CPPCHECK_HTMLREPORT_SYM]
    
    if @config[:html_report] && (!@config[:file_report] || !@config[:xml_report])
      raise 'File and XML reports must be enabled when asking for HTML report.'
    end
    
    @tool[:arguments] << '--xml' if @config[:xml_report]
    
    if @config[:file_report]
      if @config[:xml_report]
        @output_file = @config[:xml][:artifact_filename] || CPPCHECK_ARTIFACTS_FILE_XML
      else
        @output_file = @config[:text][:artifact_filename] || CPPCHECK_ARTIFACTS_FILE
      end
      
      @tool[:arguments] << "--output-file=#{@output_file}"
    end
    
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
    
    config = {
      :tools => {
        :cppcheck => @tool,
        :cppcheck_htmlreport => @htmlreport_tool
      }
    }
    @ceedling[:configurator].build_supplement(project_config, config)
  end
  
  def config
    return @config
  end
  
  def html_report_options
    options = [
      "--file=#{@output_file}",
      "--report-dir=#{File.join(CPPCHECK_ARTIFACTS_PATH, 'html')}",
      "--source-dir=#{PROJECT_ROOT}"
    ]
    options << "--title=#{@config[:html][:title]}" unless @config[:html][:title].nil?
    
    return options
  end
end
