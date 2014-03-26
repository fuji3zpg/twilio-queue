class CallController < ApplicationController
  protect_from_forgery except: [:receive, :voice]

  def client
    @client_name = default_client

    account_sid = ENV['TWILIO_SID']
    auth_token = ENV['TWILIO_TOKEN']

    demo_app_sid = ENV['TWILIO_DEMO_APP_SID']
    capability = Twilio::Util::Capability.new account_sid, auth_token
    capability.allow_client_outgoing demo_app_sid
    capability.allow_client_incoming @client_name
    @token = capability.generate
  end

  def voice
    response = Twilio::TwiML::Response.new do |r|
      # callerIdは、取得したTwilioの番号か、Twilioに認証された電話番号（Caller ID）を設定する
      r.Dial :callerId => ENV['TWILIO_CALL_FROM'] do |d|
        d.Client default_client()
      end
    end

    render xml: response.text
  end

  private

  def default_client
    "Agent1"
  end
end
