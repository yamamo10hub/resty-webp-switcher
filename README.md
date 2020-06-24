### resty-webp-conv-proxy

---
#### 説明

Cache-> Origin 間に設置するwebp画像変換Proxy

---
#### 動作について
クライアントからのリクエストのヘッダ "Accept:" に以下を含む場合、画像変換ホストへリクエストを行う  
```
image/webp
```
画像変換サーバーへリクエストを行った場合、変換サーバー用のURLに書き換えてリクエストを行い  
クライアント(cacheserver)にレスポンスされるのはwebpに変換された画像ファイルとなる。  

上記を含まない場合(変換対象でない場合)、通常のオリジンサーバーへ取得を行う  
  
また、image/webpの付与されたリクエストによって変換サーバーにリクエストした時、  
以下の場合は通常のオリジンサーバーへ取得を行う  
* 10secのタイムアウト制限があり、応答が失敗している場合  
* ステータスコードが "200 or 304" でない場合  
  
200の場合、変換サーバーのresponsebodyと以下のヘッダ内容を応答する  
* Content-Type: image/webp
* Content-Length: [変換サーバーの応答ヘッダ(content-length)の値] 
* Last-Modified: [変換サーバーの応答ヘッダ(last-modified)の値]
  
304の場合、以下の内容を応答する
* 変換サーバーの応答ステータスコードの値を自身の応答ステータスコードとする

logは標準出力されるのでdocker logsで確認する  
 
環境変数として以下を渡し、環境変数の内容でnginx.confを書き換えて生成すると同時に  
openrestyを起動させる  
  
コンテナ起動時に指定する環境変数は以下  
```
SERVICE_FQDN クライアントからリクエストを受け付けている配信FQDN
WEBP_SERVER  画像変換サーバーのFQDN
ORG_SERVER   画像以外のリクエスト参照用FQDN(originサーバー)
ORG_PORT　　 originサーバーアクセス時のポート番号(殆ど443か80を指定するはず)
ORG_PREFIX　 originサーバーへのアクセスプロトコル(ORG_PORTが443ならhttps、80ならhttp)
```
  
変換サーバーへのリクエストURLは以下となる
```
https://[変換serverFQDN]/?url=[ORG_PREFIX]://[SERVICE_FQDN]/[リクエストURI]&op=format&fmt=webp&
resolve_ip=[ORG_SERVER]&resolve_port[ORG_PORT]
```
変換serverは外部作成されたものを使用したため、自前で利用する場合は作成することになる
外部作成された変換serverの必要パラメーターは以下になる
* url=[画像のURL]
* op=format //fmtを指定するための固定値
* fmt=webp //変換フォーマットのタイプ指定
* resolve_ip=[] //参照先サーバーIP or FQDN
* resolve_port=[] //参照先のport番号


#### 起動例
```
cd resty-webp-conv-proxy  
  
docker build -t ./ resty-webp-conv-proxy  
  
docker run -d -p 80:80 \
-e SERVICE_FQDN=www.mysite.info \ 
-e WEBP_SERVER=webpconvert.mysite.info \ 
-e ORG_SERVER=www-org.mysite.info \ 
-e ORG_PORT=80 \ 
-e ORG_PREFIX=http \ 
--restart=always --name resty-mysite001-webp resty-webp-switcher  
  
※-p指定のhost側のport番号は任意(この場合は80を指定している)  
```
