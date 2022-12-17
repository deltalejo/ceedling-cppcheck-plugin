directory(CPPCHECK_BUILD_PATH)

CLEAN.include(File.join(CPPCHECK_BUILD_PATH, '*'))

CLOBBER.include(File.join(CPPCHECK_BUILD_PATH, '**/*'))

task :cppcheck_deps => [CPPCHECK_BUILD_PATH]

task :cppcheck => [:cppcheck_deps] do
  Rake.application['cppcheck:all'].invoke
end

namespace :cppcheck do
  desc 'Run analysis on whole project.'
  task :all => [:cppcheck_deps] do
    command = @ceedling[:tool_executor].build_command_line(
      TOOLS_CPPCHECK,
      ['--enable=all'],
      COLLECTION_PATHS_SOURCE
    )
    @ceedling[:tool_executor].exec(command[:line], command[:options])
  end
  
  desc "Run analysis on single file ([*] real source file name, no path)."
  task :* do
    message = "\nOops! '#{CPPCHECK_ROOT_NAME}:*' isn't a real task. " +
              "Use a real source file name (no path) in place of the wildcard.\n" +
              "Example: rake #{CPPCHECK_ROOT_NAME}:foo.c\n\n"

    @ceedling[:streaminator].stdout_puts( message )
  end
end

rule(/^#{CPPCHECK_TASK_ROOT}\S+$/ => [
  proc do |tn|
    name = tn.sub(/^#{CPPCHECK_TASK_ROOT}/, '')
    @ceedling[:file_finder].find_source_file(name, :error)
  end
]) do |t|
  command = @ceedling[:tool_executor].build_command_line(
    TOOLS_CPPCHECK,
    [],
    t.source
  )
  @ceedling[:tool_executor].exec(command[:line], command[:options])
end
