directory(CPPCHECK_BUILD_PATH)
directory(CPPCHECK_ARTIFACTS_PATH)

CLEAN.include(File.join(CPPCHECK_BUILD_PATH, '*'))
CLEAN.include(File.join(CPPCHECK_ARTIFACTS_PATH, '*'))

CLOBBER.include(File.join(CPPCHECK_BUILD_PATH, '**/*'))

task :cppcheck_deps => [CPPCHECK_BUILD_PATH, CPPCHECK_ARTIFACTS_PATH]

task :cppcheck => ['cppcheck:all']

namespace :cppcheck do
  desc "Run whole project analysis (also just 'cppcheck' works)."
  task :all => [:cppcheck_deps] do
    command = @ceedling[:tool_executor].build_command_line(
      TOOLS_CPPCHECK,
      ['--enable=all'],
      COLLECTION_PATHS_SOURCE
    )
    results = @ceedling[:tool_executor].exec(command[:line], command[:options])
    
    if @ceedling[CPPCHECK_SYM].config[:html_report]
      command = @ceedling[:tool_executor].build_command_line(
        TOOLS_CPPCHECK_HTMLREPORT,
        @ceedling[CPPCHECK_SYM].html_report_options
      )
      @ceedling[:tool_executor].exec(command[:line], command[:options])
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
    Rake.application['cppcheck_deps'].invoke
    command = @ceedling[:tool_executor].build_command_line(
      TOOLS_CPPCHECK,
      [],
      t.source
    )
    @ceedling[:tool_executor].exec(command[:line], command[:options])
  end
