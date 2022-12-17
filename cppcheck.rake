directory(CPPCHECK_BUILD_PATH)

CLOBBER.include(File.join(CPPCHECK_BUILD_PATH, '*'))

task :cppcheck_deps => [CPPCHECK_BUILD_PATH]

task :cppcheck => [:cppcheck_deps] do 
  Rake.application['cppcheck:all'].invoke
end

namespace :cppcheck do
  desc 'Run static code analysis with Cppcheck'
  task :all => [:cppcheck_deps] do
    command = @ceedling[:tool_executor].build_command_line(
      TOOLS_CPPCHECK,
      ['--enable=all'],
      COLLECTION_PATHS_SOURCE
    )
    @ceedling[:tool_executor].exec(command[:line], command[:options])
  end
end
