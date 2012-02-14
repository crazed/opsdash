class String
  # removes a trailing slash
  def chop_slash
    self.gsub(/\/$/,'')
  end

  # removes slashes before and after a string
  def strip_slashes
    self.gsub(/(^\/|\/$)/,'')
  end
end
