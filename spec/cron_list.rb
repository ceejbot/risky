class Item < Risky
  self.riak = lambda { |k| Riak::Client.new(:host => '10.0.0.14', :protocol => 'pbc') }

  bucket '_test_items'

  attribute :v
end

class CronList < Risky
  include Risky::CronList

  self.riak = lambda { |k| Riak::Client.new(:host => '10.0.0.14', :protocol => 'pbc') }
  
  bucket '_test_cron_list'
  item_class Item
  limit 5
end

describe Risky::CronList do
  before do
    CronList.each { |x| x.delete }
    @l = CronList.new 'test'
  end

  should 'store an item' do
    @l << {:v => 1}
    @l.items.first.should.be.kind_of String
    Item[@l.items.first].should.be.nil
    @l.save.should.not.be.false

    @l.reload
    @l.items.size.should == 1
    @l.items.first.should.be.kind_of? String
    i = Item[@l.items.first]
    i.should.be.kind_of? Item
    i.v.should == 1
  end

  should 'limit items' do
    10.times do |i|
      @l << {:v => i}
    end
    @l.save.should.not.be.false
    @l.reload
    @l.items.size.should == 5
    @l.items.map { |k|
      Item[k].v
    }.sort.should == (5...10).to_a
  end

  should "clean up after itself" do
    CronList.each { |x| x.delete }
    CronList.count.should == 1
  end

end
