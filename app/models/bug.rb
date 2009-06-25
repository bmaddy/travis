class Bug < ActiveRecord::Base
  acts_as_state_machine :initial=>:new
  acts_as_taggable
  acts_as_solr

  has_many :audit_records, :as=>:auditable
  belongs_to :iteration

  attr_protected :state, :login

  validates_length_of :title, :within=>4..200
  validates_length_of :reported_by, :maximum=>200, :allow_nil=>true
  validates_numericality_of :swag, :greater_than_or_equal_to=>0, :allow_nil=>true, :less_than=>10000
  validates_numericality_of :severity, :greater_than_or_equal_to=>1, :allow_nil=>true, :less_than_or_equal_to=>4
  validates_numericality_of :priority, :greater_than_or_equal_to=>1, :allow_nil=>true, :less_than_or_equal_to=>4

  before_create { |record| record.audit_records.build(:diff=>{:self=>[:nonexistent, :existent]}.to_yaml, 
                                                              :login=>(User.current_user ? User.current_user.login : 'some guy')) }
  after_create :set_mnemonic

  before_update { |record| AuditRecord.build_it(record) }

  named_scope :unswagged, :conditions => ['swag IS NULL']

  state :new
  state :held
  state :waiting_for_fix, :enter=>Proc.new{|b| b.login = nil; b.save!}
  state :in_progress, :enter=>Proc.new{|b| b.login = (User.current_user ? User.current_user.login : 'some guy'); b.save!}
  state :in_qc
  state :passed, :enter=>Proc.new{|b| b.login = nil; b.save!}

  event :hold do
    transitions :to=>:held, :from=>:new
    transitions :to=>:held, :from=>:waiting_for_fix
  end
  event :approve do
    transitions :to=>:waiting_for_fix, :from=>:new
    transitions :to=>:waiting_for_fix, :from=>:held
  end
  event :start do
    transitions :to=>:in_progress, :from=>:waiting_for_fix
  end
  event :stop do
    transitions :to=>:waiting_for_fix, :from=>:in_progress
  end
  event :finish do
    transitions :to=>:in_qc, :from=>:in_progress
  end
  event :fail do
    transitions :to=>:in_progress, :from=>:in_qc
  end
  event :pass do
    transitions :to=>:passed, :from=>:in_qc
  end
  
  def Bug.severities
    {'Show Stopper'=>1, 'Annoying'=>2, 'Work-Around Exists'=>3, 'Aesthetic'=>4}
  end

  def severity_text
    Bug.severities.index(self.severity) # || 'Unknown'
  end

  def Bug.priorities
    {'Critical'=>1, 'High'=>2, 'Medium'=>3, 'Low'=>4}
  end

  def priority_text
    Bug.priorities.index(self.priority) # || 'Unknown'
  end
  
  private 
  def set_mnemonic
    self.update_attribute(:mnemonic, ("BUG-%d"%[self.id]))
  end
  
  def self.per_page
    20
  end
end