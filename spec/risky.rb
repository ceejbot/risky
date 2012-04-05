class User < Risky
  attribute :admin, :default => false
  bucket '_test_users'
end

describe 'Risky' do
  should 'have a bucket' do
    User.bucket.should.be.kind_of? Riak::Bucket
  end

  should 'store a value and retrieve it' do
    u = User.new('test', 'admin' => true)
    u.save.should.not.be.false

    u2 = User['test']
    u.key.should == 'test'
    u.admin.should == true
  end

  should "clean up after itself" do
    User.count.should == 1
    User.each { |x| x.delete }
  end
end
