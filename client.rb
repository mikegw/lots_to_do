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
        username: username,
        password: password,
        database: database,
        flags: Mysql2::Client::MULTI_STATEMENTS
      )
    end

    def disconnect
      if @client
        @client.close
        @client = nil
      end
    end

    def setup
      username and password and database
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

    def database
      ENV['database'] || (
        print "Please enter the name of an empty mysql database to use: "
        ENV['database'] = gets.chomp
      )
    end

    def username
      ENV['username'] || (
        print "Please enter a mysql username: "
        ENV['username'] = gets.chomp
      )
    end

    def password
      ENV['password'] || (
        print "Please enter password (HIDDEN): "
        ENV['password'] = STDIN.noecho(&:gets).chomp
        puts "\n"
        ENV['password']
      )
    end
  end
end
