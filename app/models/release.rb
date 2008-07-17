class Release < ActiveRecord::Base
  has_and_belongs_to_many :iterations, :order=>"start_date asc"
  validates_length_of :title, :within=>1..75
  has_many :stories, :finder_sql=>'select s.* from  releases join iterations_releases ir on (releases.id=ir.release_id) join iterations iter on (iter.id=ir.iteration_id) join stories s on(s.iteration_id=iter.id) where releases.id=#{id}'

  def swags_created_on(d)
    @cstats=creation_stats unless @cstats
    @cstats[d.to_s]||0.0
  end

  def stories_passed_on(d)
      @cstats = creation_stats('and  s.state = \'passed\'') unless @cstats
      @cstats[d.to_s]||0.0
  end
  def total_points
    @tswag||=stories.map(&:swag).compact.sum
  end
  def total_days
    @tdays||=iterations.map(&:total_days).compact.sum
  end
  def open_points
    iterations.map{|x|x.open_points}.sum
  end
  def story_count 
    iterations.map{|x|x.story_count}.sum
  end

  def completed_story_count 
    iterations.map{|x|x.completed_story_count}.sum
  end

  def start_date
    if has_iterations?
      iterations.first.start_date
    else
      "No start iteration"
    end
  end
  def end_date
    if has_iterations?
      iterations.last.end_date
    else
      "No end iteration"
    end
  end

  def has_iterations?
    !iterations.empty?
  end
  private
  def creation_stats(condition='')
    q= "select sum(s.swag) as swags, date(s.created_at) as date from releases rel  
    join iterations_releases ir on (rel.id=release_id) 
    join iterations iter on (iter.id=ir.iteration_id) 
    join stories s on (s.iteration_id=iter.id) 
    where rel.id=%d  %s group by date"
    r = Release.connection.select_all(q%[id, condition])
    Hash[*r.map{|x| [x['date'], x['swags'].to_f]}.flatten]

  end

end
