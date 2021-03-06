class ApplicationController < ActionController::Base
  protect_from_forgery
  
  #should be skip_before in members.rb (http://www.mail-archive.com/merb@googlegroups.com/msg01067.html)
  #but not supported yet
  
  before_filter :ensure_authenticated
  before_filter :ensure_member_active
  before_filter :ensure_organisation_active
  before_filter :ensure_member_inducted
   
  def date_format(d)
    d.to_s(:long)
  end
  
  helper_method :current_user
  def current_user
    @current_user if user_logged_in?
  end
  
  # Returns true if a user is logged in; false otherwise.
  def user_logged_in?
    current_user = @current_user
    current_user ||= session[:user] ? Member.find_by_id(session[:user]) : false
    @current_user = current_user
    current_user.is_a?(Member)
  end
  
  # Stores the given user as the 'current user', thus marking them as logged in.
  def current_user=(user)
    session[:user] = (user.nil? || user.is_a?(Symbol)) ? nil : user.id
    @current_user = user
  end
  
  def store_location
    session[:return_to] = request.fullpath
  end
  
  def redirect_back_or_default(default = root_path)
    session[:return_to] ? redirect_to(session[:return_to]) : redirect_to(default)
    session[:return_to] = nil
  end
  
  def prepare_constitution_view
    @organisation_name = Organisation.organisation_name
    @objectives = Organisation.objectives
    @assets = Organisation.assets
    @website = Organisation.domain

    @period  = Clause.get_integer('voting_period')
    @voting_period = VotingPeriods.name_for_value(@period)

    @general_voting_system = Constitution.voting_system(:general)
    @membership_voting_system = Constitution.voting_system(:membership)
    @constitution_voting_system = Constitution.voting_system(:constitution)
  end
  
  protected
  
  def ensure_authenticated
    if user_logged_in?
      true
    else
      raise Unauthenticated
    end
  end
  
  def ensure_member_active
    raise Unauthenticated if current_user && !current_user.active?
  end
  
  def ensure_organisation_active
    return if Organisation.active?
    
    if Organisation.pending?
      redirect_to(:controller => 'induction', :action => 'founding_meeting')
    else
      redirect_to(:controller => 'induction', :action => 'founder')
    end
  end
  
  def ensure_member_inducted
    redirect_to_welcome_member if Organisation.active? && current_user && !current_user.inducted?
  end
  
  def redirect_to_welcome_member
    redirect_to(:controller => 'welcome', :action => 'index')
  end
  
  # EXCEPTIONS
  
  rescue_from NotFound, :with => :render_404
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404
  def render_404
    render :file => "#{Rails.root}/public/404.html", :status => 404
  end
  
  rescue_from Unauthenticated, :with => :handle_unauthenticated
  def handle_unauthenticated
    if Organisation.has_founding_member?
      store_location
      redirect_to login_path
    else
      redirect_to(:controller => 'induction', :action => 'founder')
    end
  end
end
