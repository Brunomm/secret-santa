class PagesController < ApplicationController
  before_action :authenticate_user!

  def home
    redirect_to campaigns_path if current_user.campaigns.exists?
  end

end