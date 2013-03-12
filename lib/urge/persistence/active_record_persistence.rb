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
        def urgent( name, at = DateTime.now )
          options = urge_schedules[name]
          raise 'Unknown schedule' unless options
          where( "#{urge_attr_name(name)} < ?", at )
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
  
        def urge_all!( name, options = {} )
          urgent( name ).each { |u| u.urge!( name, options.dup ) }
        end
      
      end
      
      module InstanceMethods
        
        def urge!( name, options = {} )
          urge( name, options )
          save!
        end
        
      end

    end
  end
end