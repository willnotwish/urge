require 'urge'

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

  test_loggers = %w{ test }
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
require 'active_support/time'
require 'active_record'
require 'factory_girl'

FactoryGirl.find_definitions

ActiveRecord::Base.logger = Logging.logger['test']

def load_schema
  config = YAML::load( IO.read( File.dirname(__FILE__) + '/database.yml' ) )
  ActiveRecord::Base.establish_connection config['sqlite3']
  load( File.dirname(__FILE__) + "/schema.rb" )
end


