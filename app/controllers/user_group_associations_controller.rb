# encoding: utf-8
class UserGroupAssociationsController < ApplicationController

  def show
    @user_group_association = UserGroupAssociation.find(params[:id])
    authorize! :read, @user_group_association
  end

  def edit
    @user_group_association = UserGroupAssociation.find(params[:id])
    authorize! :update, @user_group_association
  end

  def update
    @user_group_association = UserGroupAssociation.find(params[:id])
    authorize! :update, @user_group_association

    respond_to do |format|
      if @user_group_association.update_attributes(params[:user_group_association])
        format.html { redirect_to params[:from] == "group" ? @user_group_association.group : @user_group_association.user, notice: 'Zmiany zapisane.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_group_association.errors, status: :unprocessable_entity }
      end
    end
  end

  def new
    @user_group_association = UserGroupAssociation.new
    if (params[:user_id])
      @user_group_association.user = User.find(params[:user_id])
      @groups = current_user.find_groups.reject { |g| @user_group_association.user.groups.include?(g) }
    elsif (params[:group_id])
      @user_group_association.group = Group.find(params[:group_id])
      @users = current_user.users_to_manage.reject { |u| @user_group_association.group.users.include?(u) }
      @user_group_association.user = @users.first
    end
    authorize! :create, @user_group_association
  end

  def create
    @user_group_association = UserGroupAssociation.new(params[:user_group_association])
    authorize! :create, @user_group_association
    
    respond_to do |format|
      if @user_group_association.save
        format.html { redirect_to params[:from] == "group" ? @user_group_association.group : @user_group_association.user, notice: 'Użytkownik przypisany do grupy.' }
        format.json { render json: @user_group_association, status: :created, location: @user_group_association }
      else
        format.html { render action: "new" }
        format.json { render json: @user_group_association.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user_group_association = UserGroupAssociation.find(params[:id])
    authorize! :destroy, @user_group_association

    user = @user_group_association.user
    @user_group_association.destroy

    respond_to do |format|
      format.html { redirect_to params[:from] == "group" ? group : user }
      format.json { head :ok }
    end
  end
end
