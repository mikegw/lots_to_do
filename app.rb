$LOAD_PATH << File.expand_path('..', __FILE__)

require 'bundler'
require 'rack'
require 'pry'
require 'json'

Bundler.require

require 'client'
require 'lib/models/user'
require 'lib/models/todo'
require 'lib/errors'

class App
  def self.route(action, identifier, &handler)
    routes[action][identifier] = handler
  end

  def call(env)
    action = env['REQUEST_METHOD']
    path = env['REQUEST_PATH']
    raw_body = env['rack.input'].read if env['rack.input']
    body = JSON.parse(raw_body) rescue raw_body

    self.class.routes[action].each_pair do |identifier, handler|
      path_data = identifier.match(path)
      return handler.call(path_data, body) if path_data
    end
    ['405', {}, []]
  rescue BadRequest => e
    ['400', {}, []]
  rescue NotFound
    ['404', {}, []]
  end

  private

  def self.routes
    @routes ||= Hash.new { |h, k| h[k] = {} }
  end

  route 'POST', %r{^/users$} do |path_data, body|
    user = User.create(body)
    ['201', {'Content-Type' => 'text/json'}, [user.to_json]]
  end

  route 'GET', %r{^/users/(?<id>\d+)$} do |path_data|
    id = path_data[:id].to_i
    user = User.fetch(id)
    ['200', {'Content-Type' => 'text/json'}, [user.to_json]]
  end

  route 'POST', %r{^/users/(?<user_id>\d+)/todos$} do |path_data, body|
    user_id = path_data[:user_id].to_i
    raise BadRequest unless body.is_a?(Hash)
    todo_attributes = body.merge('user_id' => user_id)
    todo = Todo.create(todo_attributes)
    ['201', {'Content-Type' => 'text/json'}, [todo.to_json]]
  end

  route 'GET', %r{^/users/(?<user_id>\d+)/todos$} do |path_data|
    user_id = path_data[:user_id].to_i
    todo = Todo.list(user_id)
    ['200', {'Content-Type' => 'text/json'}, [todo.to_json]]
  end

  route 'DELETE', %r{^/users/(?<user_id>\d+)/todos/(?<id>\d+)$} do |path_data|
    user_id = path_data[:user_id].to_i
    id = path_data[:id].to_i
    todo = Todo.delete(id, user_id)
    ['200', {'Content-Type' => 'text/json'}, [todo.to_json]]
  end

  route 'PUT', %r{^/users/(?<user_id>\d+)/todos/(?<id>\d+)$} do |path_data, body|
    user_id = path_data[:user_id].to_i
    id = path_data[:id].to_i
    attributes = body.merge(
      'id' => id,
      'user_id' => user_id
    )
    todo = Todo.update(attributes)
    ['200', {'Content-Type' => 'text/json'}, [todo.to_json]]
  end
end
