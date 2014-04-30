class CallController < ApplicationController
  # collect_digit、receiveメソッドなどへのCSRFチェックをオフにする。collect_digitメソッドにPOSTメソッドを送る時に、オフにしておかないとエラーが発生する。
  protect_from_forgery except: [:voice, :collect_digit, :receive, :queue, :enqueue]

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
    capability.allow_client_outgoing ENV['TWILIO_DEMO_APP_SID_QUEUE'] # 電話発信機能を使うために必要。TwiML APPSとして作ったアプリのSIDを設定する。
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

  def collect_digit
    base_url = request.protocol + request.host_with_port

    response = Twilio::TwiML::Response.new do |r|
      # 1桁の数字を取得し（numDigits）、actionのTwiMLに渡す。タイムアウトは10秒。
      r.Gather(action: call_enqueue_path, numDigits: 1, timeout: 10) do
        r.Say('お問い合わせの場合は１、注文の場合は２を押してください', voice: 'woman', language: 'ja-JP')
      end

      # タイムアウト時の処理
      r.Say('何も入力されませんでした', voice: 'woman', language: 'ja-JP')
      r.Redirect base_url + "/call/enqueue"
    end

    render xml: response.text
  end

  def receive
    response = Twilio::TwiML::Response.new do |r|
      r.Dial callerId: ENV['TWILIO_CALL_FROM'] do |d|
        if params[:Digits] == "1"
          d.Client 'Agent1'
        else
          d.Client 'Agent2'
        end
      end
    end

    render xml: response.text
  end

  def queue
    response = Twilio::TwiML::Response.new do |r|
      queue_name = params[:Queue] || default_queue
      r.Say "#{queue_name}のキューに接続しました。", voice: 'woman', language: 'ja-JP'

      r.Dial do |d|
        d.Queue queue_name
      end
    end

    render xml: response.text
  end

  def enqueue
    response = Twilio::TwiML::Response.new do |r|
      params[:Digits] == "1" ? queue_name = "カスタマーサービス" : queue_name = default_queue

      r.Say "コールが#{queue_name}キューにはいりました。", voice: 'woman', language: 'ja-JP'
      r.Enqueue queue_name
    end

    render xml: response.text
  end

  private

  def default_client
    "Agent1"
  end

  def default_queue
    "受注"
  end
end
