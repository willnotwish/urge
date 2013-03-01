module Nag
  module Persistence

    def self.set_persistence(base)

      # Use a fancier auto-loading thingy, perhaps.  When there are more persistence engines.
      hierarchy = base.ancestors.map {|klass| klass.to_s}

      dir_name = File.join( File.dirname(__FILE__), 'persistence' )
      require File.join( dir_name, 'base' )
      # require File.join(File.dirname(__FILE__), 'persistence', 'read_state')
      if hierarchy.include?( "ActiveRecord::Base" )
        require File.join( dir_name, 'active_record_persistence' )
        base.send( :include, Nag::Persistence::ActiveRecordPersistence )
      end
      
    end
  end

end