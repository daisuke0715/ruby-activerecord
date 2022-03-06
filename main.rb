require 'active_record'
require 'active_support/all'
require 'pp'

# タイムゾーンの設定
Time.zone_default = Time.find_zone! "Tokyo"
ActiveRecord.default_timezone = :local

# Loggerを使ったSQLの確認
ActiveRecord::Base.logger = Logger.new(STDOUT) # 標準出力でLogを出力

# データベースへ接続するための設定
ActiveRecord::Base.establish_connection(
  "adapter" => "sqlite3",
  "database" => "./myapp.db"
)

# users テーブルをオブジェクトに結びつける
class User < ActiveRecord::Base
  has_many :comments
end

# comment テーブルをオブジェクトに結びつける
class Comment < ActiveRecord::Base
  belongs_to :user
end
