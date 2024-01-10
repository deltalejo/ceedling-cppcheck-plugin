DEFAULT_CPPCHECK_TOOL = {
  :executable => (ENV['CPPCHECK'].nil? ? FilePathUtils.os_executable_ext('cppcheck') : ENV['CPPCHECK'].split[0]).freeze,
  :name => 'default_cppcheck'.freeze,
  :stderr_redirect => StdErrRedirect::AUTO.freeze,
  :optional => false.freeze,
  :arguments => [
    '--cppcheck-build-dir=#{CPPCHECK_BUILD_PATH}'.freeze,
    {'-I$' => 'COLLECTION_PATHS_INCLUDE'}.freeze
  ].freeze
}

DEFAULT_CPPCHECK_HTMLREPORT_TOOL = {
  :executable => (ENV['CPPCHECK_HTMLREPORT'].nil? ? FilePathUtils.os_executable_ext('cppcheck-htmlreport') : ENV['CPPCHECK_HTMLREPORT'].split[0]).freeze,
  :name => 'default_cppcheck_htmlreport'.freeze,
  :stderr_redirect => StdErrRedirect::NONE.freeze,
  :optional => false.freeze,
  :arguments => [].freeze
}
