module ProjectsHelper

  def get_listing_sortable_options(list_container_id)
    {
      :tag => 'div',
      :handle => 'handle',
      :complete => visual_effect(:highlight, list_container_id),
      :url => order_projects_path
    }
  end
  
  def set_element_visible(id,test)
    if (test)
      page.show id
    else
      page.hide id
    end
  end

  def project_next_prev
    html = ''
    unless @previous_project.nil?
      project_name = truncate(@previous_project.name, :length => 40, :omission => "...")
      html << link_to_project(@previous_project, "&laquo; #{project_name}")
    end
    html << ' | ' if @previous_project && @next_project
    unless @next_project.nil?
      project_name = truncate(@next_project.name, :length => 40, :omission => "...")
      html << link_to_project(@next_project, "#{project_name} &raquo;")
    end
    html
  end
  
  def project_next_prev_mobile
    html = ''
    unless @previous_project.nil?
      project_name = truncate(@previous_project.name, :length => 40, :omission => "...")
      html << link_to_project_mobile(@previous_project, "5", "&laquo; 5-#{project_name}")
    end
    html << ' | ' if @previous_project && @next_project
    unless @next_project.nil?
      project_name = truncate(@next_project.name, :length => 40, :omission => "...")
      html << link_to_project_mobile(@next_project, "6", "6-#{project_name} &raquo;")
    end
    html
  end
  
end
