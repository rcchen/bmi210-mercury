require 'twilio-ruby'

class MessagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive
    number = params[:From]
    body = params[:Body]
    sid = send_message number, body
    render nothing: true
  end

  private

  def send_message(number, body)
    client = Twilio::REST::Client.new ENV["TWILIO_SID"], ENV["TWILIO_TOKEN"]
    message = client.account.messages.create(:body => body, :to => number, :from => ENV["TWILIO_NUM"])
    return message.sid
  end

end