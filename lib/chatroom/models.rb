require "ohm"
require 'multi_json'
module Chatroom
  class User < Ohm::Model
    attr_accessor :connection

    attribute :name, :login
    index :login
    reference :room, :Room
    def validate
      assert_present :login
      assert_present :name
      assert_unique :login
    end
    def send_message(*args)
      connection.send MultiJson.dump(args)
    end
  end

  class Chat < Ohm::Model
    attribute :text, :created_at
    reference :user, :User
  end

  class Room < Ohm::Model
    attr_accessor :channel

    attribute :name
    index :name

    set :users, :User
    list :chats, :Chat

    def initialze(name)
      self.channel = EventMachine::Channel.new
    end

    def join(user)
      users << user
      broadcast(:join, user.login, user.name)
      channel.subscribe user.method(:send_message)
    end

    def leave(user)
      channel.unsubscribe user.method(:send_message)
      boardcast(:leave, user.login, user.name)
      users.delete(user)
    end

    def broadcast(msg)
      channel <<  msg
    end

    def validate
      assert_present :name
      assert_unique :name
    end
  end

  class Hall < Ohm::Model
    set :rooms, :Room
  end
end
