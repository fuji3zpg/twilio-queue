class CallController < ApplicationController
  # voiceメソッドへのCSRFチェックをオフにする。voiceメソッドにPOSTメソッドを送る時に、オフにしておかないとエラーが発生する。
  protect_from_forgery except: [:voice]

  def client
    # パラメータ"client"でクライアント名を設定する。未設定の場合は、デフォルトのエージェント名を使用する
    @client_name = params[:client]

    if @client_name.nil?
      @client_name = default_client
    end

    # 以下、エージェント用クライアントが使える機能を設定する
    account_sid = ENV['TWILIO_SID']
    auth_token = ENV['TWILIO_TOKEN']

    capability = Twilio::Util::Capability.new account_sid, auth_token
    capability.allow_client_incoming @client_name # 電話応答機能を有効に
    @token = capability.generate # エージェント用クライアントに設定するトークン
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
