class UsersController < ApplicationController
  include SessionsHelper

  def show
    @user = User.find(params[:id])
    unless logged_in? && eligible_for_viewing?(@user)
      redirect_to '/422.html'
    end
  end

  def new
    @user = User.new 
  end

  def create
    puts 'creating new user'

    require 'open-uri'
    require 'json'

    puts params[:token]

    #fetch email with OpenJUB-API
    user_info = open("https://api.jacobs-cs.club/user/me"+"?token="+params[:token])
    json = JSON.parse(user_info.read)
    email = json["email"]
    username = json["username"]
    name = json["fullName"]
    token = params[:token]

    @user = User.new(name: name, username: username, email: email, token: token)
    if @user.save
      log_in @user
      flash[:success] = "Welcome to JacobsMKT!"
      render :js => "window.location = '#{@user}'" #due to the ajax call
    else
      flash[:warning] = "Ups! Looks like you are already registered. Try the normal login link."
      redirect_to login_path #why is this not working? => refers to /user/new
    end
  end

  private

    def user_params
      params.require(:user).permit(:email)
    end
end