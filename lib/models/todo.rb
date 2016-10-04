# +---------+------------------+------+-----+---------+----------------+
# | Field   | Type             | Null | Key | Default | Extra          |
# +---------+------------------+------+-----+---------+----------------+
# | id      | int(10) unsigned | NO   | PRI | NULL    | auto_increment |
# | title   | varchar(31)      | YES  |     | NULL    |                |
# | body    | varchar(255)     | YES  |     | NULL    |                |
# | done    | tinyint(1)       | NO   |     | 0       |                |
# | user_id | int(10) unsigned | NO   | MUL | NULL    |                |
# +---------+------------------+------+-----+---------+----------------+
require 'lib/errors'
require 'lib/model'

class Todo
  extend Model

  def self.create(attributes)
    raise BadRequest unless attributes.is_a?(Hash)
    sql = File.read('lib/sql/create_todo.sql')

    replace(sql: sql, place: '{{TITLE}}', value: attributes['title'])
    replace(sql: sql, place: '{{BODY}}', value: attributes['body'])
    replace(sql: sql, place: '{{USER_ID}}', value: attributes['user_id'])
    replace(sql: sql, place: '{{DONE}}', value: attributes['done'] == true)

    todo = perform_query(sql).first
    raise BadRequest unless todo

    modify_done_attribute(todo)
    todo
  end

  def self.list(user_id)
    raise NotFound unless user_id.is_a?(Integer)

    sql = File.read('lib/sql/list_todos.sql')
    replace(sql: sql, place: '{{USER_ID}}', value: user_id)

    users, todos = perform_query(sql)
    raise NotFound unless users.first['exists'] == 1

    todos.each { |todo| modify_done_attribute(todo) }
    todos
  end

  def self.delete(id, user_id)
    raise NotFound unless id.is_a?(Integer)

    sql = File.read('lib/sql/delete_todo.sql')
    replace(sql: sql, place: '{{USER_ID}}', value: user_id)
    replace(sql: sql, place: '{{ID}}', value: id)

    todo = perform_query(sql).first
    raise NotFound unless todo

    todo['done'] = todo['done'] == 1
    todo
  end

  def self.update(attributes)
    raise BadRequest unless attributes.is_a?(Hash)

    sql = File.read('lib/sql/update_todo.sql')

    replace(sql: sql, place: '{{ID}}', value: attributes['id'])
    replace(sql: sql, place: '{{USER_ID}}', value: attributes['user_id'])

    replace(sql: sql, place: '{{TITLE}}', value: attributes['title'])
    replace(sql: sql, place: '{{BODY}}', value: attributes['body'])

    done = [true, false].delete(attributes['done'])
    replace(sql: sql, place: '{{DONE}}', value: done)

    todo = perform_query(sql).first
    raise NotFound unless todo

    modify_done_attribute(todo)
    todo
  end

  class << self
    private

    def modify_done_attribute(todo)
      todo['done'] = todo['done'] == 1
    end
  end
end
