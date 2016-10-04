require 'lib/errors'
require 'client'

module Model

  private

  def escape(str)
    Client.escape(str)
  end

  def perform_query(sql)
    result = Client.query(sql)
  rescue Mysql2::Error
    raise BadRequest
  end

  def replace(sql:, place:, value:, validate: true)
    (raise BadRequest, 'Missing attribute: ' + place) if (validate && value.nil?)
    sql_value = convert_value(value)
    sql.gsub!(place, sql_value)
  end

  def convert_value(value)
    case value
    when String
      "'#{escape(value.to_s)}'"
    when true, false
      value ? '1' : '0'
    when Fixnum
      value.to_s
    when nil
      'NULL'
    else
      raise "Invalid replace class: #{value.class} (#{value})"
    end
  end
end
