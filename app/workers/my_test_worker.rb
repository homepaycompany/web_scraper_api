class MyTestWorker
  include Sidekiq::Worker
  def perform
    a = []
    10000.times do
      a << 1
    end
  end
end
