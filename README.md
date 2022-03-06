# Active Record学習

## データベースの準備
- Active Record は Ruby on Rails と同じく、テーブル名などのルールが非常に厳格なので、テーブル名は英小文字（英単語）の複数形にするのを忘れないようにすること
- 主キーは id integer primary key としてあげれば OK 
- created_at, updated_at というフィールドも入れておいてあげると、作成日時や更新日時を Active Record の方で自動で管理してくれる
- `sqlite3 myapp.db < import.sql`を実行してimport.sqlをもとに、myapp.dbというデータベース（sqliteではただのファイル）を生成

<br>
## Active Recordの設定
- データベースへの接続設定：ActiveRecord::Base.establish_connection() としつつ、() の中に "adapter" => "sqlite3", "database" => "./myapp.db" としてあげれば OK
- ActiveRecordを使えば、データベース上のテーブルをオブジェクトに結びつける事ができる（ここば味噌）
- 以下のように記述してあげるだけで、データテーブルをオブジェクトに紐づける事ができる

```


# データベースへ接続するための設定
ActiveRecord::Base.establish_connection(
  "adapter" => "sqlite3",
  "database" => "./myapp.db"
)

# users テーブルをオブジェクトに結びつける
class User < ActiveRecord::Base
  
end

```

- データテーブルをオブジェクトに紐づける事ができたことにより、テーブルのレコードは対応する命名のクラスのインスタンスとして扱う事ができるようになる
- また、データテーブルとオブジェクトを紐づけて、データ生成（insert）したとき、ActiveRecordの設定により、自動で連番のidが生成されたり、created_at、updated_atカラムに値が入ったりする！

```
# クラスのインスタンス化が可能になる
user = User.new  # dbのschemaをもとにインスタンスを作成

user.name = "tanaka"
user.age = 23
user.save # レコード（1行のデータ）の作成

# シンボルを使ったハッシュでインスタンスを生成
user = User.new(name: "hayashi", age: 23 )
user.save

# newとsaveを同時に実行
User.create(name: "hosi", age: 22)

# ブロックを使ったinsertの処理
user = User.new do |u|
  u.name = "hayashi"
  u.age = 23
end
```

<br> 
 
 ## Loggerを使ってSQLを確認する方法
 - 処理の結果どのようなSQL文が発行されているか確認する方法

```
# Loggerを使ったSQLの確認方法
# Logger を使えば SQL の命令自体を確認することができる
ActiveRecord::Base.logger = Logger.new(STDOUT) # 標準出力でLogを出力
```

## 値の挿入
```
# insert
# クラスのインスタンス化が可能になる
user = User.new  # dbのschemaをもとにインスタンスを作成

user.name = "tanaka"
user.age = 23
user.save # レコード（1行のデータ）の作成

# シンボルを使ったハッシュでインスタンスを生成
user = User.new(name: "hayashi", age: 23 )
user.save

# newとsaveを同時に実行
User.create(name: "hosi", age: 22)

# ブロックを使ったinsertの処理
user = User.new do |u|
  u.name = "hayashi"
  u.age = 23
end
```

<br>

## データの抽出

### selectを使った値の抽出
```
# データの抽出
# idとnameとageカラムだけ抽出
User.select("id, name, age")

# 最初のレコード
User.select("id, name, age").fist

# 最後のレコード
User.select("id, name, age").last

# 最初の 3 件というような指定
User.select("id, name").first(3) 
```

### findを使った抽出
```
# 抽出条件の設定
# idを指定して抽出
User.find(3)

# id以外のカラムで抽出
User.find_by(name: "tanaka")
# find_by の後にフィールド名をつなげて検索することもでき
User.find_by_name("tanaka")
# 存在しないレコードを抽出した時
# => nil が返ってきている

# レコードが存在しなかった時にはエラーにしたい場合
User.select("id, name").find_by_name!("kiriya")
```
<br>

### whereを使った抽出
- 複雑な条件でデータを抽出する事ができる
- where をつなげていって AND 検索をすることも可能

```
# 20代の人のレコードを抽出
User.select("id, name, age").where(age: 20..29)

# 19 歳と 31 歳の人を抽出
User.select("id, name, age").where(age: [19, 31]) 

# AND検索
User.select("id, name, age").where("age >= 20").where("age < 30") 
# User.select("id, name, age").where("age >= 20 and age < 30") のように書くこともできる

# OR検索
User.select("id, name, age").where("age >= 20 or age < 30") 

# .or命令
User.select("id, name, age").where("age <= 20").or(User.where("age >= 30"))


# NOT 検索
User.select("id, name, age").where.not(id: 3)
```
<br>

### プレースホルダーを使う（変数）
- 注意）変数の値を直接条件文字列に入れ込んでしまうと、悪意のあるコードが紛れ込んでしまう可能性があるので以下のような記載は絶対にしないこと！
```
User.select("id, name, age").where("age >= #{min} and age < #{max}") 
```


```
# プレースホルダーの使い方

max = 30
min = 20

# 「?」に順番に値が入るようになっている
User.select("id, name, age").where("age >= ? and age < ?", min, max) 

# 「?」 がたくさんになってくると、どの値かわかりにくくなってくるのでシンボルを使うやり方もある
User.select("id, name, age").where("age >= :min and age < max", {min: min, max: max}) 

```

<br>

### 文字列の部分一致（LIKE句）
```
# 文字列の部分一致
User.select("id name age").where("name like ?", "%i")
```

<br>

### order, limit, offset
```
# ageで並べ替えたい場合
User.select("id, name, age").order("age") 
User.select("id, name, age").order(:age)

# 逆順にしたい場合
User.select("id, name, age").order("age desc")
User.select("id, name, age").order(age: :desc)

# 件数を制限する
# 若い順で 3 人を抽出
User.select("id, name, age").order(:age).limit(3)

# 最初の1人を飛ばしたい
User.select("id, name, age").order(:age).offset(1)
```


<br>

### 抽出条件を適当な名前をつけて登録しておきたい場合
```
# クラスメソッドとスコープ
class User < ActiveRecord::Base
  # class method
  def self.top3(num)
    select("id, name, age").order(:age).limit(num)
  end

  # scope
  scope :top3 -> (num) { select("id, name, age").order(:age).limit(num) }

end

User.top3(3) #=> 年齢若い3人
```

<br>

### コードの抽出をしてみて、もしそれが存在しなかったらレコードを挿入するという処理

```
# hayashiで検索して該当するレコードがなかったら作成
user = User.find_or_create_by(name: "hayashi") 

# nilのカラムを作らず、他のフィールドも埋めたい時
user = User.find_or_create_by(name: "yokota") do |u|
  u.age = 18 
end 
```

<br>

### データ更新
```
# 1つのレコードを更新： 単機能だけど高速
User.update(〜: ...)

# 複数のレコードを一気に更新：　高機能だけど低速（更新する前後でなんらかの自動処理を加えることもできる）
# 20 歳以上の人の年齢を全て80に変更
User.where("age >= 20").update(age: 80) 

# update_all
# 全てのレコードに対して処理を実行
User.where("age >= 20").update_all("age = age + 2")

```

<br>

### データ削除（更新と同じ）
```
# delete： 単機能だけど高速
# destroy：　高機能だけど低速（削除する前後でなんらかの自動処理を加えることもできる）
```


<br>


### バリデーションについて
- レコードを挿入したり更新したりする時に、ルールを付けることができる仕組み
  
```
# ユーザーのオブジェクトでは、name と age が両方必須
# name 3 文字以上

class User < ActiveRecord::Base
  validates :name, presence: true, length: { minimum:3 }
  validates :age, presence: true
end
```


<br>


### Callbackについて 
- 特定の処理が行われる前後で自動的になんらかの処理を噛ます仕組み
```
class User < ActiveRecord::Base
  before_destroy :print_before_msg
  after_destroy :print_after_msg


  protected
    def print_before_msg
      pp "before delete"
    end

    def print_after_msg
      pp "after delete"
    end
end
```

<br>

### Assosiationについて
- 複数のテーブル（オブジェクト）を関連付けて扱うための仕組み
```
# User -> Comments
# users テーブルをオブジェクトに結びつける
class User < ActiveRecord::Base
  has_many :comments
end

# comment テーブルをオブジェクトに結びつける
class Comment < ActiveRecord::Base
  belongs_to :user
end


# 関連するデータを抽出する場合（include：アソシエーション組んだデータであれば、これで抽出可能）
# user を抽出する時に includeの記述を追加すると、コメント情報も一気に抽出可能
user = User.includes(:comments).find(1) 

# あとはこのデータを使って .each などでデータを表示
user.comments.each do |comment|
  pp "#{user.name}: #{comment.body}"
end

# comment を抽出する時に includeの記述を追加すると、コメント情報も一気に抽出可能
comments = Comment.includes(:user).all

# あとはこのデータを使って .each などでデータを表示
comments.each do |comment|
 pp "#{comment.body} by #{comment.user.name}" 
end
```

<br>

### 関連するデータを削除する
- ユーザーの方を削除したら関連するコメントも削除する、といった処理
```
# データが削除されるのを防ぐためにこうなっていて、関連するオブジェクトを削除をする際には特殊な設定が必要
class User < ActiveRecord::Base
  has_many :comments, dependent: :destory
end
```


<br>

[補足]
- pp => pretty printの略で、わかりやすくログを表示してくれるモジュール
- sqliteで `...>` となったときは、「;」を入力して、処理を抜ける
- ActiveRecordでメソッドの後ろに「!」がついている場合があるが、それは、処理がうまくいかなかった時にErrorを返すという意味
- すでにテーブルがある状態で、新しくテーブルを追加したいとき、すでにあるテーブルも重複して作成することを防止するために、ドロップして真っ新にしてから、テーブル作成を実行すること
- 例えば、今 users テーブルがあるので、users テーブルがある状態で create table するとエラーになるので、drop table if exists users; として、まっさらな状態から実行する

