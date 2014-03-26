== README

RailsコンソールからTwilioを通じて電話発信し、デフォルトエージェントに着信するRailsアプリケーションです。

call.rb モデル内の環境変数を各自の環境に合わせて設定すれば、Twilioでテストコールできます。

## サンプルの動き
このサンプルでは、以下のことを行います。

* Railsのコンソールから Call.to_default_agent メソッドを呼び出すことで、
* Twilioからデフォルトエージェントに発信します。

    $ rails console
    > Call.to_default_agent


## XMLファイルサンプル
call.rb の ENV['TWILIO_XML_URL'] は、コール着信後に接続するデフォルトエージェントをXML形式で定義しています。
↓ はXMLファイルのサンプルです。

```
<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Dial callerId="+815031540365">
    <Client>Agent1</Client>
  </Dial>
</Response>
```
