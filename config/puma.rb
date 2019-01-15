
workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/
  # deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end

#SSLを導入したので、次はアプリケーションの設定をいじって、本番環境に適したWebサーバを使ってみましょう。Herokuのデフォルトでは、Rubyだけで実装されたWEBrickというWebサーバを使っています。WEBrickは簡単にセットアップできたり動せることが特長ですが、著しいトラフィックを扱うことには適していません。つまり、WEBrickは本番環境として適切なWebサーバではありません。よって、今回はWEBrickをPumaというWebサーバに置き換えてみます。Pumaは多数のリクエストを捌くことに適したWebサーバです。

# 新しいWebサーバを追加するために、Heroku内のPumaドキュメント (英語) に従ってセットアップしていきます。

# 最初のステップはpuma gemをGemfileに追加することなのですが、なんとRails 5では、Pumaはデフォルトの設定でも使えるようになっています (リスト 3.2)。したがって、最初のステップはスキップします (ちなみにRails 4.2以前ではconfig/puma.rbファイルを作成し、リスト 7.37のように設定していました)。次のステップは、HerokuのPumaのドキュメントに従って、設定を書き込んでいくことです (リスト 7.37)13。とはいえ今回はドキュメントのコードをそのまま引用しただけなので、中身は理解しなくても大丈夫です (コラム 1.1)。

# # Puma can serve each request in a thread from an internal thread pool.
# # The `threads` method setting takes two numbers: a minimum and maximum.
# # Any libraries that use thread pools should be configured to match
# # the maximum value specified for Puma. Default is set to 5 threads for minimum
# # and maximum; this matches the default thread size of Active Record.
# #
# threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
# threads threads_count, threads_count

# # Specifies the `port` that Puma will listen on to receive requests; default is 3000.
# #
# port        ENV.fetch("PORT") { 3000 }

# # Specifies the `environment` that Puma will run in.
# #
# environment ENV.fetch("RAILS_ENV") { "development" }

# # Specifies the number of `workers` to boot in clustered mode.
# # Workers are forked webserver processes. If using threads and workers together
# # the concurrency of the application would be max `threads` * `workers`.
# # Workers do not work on JRuby or Windows (both of which do not support
# # processes).
# #
# # workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# # Use the `preload_app!` method when specifying a `workers` number.
# # This directive tells Puma to first boot the application and load code
# # before forking the application. This takes advantage of Copy On Write
# # process behavior so workers use less memory. If you use this option
# # you need to make sure to reconnect any threads in the `on_worker_boot`
# # block.
# #
# # preload_app!

# # If you are preloading your application and using Active Record, it's
# # recommended that you close any connections to the database before workers
# # are forked to prevent connection leakage.
# #
# # before_fork do
# #   ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
# # end

# # The code in the `on_worker_boot` will be called if you are using
# # clustered mode by specifying a number of `workers`. After each worker
# # process is booted, this block will be run. If you are using the `preload_app!`
# # option, you will want to use this block to reconnect to any threads
# # or connections that may have been created at application boot, as Ruby
# # cannot share connections between processes.
# #
# # on_worker_boot do
# #   ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
# # end
# #

# # Allow puma to be restarted by `rails restart` command.
# plugin :tmp_restart
