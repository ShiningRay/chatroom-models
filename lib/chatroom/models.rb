require "ohm"
require 'ohm/identity_map'
require 'multi_json'
module Chatroom
  class Room < Ohm::Model
  end
  class User < Ohm::Model
    attr_accessor :connection#, :subscription#, :room

    attribute :name
    attribute :login
    unique :login
    reference :room, Room

    def validate
      assert_present :login
      assert_present :name
      #assert_unique :login
    end
    
    def send_message(*args)
      connection.send_data args
    end

    def subscription
      connection.subscription
    end

    def subscription=(s)
      connection.subscription = s
    end
  end

  class Chat < Ohm::Model
    attribute :text, :created_at
    reference :user, :User
  end

  class Room < Ohm::Model
    attr_accessor :channel

    attribute :name
    unique :name

    set :users, User
    list :chats, Chat

    def join(user)
      users << user
      user.room = self
      user.save

      broadcast(:join, user.login, user.name)
      user.subscription = channel.subscribe user, :send_message
      save
    end

    def leave(user)
      channel.unsubscribe user.subscription
      boardcast(:leave, user.login, user.name)
      users.delete(user)
      user.room = nil
      user.save
      save
    end

    def broadcast(*msg)
      channel << msg
    end

    def validate
      assert_present :name
      #assert_unique :name
    end
  end

  class Hall < Ohm::Model
    set :rooms, :Room
  end
end
