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
    response = "No response created"

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
    diagnosis = Diagnosis.where(:user_id => user.id, :in_progress => true).first

    # If the diagnosis exists, just keep going with it
    if diagnosis

      # Search across diseases to find the correct one
      if diagnosis.disease_id == nil
        lastLog = user.logs.last
        if lastLog.response.include?("Select a number:")
          diseases = Disease.search_by_name(lastLog.request)
          requestIndex = request.to_i if request.match(/^\d+$/)
          if requestIndex and requestIndex < diseases.length
            diagnosis.disease = diseases[requestIndex]
            diagnosis.save
            response = "You have selected: #{diagnosis.disease.name}"
            log_and_send(user, request, response)
          else
            log_and_send(user, request, lastLog.response)
          end
        else
          diseases = Disease.search_by_name(request)
          if diseases
            response = diseases.map.with_index { |disease, index| "(#{index}) #{disease.name}" }.join(" ")
            response = "Select a number: #{response}"
            log_and_send(user, request, response)
          end
        end
      end

      puts "==================================="
      puts diagnosis.to_json
      puts "==================================="

      # Run through all of the symptoms
      if diagnosis.disease_id != nil
        # Get the correct disease and symptoms
        disease = Disease.find(diagnosis.disease_id)
        symptoms = disease.symptoms.first.symptoms
        puts symptoms.to_json
        # See if the user has started symptoms yet
        if diagnosis.symptom_id == nil
          diagnosis.symptom_id = -1
        end
        if diagnosis.symptom_id < symptoms.length - 1
          adjusted = false
          if ["yes", "y"].include?(request.downcase)
            diagnosis.symptom_score += 1
            adjusted = true
          end
          if ["no", "n"].include?(request.downcase)
            diagnosis.symptom_score -= 0.5
            adjusted = true
          end
          if !adjusted and diagnosis.symptom_id > -1
            lastLog = user.logs.last
            response = lastLog.response
            log_and_send(user, request, response)
          else
            diagnosis.symptom_id += 1
            symptom_name = symptoms[diagnosis.symptom_id].name.split("_").join(" ")
            response = "Are you currently feeling #{symptom_name}"
            log_and_send(user, request, response)
          end
        end
        diagnosis.save
      end

      # Run through all of the factors

    # Start a new diagnosis
    else
      if user.age
        diagnosis = Diagnosis.create(:user_id => user.id, :in_progress => true, :symptom_score => 0, :factor_score => 0)
        response = "What would you like to evaluate today?"
        log_and_send(user, request, response)
      end

    end

    render nothing: true
  end

  private

  def log_and_send(user, request, response)
    Log.create(:user_id => user.id, :request => request, :response => response)
    send_message user.phone, response
  end

  def send_message(number, body)
    client = Twilio::REST::Client.new ENV["TWILIO_SID"], ENV["TWILIO_TOKEN"]
    message = client.account.messages.create(:body => body, :to => number, :from => ENV["TWILIO_NUM"])
    return message.sid
  end

end