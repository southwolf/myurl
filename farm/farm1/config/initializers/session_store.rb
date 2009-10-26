# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_farm1_session',
  :secret      => '05afadd36169af8adbbd6df312d6d7b5d7cdb70ea343d512e5b42a1b9a90e33a5a4606439e3d43ba0b81c733fa45201be228a3fcaec84fe7a74c492439032cd6'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
