require 'logging'

module Urge
  module Scheduled
    module ClassMethods

      def run_all( name )
        now = DateTime.now
        logger.debug "run_all. Time now: #{now}"
        ready_to_run( name, now ).each do |task|
          logger.debug "Task of class #{task.class.name} named: #{name} is about to be run"
          task.run( name )
        end
      end
        
      def inspect_all( name )
        now = DateTime.now
        tasks = ready_to_run( name, now )
        logger.info "inspect_queue. Time now: #{now}. The following #{tasks.size} tasks are ready to run"
        tasks.each { |task| logger.info task.inspect }
        tasks
      end
      
      def logger
        @@logger ||= Logging.logger[self]
      end

      def urge_schedule( name, options = {} )
        logger.info "Defining schedule: #{name}. Options: #{options}. Class: #{self.name}"

        # Warn if a schedule with this name already exists, but don't bail out.
        # It's not necessarily an error. Rails autoloading classes is an example where it's not...
        logger.warn "A schedule with this name already exists. Old options: #{schedules[name]}" if schedules[name]

        schedules[name] = options
      end
      
      def schedules
        @@per_class_schedules ||= {}
        @@per_class_schedules[self.name] ||= {}
      end

      def attr_name( name )
        raise 'Non existent schedule name' if schedules[name].blank?
        schedules[name][:scheduled_for] || "scheduled_for_#{name}"
      end
      
      def all_schedules
        @@per_class_schedules
      end

    end
  
    module InstanceMethods

      def ready_to_run?( name )
        ts = self.send( attr_name( name ) )
        ts ? (DateTime.now >= ts) : false
      end

      def reschedule( name, _when )
        logger.debug "ScheduledTask#reschedule about to reschedule for #{_when}"
        self.send( "#{attr_name(name)}=", _when )
      end

      # Takes action and reschedules itself. That is all, and that is enough!
      def run( name, options = {} )

        return false unless ready_to_run?( name )
        
        logger.debug "About to call take_action_#{name}"
        interval = internal_take_action( name, options )

        logger.debug "Action taken. Calculated run interval: #{interval ? interval : 'none - task will *not* be rescheduled'}"
        reschedule( name, interval ? interval.from_now : nil )
        
        true

      end

    private

      def internal_take_action( name, options )
        self.send( self.class.schedules[name][:action] || "take_action_#{name}".to_sym, options )
      end

      def attr_name( name )
        self.class.attr_name( name )
      end
      
    end
  
    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
      Urge::Persistence.set_persistence(base)
    end
  end
end