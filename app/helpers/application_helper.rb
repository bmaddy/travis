# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def observe(element, function, event)
    code = <<-CODE
      <script type='text/javascript'>
        Event.observe('#{element}', '#{event}', function(element, value) { #{function} })
      </script>
    CODE
  end
  def render_search_results(partial, collection, locals=nil, msg='No results found')
    if collection && collection.empty?
      return content_tag(:tr, content_tag(:td, msg, :colspan=>'99'))
    else
      render :partial=>partial, :collection=>collection, :locals=>locals
    end
  end
  
  def prev_next_links(current_iteration) 
    prev_iter=current_iteration.previous
    next_iter=current_iteration.next
    prev_link=prev_iter ? link_to(h("< #{prev_iter.title}"), iteration_path(prev_iter), :id=>'prev_iter') : nil
    next_link=next_iter ? link_to(h("#{next_iter.title} >"), iteration_path(next_iter), :id=>'next_iter'): nil
    return [prev_link, next_link].compact.join(' | ')
  end

  def salesforce_link(sf_object, view='show')
    label = close_label = ""
    if view == 'show'
      label = "<h2>Salesforce Ticket:"
      close_label = "</h2>"
    end
    if !sf_object.salesforce_url.blank? && !sf_object.salesforce_ticket_nbr.blank?
      "#{label} <a href='#{sf_object.salesforce_url}', target='_travis_sf'>#{sf_object.salesforce_ticket_nbr}</a>#{close_label}"
    elsif !sf_object.salesforce_url.blank?
      "#{label} <a href='#{sf_object.salesforce_url}', target='_travis_sf'>#{sf_object.salesforce_url}</a>#{close_label}"
    elsif !sf_object.salesforce_ticket_nbr.blank?
      "#{label} #{sf_object.salesforce_ticket_nbr}#{close_label}"
    end
  end

end
