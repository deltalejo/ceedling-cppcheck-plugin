DEFAULT_CPPCHECK_TOOL = {
  :executable => (ENV['CPPCHECK'].nil? ? FilePathUtils.os_executable_ext('cppcheck') : ENV['CPPCHECK'].split[0]).freeze,
  :name => 'default_cppcheck'.freeze,
  :stderr_redirect => StdErrRedirect::NONE.freeze,
  :background_exec => BackgroundExec::NONE.freeze,
  :optional => false.freeze,
  :arguments => [
    '--cppcheck-build-dir=#{CPPCHECK_BUILD_PATH}'.freeze,
    {'-I$' => 'COLLECTION_PATHS_INCLUDE'}.freeze
  ].freeze
}

def get_default_config
  return :tools => {
    :cppcheck => DEFAULT_CPPCHECK_TOOL
  }
end
