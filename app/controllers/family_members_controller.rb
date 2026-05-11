class FamilyMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_family_member, only: [:edit, :update, :destroy]

  def new
    @family_member = FamilyMember.new
  end

  def create
    respond_to do |format|
      @family_member = current_active_profile.family_members.build(family_params)
      if @family_member.save
        format.js { flash[:notice] = "Family Details added successfully." }
      else
        format.js { flash[:notice] = "Family Details failed to update. Try again" }
      end
    end
  end

  def edit

  end

  def update
    respond_to do |format|
      if  @family_member.update(family_params)
        format.js { flash[:notice] = "Family Details updated successfully." }
      else
        format.js { flash[:notice] = "Family Details failed to update. Try again" }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @family_member.destroy
        format.js { flash[:notice] = "Family Details deleted successfully." }
      else
        format.js { flash[:notice] = "Family Details failed to delete. Try again" }
      end
    end
  end

  private

  def set_family_member
    @family_member = FamilyMember.find_by(id: params[:id])
  end

  def family_params
    params.require(:family_member).permit!
  end
end
