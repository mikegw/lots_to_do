require 'mysql2'
require 'pry'

module Client
  class << self
    def query(sql)
      results = [client.query(sql)]
      while client.next_result
        results << client.store_result
      end
      convert_results(results)
    end

    def escape(sql)
      client.escape(sql)
    end

    def establish_connection
      @client = Mysql2::Client.new(
        host: 'localhost',
        username: 'mike',
        password: 'thelobster',
        database: 'lots_to_do',
        flags: Mysql2::Client::MULTI_STATEMENTS
      )
    end

    def disconnect
      if @client
        @client.close
        @client = nil
      end
    end

    private

    def client
      raise 'dam' unless @client
      @client
    end

    def convert_results(results)
      results.reject!(&:nil?)
      case results.length
      when 0
        nil
      when 1
        results.first.entries
      else
        results.map(&:entries)
      end
    end
  end
end
