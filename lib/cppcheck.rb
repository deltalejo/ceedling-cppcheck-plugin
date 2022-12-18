require 'ceedling/plugin'

CPPCHECK_ROOT_NAME  = 'cppcheck'.freeze
CPPCHECK_TASK_ROOT  = CPPCHECK_ROOT_NAME + ':'
CPPCHECK_SYM        = CPPCHECK_ROOT_NAME.to_sym

CPPCHECK_BUILD_PATH = File.join(PROJECT_BUILD_ROOT, CPPCHECK_ROOT_NAME)
CPPCHECK_ARTIFACTS_PATH = File.join(PROJECT_BUILD_ARTIFACTS_ROOT, CPPCHECK_ROOT_NAME)

CPPCHECK_ARTIFACTS_FILE = File.join(CPPCHECK_ARTIFACTS_PATH, 'CppcheckResults.txt')
CPPCHECK_ARTIFACTS_FILE_XML = File.join(CPPCHECK_ARTIFACTS_PATH, File.basename(CPPCHECK_ARTIFACTS_FILE, '.*') + '.xml')

class Cppcheck < Plugin
  def setup
    @config = @ceedling[:setupinator].config_hash[CPPCHECK_SYM]
    @tool = @ceedling[:setupinator].config_hash[:tools][CPPCHECK_SYM]
    
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
