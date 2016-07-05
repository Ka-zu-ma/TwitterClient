# TwitterClient

###アプリ説明
単語を登録しておくと、その単語が含まれるツイートが見れる  	

###あとやること
ツイートが自動更新されるようにする  
ホームボタンを押すと読んでいない始めのところまで移動し、読んでないところから読める  
各ワードのツイート一覧で、ナビゲーションタイテムのタイトルをクリックすると、最新ツイートまで既読   
ロールバックいれる

###後回し
ネガティブ系ワード、ポジティブ系ワードでセルを色分け  
ワード登録画面で、UISegmentedControlでポジティブ、ネガティブ選べるようにする  

###補足
fabric経由でフレームワークをインスコすると、twitterKitとtwitterCoreのバージョンが合わないので、podで手動インストールした  
githubにアップするとき、secretを削除するのを忘れずに。

###エラー
[Fabric] failed to download settings Error Domain=FABNetworkError Code=-5 "(null)" UserInfo={status_code=403, type=2, request_id=0141cd74a897828aa0cc306290c10629, content_type=application/json; charset=utf-8}
