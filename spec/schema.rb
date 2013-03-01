ActiveRecord::Schema.define( :version => 0 ) do

  create_table 'credit_control_tasks', :force => true do |t|
    t.string 'name'
    t.timestamp 'scheduled_for'
    t.integer 'client_id'
  end
  
  create_table 'clients', :force => true do |t|
    t.string 'name'
    t.string 'code'
  end

  create_table "simple_guests", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.datetime "started_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "aasm_state"
    t.datetime "joined_at"
    t.datetime "scheduled_for"
  end

  create_table "dual_action_guests", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.datetime "started_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "aasm_state"
    t.datetime "joined_at"
    t.datetime "status_check_at"
    t.datetime "insurance_check_at"
  end

end
