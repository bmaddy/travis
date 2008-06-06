require 'spec/spec_helper'
# require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe Ziya::Charts::Base do
  before( :each ) do
    @chart = Ziya::Charts::Base.new
  end
    
  describe "#initialize" do
    before( :each ) do
      @chart = Ziya::Charts::Base.new( "test_license", "test_id" ) 
    end
    
    it "should create a chart with the correct license" do
      @chart.license.should == "test_license"
    end    
    
    it "should create a chart with the correct id" do
      @chart.id.should == "test_id"
    end        
  end    

  describe "it should produce the correct xml for a basic chart" do
    chart = Ziya::Charts::Base.new( "aaa" )
    chart.add( :axis_category_text, %w[fox dog] )
    chart.add( :series, "test", [10, 20] )
    chart.to_xml.should == "<chart><license>aaa</license><chart_data><row><null/><string>fox</string><string>dog</string></row><row><string>test</string><number>10</number><number>20</number></row></chart_data></chart>"
  end
    
  describe "#add" do
    before( :each ) do
      @chart = Ziya::Charts::Base.new
    end

    it "should support setting an axis category" do
      @chart.add( :axis_category_text, %w[fox cat dog] )
      @chart.to_xml.should == "<chart><chart_data><row><null/><string>fox</string><string>cat</string><string>dog</string></row></chart_data></chart>"
    end    
    it "should error if the axis category is not an array" do
      lambda { @chart.add( :axis_category_text, "") }.should raise_error( ArgumentError, /array of categories/i )
    end    
    
    it "should support setting a composite chart urls" do
      @chart.add( :composites, %w[url1 url2] )
      @chart.to_xml.should == "<chart></chart>"
    end    
    it "should error if the composite url arg is not an array" do
      lambda { @chart.add( :composites, "") }.should raise_error( ArgumentError, /array of urls/i )
    end    
    
    it "should support setting the axis value text" do
      @chart.add( :axis_category_text, %w[dog cat] )        
      @chart.add( :axis_value_text, %w[blee duh] )
      @chart.to_xml.should == "<chart><axis_value_text><string>blee</string><string>duh</string></axis_value_text><chart_data><row><null/><string>dog</string><string>cat</string></row></chart_data></chart>"
    end    
    it "should error if the axis value text arg is not an array" do
      lambda { @chart.add( :axis_value_text, "") }.should raise_error( ArgumentError, /array of values/i )
    end    
    
    it "should support adding series" do
      @chart.add( :axis_category_text, %w[dog cat] )      
      @chart.add( :series, "test", %w[10 20] )
      @chart.to_xml.should == "<chart><chart_data><row><null/><string>dog</string><string>cat</string></row><row><string>test</string><string>10</string><string>20</string></row></chart_data></chart>"
    end    
    
    it "should support adding labels to series" do
      @chart.add( :axis_category_text, %w[dog cat] )
      @chart.add( :series, "test", [10,20], %w[label1 label2] )
      @chart.to_xml.should == "<chart><chart_data><row><null/><string>dog</string><string>cat</string></row><row><string>test</string><number>10</number><number>20</number></row></chart_data><chart_value_text><row><null/></row><row><null/><string>label1</string><string>label2</string></row></chart_value_text></chart>"
    end

    it "should error if a series is defined but no axis_category is specified" do
      @chart.add( :series, "test", [10,20], %w[label1 label2] )      
      lambda { @chart.to_xml }.should raise_error( RuntimeError, /axis_category_text/i )
    end 
    
    it "should error if the series has no name" do
      lambda { @chart.add( :series, nil) }.should raise_error( ArgumentError, /series name/i )
    end 
       
    it "should error if the series is not an arry" do
      lambda { @chart.add( :series, "test", nil) }.should raise_error( ArgumentError, /data points/i )
    end    
    
    it "should error if the user data has no key" do
      lambda { @chart.add( :user_data, nil) }.should raise_error( ArgumentError, /specify a key/i )
    end    
    it "should error if the user data has no key" do
      lambda { @chart.add( :user_data, :fred, "blee") }.should_not raise_error( ArgumentError, /specify a key/i )
    end    
    
    it "should support setting yaml styles directly" do
      @chart.add( :styles, "--- !ruby/object:Ziya::Charts::Base\n" )
      @chart.to_xml.should == "<chart></chart>"
    end    
    it "should error if no style is specified" do
      lambda { @chart.add( :styles, "") }.should raise_error( ArgumentError, /set of styles/i )
    end    

    it "should support mixed charts" do
      @chart.add( :chart_types, %w[line bar] )
      @chart.to_xml.should == "<chart><chart_type><string>line</string><string>bar</string></chart_type></chart>"
    end    
    it "should error if no chart types are specified" do
      lambda { @chart.add( :chart_types, "") }.should raise_error( ArgumentError, /set of chart types/i )
    end    

    it "should support setting a themes" do
      @chart.add( :theme, "blee" )
      @chart.to_xml.should == "<chart></chart>"
    end    
    it "should error if no chart types are specified" do
      lambda { @chart.add( :theme, "") }.should raise_error( ArgumentError, /theme name/i )
    end    
    
    it "should error if an invalid option is specified" do
      lambda { @chart.add( :fred, "") }.should raise_error( ArgumentError, /invalid directive/i )
    end        
  end
end
