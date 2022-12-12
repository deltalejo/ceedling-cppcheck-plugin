directory CPPCHECK_BUILD_DIR

CLOBBER.include(File.join(CPPCHECK_BUILD_DIR, "*"))

desc "Run static analysis with Cppcheck"
task cppcheck: [CPPCHECK_BUILD_DIR] do
  
end
