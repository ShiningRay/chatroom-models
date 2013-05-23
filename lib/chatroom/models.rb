require "ohm"
require 'ohm/identity_map'
require 'multi_json'
module Chatroom
  class Room < Ohm::Model
  end
  class User < Ohm::Model
    attr_accessor :connection, :subscription

    attribute :name
    attribute :login
    unique :login
    reference :room, Room

    def validate
      assert_present :login
      assert_present :name
      #assert_unique :login
    end
    
    def send_message(args)
      connection.send_data args if connection
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

      broadcast(event: :join, source: user.login, room: name)
      user.send_message(event: :joined, room: name)
      user.subscription = channel.subscribe user, :send_message
      save
    end

    def leave(user)
      channel.unsubscribe user.subscription
      users.delete(user)
      broadcast(event: :leave, source: user.login)
      user.send_message(event: :info, data: [:quited, name])
      user.room = nil
      user.save
      save
    end

    def broadcast(msg)
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
