require 'lib/models/user'
require 'lib/errors'

describe User do
  context 'when creating users' do
    let(:user_attributes)  { User.create('name' => 'test user') }
    it 'generates an id' do
      expect(user_attributes['id']).not_to be_nil
    end
    it 'returns the name' do
      expect(user_attributes['name']).to eq('test user')
    end
    it 'limits the name to 20 chars or less' do
      expect { User.create('name' => 'x'*20) }.not_to raise_error
      expect { User.create('name' => 'x'*21) }.to raise_error(BadRequest)
    end
    it 'requires a name' do
      expect { User.create({}) }.to raise_error(BadRequest)
    end
  end
  context 'when fetching users' do
    context 'if the user exists' do
      let(:user) { User.create('name' => 'tim') }
      it 'returns the user' do
        result = User.fetch(user['id'])
        expect(result).to eq(user)
      end
    end
    context 'with an invalid id' do
      invalid_ids = [nil, 'a string', 0, 12345]
      invalid_ids.each do |id|
        it "raises NotFound (id = #{id.inspect})" do

          expect { User.fetch(id) }.to raise_error(NotFound)
        end
      end
    end
  end
end
