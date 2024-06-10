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
    @ceedling[CPPCHECK_SYM].generate_reports()
  end
  
  desc "Run single file analysis ([*] source file name, no path)."
  task :* do
    message = "Oops! '#{CPPCHECK_ROOT_NAME}:*' isn't a real task. " +
              "Use a real source file name (no path) in place of the wildcard.\n" +
              "Example: `ceedling #{CPPCHECK_ROOT_NAME}:foo.c`"

    @ceedling[:loginator].log(message, Verbosity::ERRORS)
  end
end

rule /^#{CPPCHECK_TASK_ROOT}\S+$/ => [
  proc do |task_name|
    name = task_name.sub(/^#{CPPCHECK_TASK_ROOT}/, '')
    ['cppcheck_deps', @ceedling[:file_finder].find_source_file(name)]
  end
] do |task|
  @ceedling[CPPCHECK_SYM].analyze_file(task.sources[1])
end

namespace :files do
  desc 'List all collected Cppcheck suppressions files.'
  task :cppcheck do
    puts "Cppcheck suppressions files:#{' None' if COLLECTION_ALL_CPPCHECK.empty?}"
    COLLECTION_ALL_CPPCHECK.sort.each do |filepath|
      puts " - #{filepath}"
    end
    puts "file count: #{COLLECTION_ALL_CPPCHECK.size}" unless COLLECTION_ALL_CPPCHECK.empty?
  end
end
