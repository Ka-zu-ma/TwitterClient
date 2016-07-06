# TwitterClient

###アプリ説明
単語を登録しておくと、その単語が含まれるツイートが見れる  	

###あとやること
ツイートが自動更新されるようにする  
ホームボタンを押すと読んでいない始めのところまで移動し、読んでないところから読める  
各ワードのツイート一覧で、ナビゲーションタイテムのタイトルをクリックすると、最新ツイートまで既読   
ロールバックいれる

###やるかわからない、あとまわし
ネガティブ系ワード、ポジティブ系ワードでセルを色分け  
ワード登録画面で、UISegmentedControlでポジティブ、ネガティブ選べるようにする  

###補足
fabric経由でフレームワークをインスコすると、twitterKitとtwitterCoreのバージョンが合わないので、podで手動インストールした  
githubにアップするとき、secretを削除するのを忘れずに。

###エラー
connectionError: Error Domain=TwitterAPIErrorDomain Code=88 "Request failed: client error (429)" 

