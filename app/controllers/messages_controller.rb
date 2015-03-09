require 'twilio-ruby'

class MessagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive

    # Retrieve relevant parameters from the message body
    phone = params[:From]
    body = params[:Body]

    # Check to see if the user is registered. If not, register them and prompt with the age question
    user = User.find_by_phone(phone)
    
    # Create a user if they do not currently exist
    if user.nil?
      user = User.create(:phone => phone)
    end

    # Retrieve the last message sent to the user using logs
    last_log = user.logs.last

    # Check to see if there has been a message
    if last_log

      # Rotate through missing information
      if last_log.message_id == 1
        user.age = Integer(body)
        user.save
        Log.create(:message_id => 2, :user_id => user.id)
      end

    # User has just registered so there is no last log
    else
      Log.create(:message_id => 1, :user_id => user.id)
    end

    # Rotate through missing information
    if user.age.nil?
      send_message phone, "What is your age?"
    else
      send_message phone, "Your age is #{user.age}"
    end

    render nothing: true
  end

  private

  def send_message(number, body)
    client = Twilio::REST::Client.new ENV["TWILIO_SID"], ENV["TWILIO_TOKEN"]
    message = client.account.messages.create(:body => body, :to => number, :from => ENV["TWILIO_NUM"])
    return message.sid
  end

end