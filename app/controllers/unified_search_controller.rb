class UnifiedSearchController < ApplicationController
  before_filter :login_required

  def index
    @stories  = Sunspot.search(Story)do
      fulltext params[:q]
      paginate(:page=>params[:page])
    end
    @bugs  = Sunspot.search(Bug)do
      fulltext params[:q]
      paginate(:page=>params[:page])
    end

    @all_story_results = @stories.hits
    
    @stories_swag = @all_story_results.sum {|s| s.swag || 0 }
    @passed_stories_count = state_count(@all_story_results, "passed")
    @passed_stories_swag = sum_swag_by_state(@all_story_results, "passed")
    @qc_stories_count = state_count(@all_story_results, "in_qc")
    @qc_stories_swag = sum_swag_by_state(@all_story_results, "in_qc")
    @dev_stories_count = state_count(@all_story_results, "in_progress")
    @dev_stories_swag = sum_swag_by_state(@all_story_results, "in_progress")
    @new_stories_count = state_count(@all_story_results, "new")
    @new_stories_swag = sum_swag_by_state(@all_story_results, "new")
    @unswagged_count = @all_story_results.select {|s| s.swag == nil }.length
    render :template=>'shared/unified_search_results'
  end
  
  private
  def state_count(coll, state)
    coll.select {|s| s.state == state }.length
  end
  
  def sum_swag_by_state(coll, state)
    coll.sum {|s| s.state == state ? (s.swag || 0) : 0}
  end
end
