class MyTestWorker
  include Sidekiq::Worker
  def perform
    test_method
    GC.start
  end

  def test_method
    a = []
    1000000.times do
      a << 1
    end
  end
end
