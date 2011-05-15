class Project < ActiveRecord::Base
  has_many :todos, :dependent => :delete_all

  # TODO: remove these scopes. Can be replaced by the named scopes on the todo relation
  has_many :not_done_todos,
    :include => [:context,:tags,:project],
    :class_name => 'Todo',
    :order => "todos.due IS NULL, todos.due ASC, todos.created_at ASC",
    :conditions => ["todos.state = ?", 'active']
  has_many :done_todos,
    :include => [:context,:tags,:project],
    :class_name => 'Todo',
    :order => "todos.due IS NULL, todos.due ASC, todos.created_at ASC",
    :conditions => ["todos.state = ?", 'completed']
  has_many :deferred_todos,
    :include => [:context,:tags,:project],
    :class_name => 'Todo',
    :conditions => ["todos.state = ? ", "deferred"],
    :order => "show_from"
  has_many :pending_todos,
    :include => [:context,:tags,:project],
    :class_name => 'Todo',
    :conditions => ["todos.state = ? ", "pending"],
    :order => "show_from"

  has_many :notes, :dependent => :delete_all, :order => "created_at DESC"
  has_many :recurring_todos

  belongs_to :default_context, :class_name => "Context", :foreign_key => "default_context_id"
  belongs_to :user

  named_scope :active, :conditions => { :state => 'active' }
  named_scope :hidden, :conditions => { :state => 'hidden' }
  named_scope :completed, :conditions => { :state => 'completed'}
  named_scope :uncompleted, :conditions => ["NOT(state = ?)", 'completed']
  
  validates_presence_of :name
  validates_length_of :name, :maximum => 255
  validates_uniqueness_of :name, :scope => "user_id"
  validates_does_not_contain :name, :string => ','

  acts_as_list :scope => 'user_id = #{user_id} AND state = \'#{state}\''
  acts_as_state_machine :initial => :active, :column => 'state'
  extend NamePartFinder
  #include Tracks::TodoList
  
  state :active
  state :hidden, :enter => :hide_todos, :exit => :unhide_todos
  state :completed, :enter => Proc.new { |p| p.completed_at = Time.zone.now }, :exit => Proc.new { |p| p.completed_at = nil }

  event :activate do
    transitions :to => :active,   :from => [:hidden, :completed]
  end
  
  event :hide do
    transitions :to => :hidden,   :from => [:active, :completed]
  end
  
  event :complete do
    transitions :to => :completed, :from => [:active, :hidden]
  end
  
  attr_protected :user
  attr_accessor :cached_note_count

  def self.null_object
    NullProject.new
  end
  
  def self.feed_options(user)
    {
      :title => I18n.t('models.project.feed_title'),
      :description => I18n.t('models.project.feed_description', :username => user.display_name)
    }
  end
      
  def hide_todos
    todos.each do |t|
      unless t.completed? || t.deferred?
        t.hide!
        t.save
      end
    end
  end
      
  def unhide_todos
    todos.each do |t|
      if t.project_hidden?
        t.unhide!
        t.save
      end
    end
  end
  
  def note_count
    cached_note_count || notes.count
  end
  
  alias_method :original_default_context, :default_context

  def default_context
    original_default_context.nil? ? Context.null_object : original_default_context
  end
  
  # would prefer to call this method state=(), but that causes an endless loop
  # as a result of acts_as_state_machine calling state=() to update the attribute
  def transition_to(candidate_state)
    case candidate_state.to_sym
      when current_state
        return
      when :hidden
        hide!
      when :active
        activate!
      when :completed
        complete!
    end
  end
  
  def name=(value)
    self[:name] = value.gsub(/\s{2,}/, " ").strip
  end
  
  def new_record_before_save?
    @new_record_before_save
  end  
  
end

class NullProject
  
  def hidden?
    false
  end
  
  def nil?
    true
  end
  
  def id
    nil
  end
    
end
