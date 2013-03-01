module Urge
  module Persistence
    module ActiveRecordPersistence

      def self.included( base )
        base.extend Urge::Persistence::Base::ClassMethods
        base.extend Urge::Persistence::ActiveRecordPersistence::ClassMethods
        base.send( :include, Urge::Persistence::ActiveRecordPersistence::InstanceMethods )
      end

      module ClassMethods

        # AR finder
        def ready_to_run( name, at = DateTime.now )
          options = schedules[name]
          raise 'Unknown schedule' unless options
          where( "#{attr_name(name)} < ?", at )
        end


        # def self.retailer( criteria )
        #   matches = joins( :retailer )
        #   # Can specify name and account code explicitly
        #   [:name, :account_code].each do |attribute|
        #     matches = matches.where( Retailer.arel_table[attribute].matches("%#{criteria[attribute]}%" ) ) unless criteria[attribute].blank?
        #   end
        #   # Can specify general criteria
        #   if !criteria[:retailer].blank?
        #     restriction = nil
        #     [:name, :account_code].each do |attribute|
        #       predicate = Retailer.arel_table[attribute].matches( "%#{criteria[:retailer]}%" )
        #       restriction = restriction ? restriction.or( predicate ) : predicate
        #     end
        #     matches = matches.where( restriction )
        #   end
        #   matches
        # end
  
        # Same as Scheduled::run_all but saves the rescheduled task
        def run_all!( name )
          now = DateTime.now
          logger.debug "run_all! Time now: #{now}"
          ready_to_run( now ).each do |task|
            logger.debug "Task of class #{task.class.name} is about to be run! (with a bang)"
            task.run!( name )
          end
        end
      
      end
      
      module InstanceMethods
        
        def run!( name, options = {} )
          run( name, options )
          save!
        end
        
      end

    end
  end
end