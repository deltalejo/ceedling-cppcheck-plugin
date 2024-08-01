require 'ceedling/plugin'
require 'cppcheck_constants'

class Cppcheck < Plugin
  def setup
    @cacheinator = @ceedling[:cacheinator]
    @configurator = @ceedling[:configurator]
    @file_path_collection_utils = @ceedling[:file_path_collection_utils]
    @file_wrapper = @ceedling[:file_wrapper]
    @loginator = @ceedling[:loginator]
    @setupinator = @ceedling[:setupinator]
    @tool_executor = @ceedling[:tool_executor]
    @tool_validator = @ceedling[:tool_validator]

    @config = @setupinator.config_hash[CPPCHECK_SYM]
    
    validate_enabled_reports()
    
    if @config[:reports].include?(CppcheckReportTypes::HTML)
      @tool_validator.validate(
        tool: TOOLS_CPPCHECK_HTMLREPORT,
        boom: true
      )
    end
    
    @configurator.replace_flattened_config(
      collect_suppressions(@configurator.project_config_hash)
    )
    
    @text_artifact_filepath = form_text_artifact_filepath(
      @config[:text_artifact_filename] || CPPCHECK_ARTIFACTS_FILE_TEXT
    )
    
    @xml_artifact_filepath = form_xml_artifact_filepath(
      @config[:xml_artifact_filename] || CPPCHECK_ARTIFACTS_FILE_XML
    )
  end
  
  def generate_reports()
    args_common = args_builder_common()
    args_common << "--enable=all"
    
    if @config[:reports].include?(CppcheckReportTypes::TEXT)
      generate_text_report(args_common)
    end
    
    if @config[:reports].include?(CppcheckReportTypes::XML)
      generate_xml_report(args_common)
    end
    
    if @config[:reports].include?(CppcheckReportTypes::HTML)
      generate_html_report(args_common)
    end
  end
  
  def analyze_file(filepath)
    args = args_builder_common()
    
    unless @config[:enable_checks].nil? || @config[:enable_checks].empty?
      args << "--enable=#{@config[:enable_checks].join(',')}"
    end
    
    args << "\"#{filepath}\""
    COLLECTION_PATHS_INCLUDE.each do |path_include|
      args << "-I\"#{path_include}\""
    end
    
    @loginator.log("Analysing #{filepath}...", Verbosity::NORMAL)
    results = run(TOOLS_CPPCHECK, args)
    @loginator.log(results[:output], Verbosity::COMPLAIN, LogLabels::NONE)
  end
  
  private
  
  def validate_enabled_reports(boom:false)
    all_valid = @config[:reports].all? do |report|
      valid = CppcheckReportTypes::is_supported?(report)
      @loginator.log(
        "Report '#{report}' is not supported.",
        Verbosity::ERRORS
      ) unless valid
      valid
    end
    
    if boom and !all_valid
      raise CeedlingException.new("Not supported reports have been requested.")
    end
  end
  
  def collect_suppressions(in_hash)
    all_suppressions = @file_wrapper.instantiate_file_list
    
    in_hash[:collection_paths_cppcheck].each do |path|
      if @file_wrapper.exist?(path) && !@file_wrapper.directory?(path)
        all_suppressions.include(path)
      else
        all_suppressions.include(File.join(path, '*.xml') )
        all_suppressions.include(File.join(
          path,
          "*#{in_hash[:extension_cppcheck]}")
        )
      end
    end
    
    @file_path_collection_utils.revise_filelist(
      all_suppressions,in_hash[:files_cppcheck]
    )

    return {
      :collection_all_cppcheck => all_suppressions
    }
  end
  
  def form_text_artifact_filepath(filename)
    return File.join(
      CPPCHECK_ARTIFACTS_PATH,
      File.basename(filename).ext('.txt')
    )
  end
  
  def form_xml_artifact_filepath(filename)
    return File.join(
      CPPCHECK_ARTIFACTS_PATH,
      File.basename(filename).ext('.xml')
    )
  end
  
  def args_builder_common()
    args = []
    
    args << "--cppcheck-build-dir=#{CPPCHECK_BUILD_PATH}"
    
    unless @config[:platform].nil? || @config[:platform].empty?
      args << "--platform=#{@config[:platform]}"
    end
    
    unless @config[:template].nil? || @config[:template].empty?
      args << "--template=#{@config[:template]}"
    end
    
    unless @config[:standard].nil? || @config[:standard].empty?
      args << "--std=#{@config[:standard]}"
    end
    
    args << "--inline-suppr" if @config[:inline_suppressions] == true
    
    unless @config[:check_level].nil? || @config[:check_level].empty?
      args << "--check-level=#{@config[:check_level]}"
    end
    
    unless @config[:disable_checks].nil? || @config[:disable_checks].empty?
      args << "--disable=#{@config[:disable_checks].join(',')}"
    end
    
    @config[:addons]&.each do |addon|
      args << "--addon=#{addon}"
    end
    
    @config[:includes]&.each do |include|
      args << "--include=#{include}"
    end
    
    @config[:excludes]&.each do |exclude|
      args << "-i#{exclude}"
    end
    
    @config[:libraries]&.each do |library|
      args << "--library=#{library}"
    end
    
    @config[:rules]&.each do |rule|
      args << "--rule=#{rule}"
    end
    
    COLLECTION_ALL_CPPCHECK.each do |suppression|
      option = suppression.end_with?('.xml')? '--suppress-xml' : '--suppressions-list'
      args << "#{option}=#{suppression}"
    end
    
    @config[:suppressions]&.each do |suppression|
      args << "--suppress=#{suppression}"
    end
    
    @config[:defines]&.each do |define|
      args << "-D#{define}"
    end
    
    @config[:undefines]&.each do |undefine|
      args << "-U#{undefine}"
    end

    @config[:arguments]&.each do |argument|
      args << "#{argument}"
    end

    return args
  end

  def args_project_builder()
    args = []
    
    if @config[:project].nil? || @config[:project].empty?
      COLLECTION_PATHS_INCLUDE.each do |path_include|
        args << "-I\"#{path_include}\""
      end
      COLLECTION_PATHS_SOURCE.each do |path_source|
        args << "\"#{path_source}\""
      end
    else
      args << "--project=#{@config[:project]}"
    end

    return args
  end
  
  def args_builder_text()
    return [
      "--output-file=#{@text_artifact_filepath}"
    ]
  end
  
  def args_builder_xml()
    return [
      "--xml",
      "--output-file=#{@xml_artifact_filepath}"
    ]
  end
  
  def args_builder_html()
    args = []
    
    args << "--file=#{@xml_artifact_filepath}"
    args << "--report-dir=#{CPPCHECK_ARTIFACTS_HTML_PATH}"
    args << "--source-dir=."
    
    unless @config[:html_title].nil? || @config[:html_title].empty?
      args << "--title=#{@config[:html_title]}"
    end
    
    return args
  end
  
  def run(tool, args, *params)
    command = @tool_executor.build_command_line(
      tool,
      args,
      *params
    )
    @loginator.log("Command: #{command}", Verbosity::DEBUG)
    
    results = @tool_executor.exec(command)
    
    return results
  end
  
  def generate_text_report(args_common)
    args = args_project_builder()
    args += args_common.dup()
    args += args_builder_text()
    
    @loginator.log("Creating Cppcheck text report...", Verbosity::NORMAL)
    results = run(TOOLS_CPPCHECK, args)
  end
  
  def generate_xml_report(args_common)
    args = args_project_builder()
    args += args_common.dup()
    args += args_builder_xml()
    
    @loginator.log("Creating Cppcheck xml report...", Verbosity::NORMAL)
    results = run(TOOLS_CPPCHECK, args)
  end
  
  def generate_html_report(args_common)
    args = args_common.dup()
    generate_xml_report(args) unless @file_wrapper.exist?(@xml_artifact_filepath)
    
    @loginator.log("Creating Cppcheck html report...", Verbosity::NORMAL)
    run(TOOLS_CPPCHECK_HTMLREPORT, args_builder_html())
  end
end

# end blocks always executed following rake run
END {
  # cache our input configurations to use in comparison upon next execution
  if @ceedling[:task_invoker].invoked?(/^#{CPPCHECK_TASK_ROOT}/)
    @ceedling[:cacheinator].cache_test_config(@ceedling[:setupinator].config_hash)
  end
}
