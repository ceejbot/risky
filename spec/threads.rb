Risky.riak = proc { Riak::Client.new(:host => '127.0.0.1') }

class Crud < Risky
  bucket '_test_crud'
  attribute :value
end

class Concurrent < Risky
  bucket '_test_concurrent'
  allow_mult
  attribute :v

  # Merge value v together as a list
  def self.merge(versions)
    p = super versions
    p.v = versions.inject([]) do |merged, version|
      merged + [*version.v]
    end.uniq
    p
  end
end

describe 'Threads' do
  should 'support concurrent modification' do
    Concurrent.bucket.props['allow_mult'].should.be.true

    # Riak doesn't do well with concurrent *new* writes, so get an existing
    # value in there first.
    c = Concurrent.get_or_new('c')
    c.v = []
    c.save(:w => :all)

    workers = 10

    # Make a bunch of concurrent writes
    (0...workers).map do |i|
      Thread.new do
        # Give them a little bit of jitter, just to make the vclocks interesting
        sleep rand/6
        c = Concurrent.get_or_new('c')
        c.v << i
        c.save or raise
      end
    end.each do |thread|
      thread.join
    end

    # Check to ensure we obsoleted or have an extant write for every thread.
    final = Concurrent['c', {:r => :all}]
    final.v.compact.sort.should == (0...workers).to_a
  end

	should "clean up after itself" do
		# this goes in an after block but bacon doesn't have them?
		Concurrent.each { |x| x.delete }
		Concurrent.count.should == 1
	end
end
