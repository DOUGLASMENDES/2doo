require File.dirname(__FILE__) + '/../test_helper'

class MessageGatewayTest < ActiveSupport::TestCase
  fixtures :users, :contexts, :todos

  def setup
    @user = users(:sms_user)
    @inbox = contexts(:inbox)
  end

  def load_message(filename)
    MessageGateway.receive(File.read(File.join(RAILS_ROOT, 'test', 'fixtures', filename)))
  end

  def test_sms_with_no_subject
    todo_count = Todo.count

    load_message('sample_sms.txt')
    # assert some stuff about it being created
    assert_equal(todo_count+1, Todo.count)

    message_todo = Todo.find(:first, :conditions => {:description => "message_content"})
    assert_not_nil(message_todo)

    assert_equal(@inbox, message_todo.context)
    assert_equal(@user, message_todo.user)
  end

  def test_double_sms
    todo_count = Todo.count
    load_message('sample_sms.txt')
    load_message('sample_sms.txt')
    assert_equal(todo_count+1, Todo.count)
  end

  def test_mms_with_subject
    todo_count = Todo.count

    load_message('sample_mms.txt')

    # assert some stuff about it being created
    assert_equal(todo_count+1, Todo.count)

    message_todo = Todo.find(:first, :conditions => {:description => "This is the subject"})
    assert_not_nil(message_todo)

    assert_equal(@inbox, message_todo.context)
    assert_equal(@user, message_todo.user)
    assert_equal("This is the message body", message_todo.notes)
  end

  def test_no_user
    todo_count = Todo.count
    badmessage = File.read(File.join(RAILS_ROOT, 'test', 'fixtures', 'sample_sms.txt'))
    badmessage.gsub!("5555555555", "notauser")
    MessageGateway.receive(badmessage)
    assert_equal(todo_count, Todo.count)
  end

  def test_direct_to_context
    message = File.read(File.join(RAILS_ROOT, 'test', 'fixtures', 'sample_sms.txt'))

    valid_context_msg = message.gsub('message_content', 'this is a task @ anothercontext')
    invalid_context_msg = message.gsub('message_content', 'this is also a task @ notacontext')

    MessageGateway.receive(valid_context_msg)
    valid_context_todo = Todo.find(:first, :conditions => {:description => "this is a task"})
    assert_not_nil(valid_context_todo)
    assert_equal(contexts(:anothercontext), valid_context_todo.context)

    MessageGateway.receive(invalid_context_msg)
    invalid_context_todo = Todo.find(:first, :conditions => {:description => 'this is also a task'})
    assert_not_nil(invalid_context_todo)
    assert_equal(@inbox, invalid_context_todo.context)
  end
end
