class MyTestWorker
  include Sidekiq::Worker
  def perform
    a = []
    1000000.times do
      a << 1
    end
  end
end
