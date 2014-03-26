class Call
  def self.to_default_agent
    account_sid = ENV['TWILIO_SID']
    auth_token = ENV['TWILIO_TOKEN']

    client = Twilio::REST::Client.new(account_sid, auth_token)

    call = client.account.calls.create(
      from: ENV['TWILIO_CALL_FROM'],
      to: ENV['TWILIO_CALL_TO'],
      url: ENV['TWILIO_XML_URL'],
      method: 'post'
    )
  end
end
