# +-------+------------------+------+-----+---------+----------------+
# | Field | Type             | Null | Key | Default | Extra          |
# +-------+------------------+------+-----+---------+----------------+
# | id    | int(10) unsigned | NO   | PRI | NULL    | auto_increment |
# | name  | varchar(20)      | YES  |     | NULL    |                |
# +-------+------------------+------+-----+---------+----------------+
require 'lib/errors'
require 'lib/model'

class User
  extend Model

  def self.create(attributes)
    raise BadRequest unless attributes.is_a?(Hash)

    sql = File.read('lib/sql/create_user.sql')
    replace(sql: sql, place: '{{NAME}}', value: attributes['name'])

    result = perform_query(sql)
    result.first or raise BadRequest
  end
  def self.fetch(id)
    raise NotFound unless id.is_a?(Integer)

    sql = File.read('lib/sql/fetch_user.sql')
    replace(sql: sql, place: '{{ID}}', value: id.to_s, validate: false)

    result = perform_query(sql)
    result.first or raise NotFound
  end
end
