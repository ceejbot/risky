class Linked < Risky
	self.riak = lambda { |k| Riak::Client.new(:host => '10.0.0.14', :protocol => 'pbc') }
	
	bucket '_test_links'
	attribute :name
	link :another
end

describe 'links' do
	before do
		Linked.each { |x| x.delete }
	end

	should 'save a single link to another object' do
		one = Linked.new 'one', :name => 'one'
		one.save.should.not.be.false

		two = Linked.new 'two', :name => 'two'
		two.another = one
		two.save.should.not.be.false

		one.another = two
		one.save
		
		result = Linked['one']
		result.another.should == two.key

		result2 = Linked['two']
		result2.another.should == one.key
	end

	should "clean up after itself" do
		# this goes in an after block but bacon doesn't have them?
		Linked.count.should == 2
		Linked.each { |x| x.delete }
	end

end
