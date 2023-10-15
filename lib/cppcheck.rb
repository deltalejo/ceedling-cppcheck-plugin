require 'ceedling/plugin'
require 'cppcheck_defaults'

CPPCHECK_ROOT_NAME           = 'cppcheck'.freeze
CPPCHECK_TASK_ROOT           = CPPCHECK_ROOT_NAME + ':'
CPPCHECK_SYM                 = CPPCHECK_ROOT_NAME.to_sym
CPPCHECK_HTMLREPORT_SYM      = (CPPCHECK_ROOT_NAME + '_htmlreport').to_sym

CPPCHECK_BUILD_PATH          = File.join(PROJECT_BUILD_ROOT, CPPCHECK_ROOT_NAME)
CPPCHECK_ARTIFACTS_PATH      = File.join(PROJECT_BUILD_ARTIFACTS_ROOT, CPPCHECK_ROOT_NAME)
CPPCHECK_ARTIFACTS_HTML_PATH = File.join(CPPCHECK_ARTIFACTS_PATH, 'html')

CPPCHECK_ARTIFACTS_FILE_TEXT = 'CppcheckReport.txt'
CPPCHECK_ARTIFACTS_FILE_XML  = File.basename(CPPCHECK_ARTIFACTS_FILE_TEXT).ext('.xml')

class Cppcheck < Plugin
  attr_reader :config
  
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
    
    @config[:reports] = ['text'] if @config[:reports].nil? || @config[:reports].empty?
    @config[:text_artifact_filename] ||= CPPCHECK_ARTIFACTS_FILE_TEXT
    @config[:xml_artifact_filename] ||= CPPCHECK_ARTIFACTS_FILE_XML
    
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
    
    suppressions = collect_suppressions(@ceedling[:configurator].project_config_hash)
    suppressions&.each do |suppression|
      option = suppression.end_with?('.xml')? '--suppress-xml' : '--suppressions-list'
      @cppcheck[:arguments] << "#{option}=#{suppression}"
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
    
    xml_artifact_filename = form_xml_artifact_filepath(@config[:xml_artifact_filename])
    
    @cppcheck_htmlreport[:arguments] << "--file=#{xml_artifact_filename}"
    @cppcheck_htmlreport[:arguments] << "--report-dir=#{CPPCHECK_ARTIFACTS_HTML_PATH}"
    @cppcheck_htmlreport[:arguments] << "--source-dir=#{PROJECT_ROOT}"
    unless @config[:html_title].nil? || @config[:html_title].empty?
      @cppcheck_htmlreport[:arguments] << "--title=#{@config[:html_title]}"
    end
    
    @ceedling[:configurator].build_supplement(
      project_config,
      {
        :cppcheck => @config,
        :tools => {
          :cppcheck => @cppcheck,
          :cppcheck_htmlreport => @cppcheck_htmlreport
        },
        :collection_all_cppcheck => suppressions
      }
    )
  end
  
  def form_text_artifact_filepath(filename)
    return File.join(CPPCHECK_ARTIFACTS_PATH, File.basename(filename).ext('.txt'))
  end
  
  def form_xml_artifact_filepath(filename)
    return File.join(CPPCHECK_ARTIFACTS_PATH, File.basename(filename).ext('.xml'))
  end
  
  private
  
  def collect_suppressions(in_hash)
    all_suppressions = @ceedling[:file_wrapper].instantiate_file_list
    in_hash[:collection_paths_cppcheck].each do |path|
      if File.exists?(path) and not File.directory?(path)
        all_suppressions.include( path )
      else
        all_suppressions.include( File.join(path, '*.xml') )
        all_suppressions.include( File.join(path, "*#{in_hash[:extension_cppcheck]}") )
      end
    end
    @ceedling[:file_system_utils].revise_file_list( all_suppressions, in_hash[:files_cppcheck] )

    return all_suppressions
  end
end
