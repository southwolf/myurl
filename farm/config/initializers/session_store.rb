# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_farm_session',
  :secret      => '05a19d03379fce179c44d8174edffe2e7262d6b44a8ed6f5e4cad2f1b41035c7ecdb6ba6c55e579540a2f55c4bc63d7646eb725486c300580243edb346616cb9'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
