require 'logging'

module Nag
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

      def nag_schedule( name, options = {} )
        logger.info "Defining schedule: #{name}. Options: #{options}. Class: #{self.name}"
        raise 'Cannot have two schedules with the same name' if schedules[name]
        schedules[name] = options
      end
      
      def schedules
        @@per_class_schedules ||= {}
        @@per_class_schedules[self.class.name] ||= {}
      end

      def attr_name( name )
        raise 'Non existent schedule name' if schedules[name].blank?
        schedules[name][:scheduled_for] || "scheduled_for_#{name}"
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

        logger.warn "Must implement dry run handling"

        return false unless ready_to_run?( name )
        
        logger.debug "About to call take_action_#{name}"
        interval = internal_take_action( name )

        logger.debug "Action taken. Calculated run interval: #{interval ? interval : 'none - task will *not* be rescheduled'}"
        reschedule( name, interval ? interval.from_now : nil )
        
        true

      end

    private

      def internal_take_action( name )
        self.send( self.class.schedules[name][:action] || "take_action_#{name}".to_sym )
      end

      def attr_name( name )
        self.class.attr_name( name )
      end
      
    end
  
    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
      Nag::Persistence.set_persistence(base)
    end
  end
end