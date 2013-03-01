require 'nag'

Logging.configure do
  
  Logging.logger.root.level = :debug
  Logging.logger.root.appenders = [Logging.appenders.file( 'log/test.log' )]

  # here we setup a color scheme called 'bright'
  Logging.color_scheme( 'bright',
    :levels => {
      :info  => :green,
      :warn  => :yellow,
      :error => :red,
      :fatal => [:white, :on_red]
    },
    :date => :blue,
    :logger => :cyan,
    :message => :magenta
  )

  Logging.appenders.stdout(
    'colourful_stdout',
    :layout => Logging.layouts.pattern(
      :pattern => '[%d] %-5l %c: %m\n',
      :color_scheme => 'bright'
    )
  )

  test_loggers = %w{ scheduled_task_test credit_control_test scheduled_test scheduled }
  # test_loggers = []
    
  test_loggers.each do |name|
    Logging.logger[name].tap {|logger| 
      logger.add_appenders 'colourful_stdout'
      logger.level = :info
    }
  end
  
end

require 'aasm'
require 'logging'
require 'nag/scheduled'
require 'active_support/time'
require 'active_record'
require 'factory_girl'

FactoryGirl.find_definitions

class ScheduledTask

  include Nag::Scheduled
  
  attr_reader :logger

  def initialize( name, options = {} )
    if options[:logger]
      @logger = options[:logger]
    else
      @logger = Logging.logger['scheduled_task_test']
    end
    self.name = name
  end

end

ActiveRecord::Base.logger = Logging.logger['credit_control_test']

def load_schema
  config = YAML::load( IO.read( File.dirname(__FILE__) + '/database.yml' ) )
  ActiveRecord::Base.establish_connection config['sqlite3']
  load( File.dirname(__FILE__) + "/schema.rb" )
end

class Client < ActiveRecord::Base
end

