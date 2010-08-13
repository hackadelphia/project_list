class DB
  # XXX
  #
  # authentication is likely vulnerable to a classic replay attack. I don't
  # really care that much.
  #
  # Additionally, the digest isn't a HMAC which has its own set of problems.
  # again with the not caring.
  #
  def plain_authenticated?(username, password)
    return false unless username
    this_user = user(username)
    return false unless this_user
    password_hash(password) == this_user.password
  end

  def crypt_authenticated?(username, crypt_password)
    return false unless username
    this_user = user(username)
    return false unless this_user
    crypt_password == this_user.password
  end

  def password_hash(password)
    Digest::SHA1.hexdigest(password)
  end

end
