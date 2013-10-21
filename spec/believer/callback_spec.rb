require 'spec_helper'

describe Believer::Callbacks do

  {:save => [:before, :after, :around],
   :destroy => [:before, :after, :around]
  }.each do |method, hooks|
    hooks.each do |hook|
      it "support #{hook} callback hook on method #{method}" do
        object = Test::Person.new({:id => 1, :name => 'ABC'})

        callback_method = "#{hook}_#{method}".to_sym
        called = false
        Test::Person.send(callback_method, Proc.new {|obj|
          called = true
        })
        object.send(method)

        called.should == true
      end
    end
  end

  #[:before, :after, :around].each do |hook|
  #  it "support #{hook} callback hook on method create" do
  #
  #    callback_method = "#{hook}_save".to_sym
  #    called = false
  #    Test::Person.send(callback_method, Proc.new {|obj|
  #      called = true
  #    })
  #    Test::Person.create({:id => 1, :name => 'ABC'})
  #
  #    called.should == true
  #  end
  #end

  #it "support after_initialize hook" do
  #  called = false
  #  Test::Person.after_initialize do
  #    called = true
  #  end
  #  p = Test::Person.create({:id => 1, :name => 'ABC'})
  #  p.should_not == nil
  #  Test::Person.where(:id => 1).first.should_not == nil
  #  called.should == true
  #end

end