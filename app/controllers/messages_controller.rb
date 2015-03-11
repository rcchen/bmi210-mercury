require 'twilio-ruby'

class MessagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive

    # Retrieve relevant parameters from the message body
    phone = params[:From]
    request = params[:Body]

    # Check to see if the user is registered. If not, register them and prompt with the age question
    user = User.find_by_phone(phone)
    
    # Create a user if they do not currently exist
    if user.nil?
      user = User.create(:phone => phone)
    end

    # Create a variable for the response being sent
    response = nil

    # Check to see if the user has an age yet
    if !user.age
    
      # Attempt to parse the current response into an age
      if request.to_i != 0
        user.age = Integer(request)
        user.save
        response = "Your age is #{user.age.to_s}"
      else
        response = "What is your age?"
      end

      Log.create(:user_id => user.id, :request => request, :response => response)
      send_message phone, response      

    end

    # Check to see if there has been a diagnosis in process
    diagnosis = Diagnosis.where(:user_id => user.id, :in_progress => true)

    # If the diagnosis exists, just keep going with it
    if diagnosis.exists?



    # Start a new diagnosis
    else

      diagnosis = Diagnosis.create(:user_id => user.id, :in_progress => true)

    end



    Log.create(:user_id => user.id, :request => request, :response => response)
    send_message phone, response

    render nothing: true
  end

  private

  def send_message(number, body)
    client = Twilio::REST::Client.new ENV["TWILIO_SID"], ENV["TWILIO_TOKEN"]
    message = client.account.messages.create(:body => body, :to => number, :from => ENV["TWILIO_NUM"])
    return message.sid
  end

end