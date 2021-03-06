require 'test_helper'

class UnifiedSearchControllerTest < ActionController::TestCase

  def setup
    @request.session[:user_id]=1
  end
  
  def test_search
    stories = Story.find(:all, :limit=>10)
    bugs = Bug.find(:all, :limit=>10)
    bugs.stubs('total_pages'=>1)
    stories.stubs('total_pages'=>1)
    mock_sres=stub('results', 'hits'=>stories, 'total_pages'=>1)
    mock_bres=stub('results', 'hits'=>bugs,  'total_pages'=>1)

    Sunspot.expects(:search).with(Story).returns(mock_sres)
    Sunspot.expects(:search).with(Bug).returns(mock_bres)
    
    get :index, :q => 'irrelevant', :page => 1
    assert_response :success
    assert_template "shared/unified_search_results"
    
    assert stories = assigns(:stories)
    assert bugs = assigns(:bugs)
    
    assert stories_swag = assigns(:stories_swag)
    assert_equal Story.all.sum {|s| s.swag || 0 }, stories_swag
    
    assert passed_stories_count = assigns(:passed_stories_count)
    assert_equal Story.count(:all, :conditions => {:state => "passed"}), passed_stories_count
    
    assert passed_stories_swag = assigns(:passed_stories_swag)
    assert_equal Story.find(:all, :conditions => {:state => "passed"}).sum {|s| s.swag || 0}, passed_stories_swag
    
    assert qc_stories_count = assigns(:qc_stories_count)
    assert_equal Story.count(:all, :conditions => {:state => "in_qc"}), qc_stories_count
    
    assert qc_stories_swag = assigns(:qc_stories_swag)
    assert_equal Story.find(:all, :conditions => {:state => "in_qc"}).sum {|s| s.swag || 0}, qc_stories_swag
    
    assert dev_stories_count = assigns(:dev_stories_count)
    assert_equal Story.count(:all, :conditions => {:state => "in_progress"}), dev_stories_count
    
    assert dev_stories_swag = assigns(:dev_stories_swag)
    assert_equal Story.find(:all, :conditions => {:state => "in_progress"}).sum {|s| s.swag || 0}, dev_stories_swag
    
    assert new_stories_count = assigns(:new_stories_count)
    assert_equal Story.count(:all, :conditions => {:state => "new"}), new_stories_count
    
    assert new_stories_swag = assigns(:new_stories_swag)
    assert_equal Story.find(:all, :conditions => {:state => "new"}).sum {|s| s.swag || 0}, new_stories_swag
    
    assert unswagged_count = assigns(:unswagged_count)
    assert_equal Story.unswagged.count, unswagged_count
  end
end
