# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.3' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  #config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end

$KAIXIN_FARM_CLIENT = {}

require 'rufus/scheduler'
require 'kaixinfarm'
require 'kaixinuser'

scheduler = Rufus::Scheduler.start_new
scheduler.every("1m") do
   now = Time.new
   tasks = Kaixintask.find_by_sql("select * from kaixintasks where finished = 0 and stopflag = 0 and occurtime < '#{now.to_formatted_s(:db)}' group by kaixinuserid, occurtime order by occurtime")
   for task in tasks
     s = Rufus::Scheduler.start_new
     t = s.at(task.occurtime) do |t|
       kaixin_user = Kaixinuser.find(:first, :conditions=>"code = #{t.tags[0].kaixinuserid}")
       tasks = Kaixintask.find(:all, :conditions=>"occurtime = '#{task.occurtime.to_formatted_s(:db)}' and kaixinuserid=#{task.kaixinuserid}")
       farm = KaixinFarm.new
       if farm.login(kaixin_user.name, kaixin_user.password)      #成功登陆
          for task in tasks
            if task.tasktype == 1
              task.num, task.desc = farm.harvest(task.kaixinfriendid, task.farmnum)
            else
              task.desc = '其他任务'
            end
            task.finished = 1
            task.save
          end
       end
     end
     t.tags << task
   end
end