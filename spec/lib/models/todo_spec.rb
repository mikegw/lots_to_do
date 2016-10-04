require 'lib/models/todo'
require 'lib/models/user'
require 'lib/errors'

describe Todo do
  let(:todo_attrs) do
    {
      'title' => 'test todo',
      'body' => 'a test todo',
      'user_id' => @user['id']
    }
  end
  before (:all) do
    @user = User.create('name' => 'charles')
  end
  context 'when creating todo' do
    let(:todo)  { Todo.create(todo_attrs) }
    it 'generates an id' do
      expect(todo['id']).not_to be_nil
    end

    it 'requires a title' do
      no_title = -> { Todo.create(todo_attrs.merge('title' => nil)) }
      expect(no_title).to raise_error(BadRequest)
    end
    it 'limits the title to 31 chars or less' do
      valid_title = -> { Todo.create(todo_attrs.merge('title' => 'x'*31)) }
      expect(valid_title).not_to raise_error

      invalid_title = -> { Todo.create(todo_attrs.merge('title' => 'x'*32)) }
      expect(invalid_title).to raise_error(BadRequest)
    end
    it 'returns the title' do
      expect(todo['title']).to eq('test todo')
    end

    it 'requires a body' do
      no_body = -> { Todo.create(todo_attrs.merge('body' => nil)) }
      expect(no_body).to raise_error(BadRequest)
    end
    it 'limits the body to 255 chars or less' do
      valid_body = -> { Todo.create(todo_attrs.merge('body' => 'x'*255)) }
      expect(valid_body).not_to raise_error

      invalid_body = -> { Todo.create(todo_attrs.merge('body' => 'x'*256)) }
      expect(invalid_body).to raise_error(BadRequest)
    end
    it 'returns the body' do
      expect(todo['body']).to eq('a test todo')
    end

    it 'returns a done boolean' do
      expect(todo['done']).to eq(false)
    end
    it 'optionally allows setting a done boolean' do
      done_todo = Todo.create(todo_attrs.merge('done' => true))
      expect(done_todo['done']).to be true
    end

    it 'requires a user_id' do
      no_user_id = -> { Todo.create(todo_attrs.merge('user_id' => nil)) }
      expect(no_user_id).to raise_error(BadRequest)
    end
    it 'returns the user_id' do
      expect(todo['user_id']).to eq(@user['id'])
    end

  end
  context 'when listing todos' do
    before (:all) do
      @user = User.create('name' => 'fred')
    end
    context 'if todos exists' do
      it 'returns the todos' do
        todo = Todo.create(todo_attrs)
        result = Todo.list(@user['id'])
        expect(result).to eq([todo])
      end
    end
    context 'with no todos' do
      it 'returns an empty array' do
        user = User.create('name' => 'another test user')
        expect(Todo.list(user['id'])).to eq([])
      end
    end
    context 'with an invalid user_id' do
      invalid_ids = [nil, 'a string', 0, 12345]
      invalid_ids.each do |id|
        it "raises NotFound (id = #{id.inspect})" do
          expect { Todo.list(id) }.to raise_error(NotFound)
        end
      end
    end
  end
  context 'when deleting todos' do
    before (:all) do
      @user = User.create('name' => 'charles')
    end
    context 'if the todo exists' do
      let(:todo) { Todo.create(todo_attrs) }
      before(:each) do
        @result = Todo.delete(todo['id'].to_i, @user['id'].to_i)
      end
      it 'deletes the todo' do
        expect(Todo.list(@user['id'].to_i)).to eq([])
      end
      it 'returns the todo' do
        expect(@result).to eq(todo)
      end
    end
    context 'with an invalid id' do
      invalid_ids = [nil, 'a string', 0, 12345]
      invalid_ids.each do |id|
        it "raises NotFound (id = #{id.inspect})" do

          expect { Todo.delete(id, @user['id'].to_i) }.to raise_error(NotFound)
        end
      end
    end
  end
  context 'when updating todos' do
    before (:all) do
      @user = User.create('name' => 'jim')
    end
    let(:new_attrs) do
      {
        "id" => @todo['id'],
        'user_id' => @user['id'],
        'title' => 'x',
        'body' => 'y',
        'done' => true
      }
    end
    before(:each) do
      @todo = Todo.create(todo_attrs)
    end
    context 'with valid new attributes' do
      before(:each) do
        @result = Todo.update(new_attrs)
      end
      it 'updates the todo' do
        expect(Todo.list(@user['id']).last).to eq(new_attrs)
      end
      it 'returns the todo' do
        expect(@result).to eq(new_attrs)
      end
    end
    context 'with invalid id' do
      it 'raises NotFound' do
        bad_id = -> { Todo.update(new_attrs.merge('id' => 0)) }
        expect(bad_id).to raise_error(NotFound)
      end
    end
    context 'with invalid user_id for id' do
      it 'raises NotFound' do
        bad_user = -> { Todo.update(new_attrs.merge('user_id' => 0)) }
        expect(bad_user).to raise_error(NotFound)
      end
    end
    context 'with an empty body' do
      it 'raises BadRequest' do
        empty_body = -> { Todo.update(new_attrs.select {|a| a =~ /id/}) }
        expect(empty_body).to raise_error(BadRequest)
      end
    end
  end
end
