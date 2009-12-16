# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '1.2.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  RAILS_DEFAULT_LOGGER = Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}.log", 1, 2*1024*1024)
  # Settings in config/environments/* take precedence over those specified here
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
  config.action_controller.consider_all_requests_local = false 
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile

# Include your application configuration below
ActiveRecord::Base.pluralize_table_names = false

$KCODE='n' 

require "iconv"
require "EncodeUtil"
class Object
  def gbk
    EncodeUtil.change("gb2312", "utf-8",  self.to_s)
  end
end

$Debug_On = true
#$OS = "WINDOWS" 
$OS = "UNIX" 
$Templates = Hash.new
$Workflows = Hash.new

#采用oracle数据库时，$TEXT=:text, mysql则为:longtext
$TEXT = :longtext
#$TEXT = :text


require 'YtLog'
#begin
  templates = YtwgTemplate.find(:all)
  p "loading templates..."
  require 'XMLHelper'  
  for template in templates
    YtLog.info template.name
    helper = XMLHelper.new
    helper.ReadFromString(EncodeUtil.change("GB2312", "UTF-8", template.content))
    $Templates[template.name] = helper
  end
  
  require 'workflow/FlowMeta'
  FlowMeta.LoadAllFlows

#rescue Exception=>err
#  puts err.backtrace
  #YtLog.info err.to_s
  #p err.backtrace.join("\n") 
  
#end


log = YtwgEventlog.new
log.time_occured = Time.new
log.description = "OA重新启动"
log.save
        
$REBOOT = false
Thread.new() do 
  while true
    exit if $REBOOT
    sleep(10)
  end
end

filters = Logfilter.find(:all)
$FilterMap = {}
for filter in filters
  next if filter.log != 1
  if filter.action
    $FilterMap["/#{filter.controller}/#{filter.action}"] = filter.desc 
  else
    $FilterMap["/#{filter.controller}"] = filter.desc 
  end
end

$PRODUCT_STATUS = {nil=>"库存", 0=>"库存", 1=>"售出", 2=>"报废", 3=>"损坏", 4=>"被组装", 5=>"被拆装"}
$CONTRACT_STATUS = {nil=>"新合同", 0=>"新合同", 1=>"已领用", 3=>"报废", 4=>"退回"}