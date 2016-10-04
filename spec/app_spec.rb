require 'app'

describe App do
  describe '.route' do
    it 'adds a route' do
      route_handler = proc {}
      App.route('GET', '/crzy', &route_handler)
      expect(App.send(:routes)['GET']['/crzy']).to eq(route_handler)
    end
  end

  describe 'post request to users' do
    let(:env) do
      {
        "REQUEST_METHOD"=>"POST",
        "REQUEST_PATH"=>"/users"
      }
    end
    let(:user_class) { class_double('User').as_stubbed_const }
    context 'with valid user attributes' do
      before(:each) do
        env["rack.input"] = StringIO.new('{"name":"mike"}')
      end
      it 'creates a user' do
        allow(user_class).to receive(:create)
        subject.call(env)
        expect(user_class).to have_received(:create).with({"name" => "mike"})
      end
      it 'returns the user' do
        allow(user_class).to receive(:create).and_return({id: 1, name: 'mike'})
        response = subject.call(env)
        expect(response).to eq(
          ['201', {'Content-Type' => 'text/json'}, ['{"id":1,"name":"mike"}']]
        )
      end
    end
    context 'with invalid user attributes' do
      before(:each) do
        env["rack.input"] = StringIO.new('{"bad":"input"}')
      end
      it 'returns a 400' do
        allow(user_class).to receive(:create).and_raise(BadRequest)
        response = subject.call(env)
        expect(response).to eq(
          ['400', {}, []]
        )
      end
    end
  end

  describe 'get request to users/:id' do
    let(:env) do
      {
        "REQUEST_METHOD"=>"GET",
        "REQUEST_PATH"=>"/users/4",
      }
    end
    let(:user_class) { class_double('User').as_stubbed_const }
    context 'with a valid user id' do
      it 'returns the user' do
        allow(user_class).to receive(:fetch).with(4).and_return({})
        response = subject.call(env)
        expect(response).to eq(
          ['200', {'Content-Type' => 'text/json'}, ['{}']]
        )
      end
    end
    context 'with an invalid user id' do
      it 'returns a 404' do
        allow(user_class).to receive(:fetch).and_raise(NotFound)
        response = subject.call(env)
        expect(response).to eq(
          ['404', {}, []]
        )
      end
    end
  end

  describe 'post request to users/:user_id/todos' do
    let(:env) do
      {
        "REQUEST_METHOD"=>"POST",
        "REQUEST_PATH"=>"/users/7/todos"
      }
    end
    let(:todo_class) { class_double('Todo').as_stubbed_const }

    context 'with an invalid user_id' do
      it 'returns a 404' do
        env['rack.input'] = StringIO.new('{"title":"bob","body":"more bob"}')
        allow(todo_class).to receive(:create).and_raise(NotFound)
        response = subject.call(env)
        expect(response).to eq(
          ['404', {}, []]
        )
      end
    end
    context 'with a valid user_id' do
      context 'and valid todo attributes' do
        before(:each) do
          env['rack.input'] = StringIO.new('{"title":"bob","body":"more bob"}')
        end
        it 'creates a todo' do
          allow(todo_class).to receive(:create)
          subject.call(env)
          expect(todo_class).to have_received(:create).with(
            "title" => "bob",
            "body" => "more bob",
            'user_id' => 7
          )
        end
        it 'returns the todo' do
          allow(todo_class).to receive(:create).and_return(
            "id" => 1,
            "title" => 'bob',
            "body" => 'more bob',
            'done' => false,
            "user_id" => 7
          )
          response = subject.call(env)
          expected_json = '{"id":1,"title":"bob","body":"more bob","done":false,"user_id":7}'
          expect(response).to eq(
            ['201', {'Content-Type' => 'text/json'}, [expected_json]]
          )
        end
      end
      context 'and invalid todo attributes' do
        it 'returns a 400' do
          allow(todo_class).to receive(:create).and_raise(BadRequest)
          response = subject.call(env)
          expect(response).to eq(
            ['400', {}, []]
          )
        end
      end
    end
  end

  describe 'get request to users/:user_id/todos' do
    let(:env) do
      {
        "REQUEST_METHOD"=>"GET",
        "REQUEST_PATH"=>"/users/8/todos",
      }
    end
    let(:todo_class) { class_double('Todo').as_stubbed_const }
    context 'with a valid user_id ' do
      it 'returns the user' do
        allow(todo_class).to receive(:list).with(8).and_return([])
        response = subject.call(env)
        expect(response).to eq(
          ['200', {'Content-Type' => 'text/json'}, ['[]']]
        )
      end
    end
    context 'with an invalid user_id' do
      it 'returns a 404' do
        allow(todo_class).to receive(:list).and_raise(NotFound)
        response = subject.call(env)
        expect(response).to eq(
          ['404', {}, []]
        )
      end
    end
  end

  describe 'delete request to users/:user_id/todos/:id' do
    let(:env) do
      {
        "REQUEST_METHOD"=>"DELETE",
        "REQUEST_PATH"=>"/users/8/todos/1",
      }
    end
    let(:todo_class) { class_double('Todo').as_stubbed_const }
    context 'with a valid user_id and id' do
      it 'returns the todo' do
        allow(todo_class).to receive(:delete).with(1, 8).and_return({})
        response = subject.call(env)
        expect(response).to eq(
          ['200', {'Content-Type' => 'text/json'}, ['{}']]
        )
      end
    end
    context 'with an invalid user_id or id' do
      it 'returns a 404' do
        allow(todo_class).to receive(:delete).and_raise(NotFound)
        response = subject.call(env)
        expect(response).to eq(
          ['404', {}, []]
        )
      end
    end
  end
  describe 'put request to users/:user_id/todos/:id' do
    let(:env) do
      {
        "REQUEST_METHOD"=>"PUT",
        "REQUEST_PATH"=>"/users/8/todos/1"
      }
    end
    let(:todo_class) { class_double('Todo').as_stubbed_const }
    before(:each) do
      env['rack.input'] = StringIO.new('{"title":"a","body":"b","done":true}')
    end
    context 'with a valid user_id and id' do
      it 'updates the todo' do
        allow(todo_class).to receive(:update).and_return({})
        response = subject.call(env)
        expect(todo_class).to have_received(:update).with(
          "id" => 1,
          "user_id" => 8,
          'title' => 'a',
          'body' => 'b',
          'done' => true
        )
      end
      it 'returns the updated todo' do
        allow(todo_class).to receive(:update).and_return({})
        response = subject.call(env)
        expect(response).to eq(
          ['200', {'Content-Type' => 'text/json'}, ['{}']]
        )
      end
    end
    context 'with an invalid user_id or id' do
      it 'returns a 404' do
        allow(todo_class).to receive(:update).and_raise(NotFound)
        response = subject.call(env)
        expect(response).to eq(
          ['404', {}, []]
        )
      end
    end
  end
end
