# frozen_string_literal: true

module SuperAdmin

  class UsersController < ApplicationController

    include OrgSelectable

    after_action :verify_authorized

    # GET /super_admin/users/:id/edit
    def edit
      @user = User.find(params[:id])
      authorize @user
      @departments = @user.org.departments.order(:name)
      @plans = Plan.active(@user).page(1)
      render "super_admin/users/edit",
             locals: { user: @user,
                       departments: @departments,
                       plans: @plans,
                       languages: @languages,
                       orgs: @orgs,
                       identifier_schemes: @identifier_schemes,
                       default_org: @user.org }
    end

    # PUT /super_admin/users/:id
    # rubocop:disable Metrics/AbcSize
    def update
      @user = User.find(params[:id])
      authorize @user
      @departments = @user.org.departments.order(:name)
      @plans = Plan.active(@user).page(1)
      # See if the user selected a new Org via the Org Lookup and
      # convert it into an Org
      attrs = user_params

      if @user.update_attributes(attrs)
        org = process_org!
        @user.update(org_id: org.id) if org.present?

        flash.now[:notice] = success_message(@user, _("updated"))
      else
        flash.now[:alert] = failure_message(@user, _("update"))
      end
      render :edit
    end
    # rubocop:enable Metrics/AbcSize

    # PUT /super_admin/users/:id/merge
    def merge
      @user = User.find(params[:id])
      authorize @user
      remove = User.find(params[:merge_id])

      if @user.merge(remove)
        flash.now[:notice] = success_message(@user, _("merged"))
      else
        flash.now[:alert] = failure_message(@user, _("merge"))
      end
      # After merge attempt get departments and plans
      @departments = @user.org.departments.order(:name)
      @plans = Plan.active(@user).page(1)
      render :edit
    end

    # GET /super_admin/users/:id/search
    def search
      @user = User.find(params[:id])
      @users = User.where("email LIKE ?", "%#{params[:email]}%")
      authorize @users
      @departments = @user.org.departments.order(:name)
      @plans = Plan.active(@user).page(1)
      # WHAT TO RETURN!?!?!
      if @users.present? # found a user, or Users, submit for merge
        render json: {
          form: render_to_string(partial: "super_admin/users/confirm_merge.html.erb")
        }
      else # NO USER, re-render w/error?
        flash.now[:alert] = "Unable to find user"
        render :edit # re-do as responding w/ json
      end
    end

    # PUT /super_admin/users/:id/archive
    def archive
      @user = User.find(params[:id])
      authorize @user
      @departments = @user.org.departments.order(:name)
      @plans = Plan.active(@user).page(1)
      if @user.archive
        flash.now[:notice] = success_message(@user, _("archived"))
      else
        flash.now[:alert] = failure_message(@user, _("archive"))
      end
      render :edit
    end

    private

    def user_params
      params.require(:user).permit(:email,
                                   :firstname,
                                   :surname,
                                   :department_id,
                                   :language_id)
    end

  end

end
