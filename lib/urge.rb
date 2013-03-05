require 'urge/version'
require 'urge/persistence'

require 'logging'

module Urge

  module ClassMethods

    # def run_all( name )
    #   now = DateTime.now
    #   logger.debug "run_all. Time now: #{now}"
    #   ready_to_run( name, now ).each do |task|
    #     logger.debug "Task of class #{task.class.name} named: #{name} is about to be run"
    #     task.run( name )
    #   end
    # end
    # 
    # def inspect_all( name )
    #   now = DateTime.now
    #   tasks = ready_to_run( name, now )
    #   logger.info "inspect_queue. Time now: #{now}. The following #{tasks.size} tasks are ready to run"
    #   tasks.each { |task| logger.info task.inspect }
    #   tasks
    # end

    def urge_logger
      @@urge_logger ||= Logging.logger[self]
    end

    def urge_schedule( name, options = {} )

      urge_logger.info "Defining schedule: #{name}. Options: #{options}. Class: #{self.name}"

      # Warn if a schedule with this name already exists, but don't bail out.
      # It's not necessarily an error. Rails autoloading classes is an example where it's not...
      urge_logger.warn "A schedule with this name already exists. Old options: #{urge_schedules[name]}" if urge_schedules[name]

      # NEW. Set defaults. The name pf the action metod is the same as the name of the schedule, and the name of the timestamp
      # attribute is likewise, but with _at appended.

      # For example, if the schedule name is 'check_credit', the signature of the action method - unless overridden - is 
      # expected to be 

      # def check_credit( options )
      # end

      # The timestamp name - unless set explicitly - is check_credit_at
      options[:timestamp_name] ||= "#{name}_at"
      options[:action] ||= name

      urge_schedules[name] = options
    end

    def urge_schedules
      @@urge_per_class_schedules ||= {}
      @@urge_per_class_schedules[self.name] ||= {}
    end

    def urge_all_schedules
      @@urge_per_class_schedules
    end

    # private

    def urge_attr_name( name )
      raise 'Non existent schedule name' unless urge_schedules[name]
      urge_schedules[name][:timestamp_name]
    end

  end

  # 
  # 
  # 
  module InstanceMethods

    def urgent?( name )
      ts = self.send( urge_attr_name( name ) )
      ts ? (DateTime.now >= ts) : false
    end

    def urge_reschedule( name, _when )
      urge_logger.debug "ScheduledTask#reschedule about to reschedule for #{_when}"
      self.send( "#{urge_attr_name(name)}=", _when )
    end

    # Takes action and reschedules itself. That is all, and that is enough!
    def urge( name, options = {} )

      return false unless urgent?( name )

      # NEW. The value returned from the urge is an instant in time (an absolute timestamp)
      ts = self.send( self.class.urge_schedules[name][:action].to_sym, options )
      urge_reschedule( name, ts )
      true

    end

  private

    def urge_attr_name( name )
      self.class.urge_attr_name( name )
    end
    
    def urge_logger
      self.class.urge_logger
    end
  
  end

  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
    Urge::Persistence.set_persistence(base)
  end

end