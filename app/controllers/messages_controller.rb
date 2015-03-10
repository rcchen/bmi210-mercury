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
      send_message phone, "What is your age?"

    else
      # Retrieve the last message sent to the user using logs
      last_log = user.logs.last

      # Check to see if there has been a message
      if last_log
          body = body.downcase
          if body == "yes" or body == "y" or body == "no" or body == "n" 
            last_log.answer = body


            # Finds the next message to be sent according to the condtion
            message = Message.find(last_log.message_id)
            messages = Message.where(condition: message.condition)
            if messages.index(message) < messages.count - 1
              next_message = messages[messages.index(message) + 1]
              send_message phone, next_message.message
              Log.create(:message_id => next_message.id, :user_id => user.id)
            else
              send_message phone, recommendation(user)
          else
            send_message phone, "Please enter either yes or no."
          end 
        end

      # User has just registered so there is no last log
      else
        # Rotate through missing information
        if user.age.nil?
          if body.is_a?(Integer)
            user.age = Integer(body)
            user.save
            send_message phone, "Which condition would you like to test?"
          else
            send_message phone, "Please enter a valid age."
        else
          if body == "MI" or "Pneumonia" or "Diarrhea"
            messages = Message.where(condition: body)
            send_message phone, messages.first.message
            Log.create(:message_id => messages.first.id, :user_id => user.id)
          else
            send_message phone, "Please enter either MI, Pneumonia, or Diarrhea."
          end
        end
      end
    end


    

    

    render nothing: true
  end

  private

  def send_message(number, body)
    client = Twilio::REST::Client.new ENV["TWILIO_SID"], ENV["TWILIO_TOKEN"]
    message = client.account.messages.create(:body => body, :to => number, :from => ENV["TWILIO_NUM"])
    return message.sid
  end

  def recommendation(user)
    logs = Log.where(user_id: user.id)
    for log in logs
      if log.answer == "yes" total_weight += log.message.weight

      end
    end
    if total_weight >= logs.first.message.factor.condition.threshold
      "Your total weight is " + total_weight + " and the threshold is " + logs.first.message.factor.condition.threshold + ". We recommend that you visit a hospital."
    else
      "Your total weight is " + total_weight + " and the threshold is " + logs.first.message.factor.condition.threshold + ". We do not recommend that you visit a hospital."
    end
  end

end