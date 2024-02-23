directory(CPPCHECK_BUILD_PATH)
directory(CPPCHECK_ARTIFACTS_PATH)

CLEAN.include(File.join(CPPCHECK_BUILD_PATH, '*'))
CLEAN.include(File.join(CPPCHECK_ARTIFACTS_PATH, '*'))

CLOBBER.include(File.join(CPPCHECK_BUILD_PATH, '**/*'))

task :cppcheck_deps => [:directories, CPPCHECK_BUILD_PATH, CPPCHECK_ARTIFACTS_PATH]
task :cppcheck => ['cppcheck:all']

namespace :cppcheck do
  desc "Run whole project analysis (also just 'cppcheck' works)."
  task :all => [:cppcheck_deps] do
    check_level = @ceedling[CPPCHECK_SYM].config[:check_level]
    check_level = 'exhaustive' if check_level.nil? || check_level.empty?
    
    extra_params = ['--quiet', '--enable=all', "--check-level=#{check_level}"]
    
    if CPPCHECK_REPORTS&.include?('text')
      command = @ceedling[:tool_executor].build_command_line(
        TOOLS_CPPCHECK,
        extra_params,
        COLLECTION_PATHS_SOURCE
      )
      @ceedling[:streaminator].stdout_puts("Creating Cppcheck text report...", Verbosity::NORMAL)
      @ceedling[:streaminator].stdout_puts("Command: #{command}", Verbosity::DEBUG)
      results = @ceedling[:tool_executor].exec(command[:line], command[:options])
      
      text_artifact_filename = @ceedling[:cppcheck].form_text_artifact_filepath(CPPCHECK_TEXT_ARTIFACT_FILENAME)
      File.open(text_artifact_filename, "w") do |fd|
        fd.write(results[:output])
      end
      @ceedling[:streaminator].stdout_puts(results[:output])
    end
    
    if ['xml', 'html'].any? {|report| CPPCHECK_REPORTS&.include?(report)}
      command = @ceedling[:tool_executor].build_command_line(
        TOOLS_CPPCHECK,
        extra_params + ['--xml'],
        COLLECTION_PATHS_SOURCE
      )
      @ceedling[:streaminator].stdout_puts("Creating Cppcheck xml report...", Verbosity::NORMAL)
      @ceedling[:streaminator].stdout_puts("Command: #{command}", Verbosity::DEBUG)
      results = @ceedling[:tool_executor].exec(command[:line], command[:options])
      
      xml_artifact_filename = @ceedling[:cppcheck].form_xml_artifact_filepath(CPPCHECK_XML_ARTIFACT_FILENAME)
      File.open(xml_artifact_filename, "w") do |fd|
        fd.write(results[:output])
      end
      
      if CPPCHECK_REPORTS&.include?('html')
        command = @ceedling[:tool_executor].build_command_line(TOOLS_CPPCHECK_HTMLREPORT, [])
        @ceedling[:streaminator].stdout_puts("Creating Cppcheck html report...", Verbosity::NORMAL)
        @ceedling[:streaminator].stdout_puts("Command: #{command}", Verbosity::DEBUG)
        @ceedling[:tool_executor].exec(command[:line], command[:options])
      end
    end
  end
  
  desc "Run single file analysis ([*] real source file name, no path)."
  task :* do
    message = "\nOops! '#{CPPCHECK_ROOT_NAME}:*' isn't a real task. " +
              "Use a real source file name (no path) in place of the wildcard.\n" +
              "Example: rake #{CPPCHECK_ROOT_NAME}:foo.c\n\n"

    @ceedling[:streaminator].stdout_puts( message )
  end
end

rule /^#{CPPCHECK_TASK_ROOT}\S+$/ => [
  proc do |tn|
    name = tn.sub(/^#{CPPCHECK_TASK_ROOT}/, '')
    @ceedling[:file_finder].find_source_file(name, :error)
  end
] do |t|
  enable_checks = @ceedling[CPPCHECK_SYM].config[:enable_checks]
  enable_checks = ['style'] if enable_checks.nil? || enable_checks.empty?
  
  extra_params = ['--quiet', "--enable=#{enable_checks.join(',')}"]
  
  @ceedling[:rake_wrapper][:cppcheck_deps].invoke
  
  command = @ceedling[:tool_executor].build_command_line(
    TOOLS_CPPCHECK,
    extra_params,
    t.source
  )
  @ceedling[:streaminator].stdout_puts("Cppcheck...", Verbosity::NORMAL)
  @ceedling[:streaminator].stdout_puts("Command: #{command}", Verbosity::DEBUG)
  results = @ceedling[:tool_executor].exec(command[:line], command[:options])
  @ceedling[:streaminator].stdout_puts(results[:output])
end

namespace :files do
  desc 'List all collected Cppcheck suppressions files.'
  task :cppcheck do
    puts 'Cppcheck suppressions files:'
    COLLECTION_ALL_CPPCHECK.sort.each { |filepath| puts " - #{filepath}" }
    puts "file count: #{COLLECTION_ALL_CPPCHECK.size}"
  end
end
