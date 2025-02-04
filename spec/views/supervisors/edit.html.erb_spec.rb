require "rails_helper"

RSpec.describe "supervisors/edit", type: :view do
  before do
    admin = build_stubbed :casa_admin
    enable_pundit(view, admin)
    allow(view).to receive(:current_user).and_return(admin)
  end

  it "displays the 'Unassign' button next to volunteer being currently supervised by the supervisor" do
    supervisor = create :supervisor
    volunteer = create :volunteer, supervisor: supervisor

    assign :supervisor, supervisor
    assign :all_volunteers_ever_assigned, [volunteer]
    assign :available_volunteers, []

    render template: "supervisors/edit"

    expect(rendered).to include(unassign_supervisor_volunteer_path(volunteer))
    expect(rendered).to_not include("Unassigned")
  end

  it "does not display the 'Unassign' button next to volunteer no longer supervised by the supervisor" do
    casa_org = create :casa_org
    supervisor = create :supervisor, casa_org: casa_org
    volunteer = create :volunteer, casa_org: casa_org
    create :supervisor_volunteer, :inactive, supervisor: supervisor, volunteer: volunteer

    assign :supervisor, supervisor
    assign :supervisor_has_unassigned_volunteers, true
    assign :all_volunteers_ever_assigned, [volunteer]
    assign :available_volunteers, []

    render template: "supervisors/edit"

    expect(rendered).to_not include(unassign_supervisor_volunteer_path(volunteer))
    expect(rendered).to include("Unassigned")
  end

  describe "invite and login info" do
    let(:volunteer) { create :volunteer }
    let(:supervisor) { build_stubbed :supervisor }
    let(:admin) { build_stubbed :casa_admin }

    it "shows for a supervisor editig a supervisor" do
      enable_pundit(view, supervisor)
      allow(view).to receive(:current_user).and_return(supervisor)

      assign :supervisor, supervisor
      assign :all_volunteers_ever_assigned, [volunteer]
      assign :available_volunteers, []

      render template: "supervisors/edit"

      expect(rendered).to have_text("Added to system ")
      expect(rendered).to have_text("Invitation email sent \n  never")
      expect(rendered).to have_text("Last logged in")
      expect(rendered).to have_text("Invitation accepted \n  never")
      expect(rendered).to have_text("Password reset last sent \n  never")
    end

    it "shows for an admin editing a supervisor" do
      enable_pundit(view, supervisor)
      allow(view).to receive(:current_user).and_return(admin)

      assign :supervisor, supervisor
      assign :all_volunteers_ever_assigned, [volunteer]
      assign :available_volunteers, []

      render template: "supervisors/edit"

      expect(rendered).to have_text("Added to system ")
      expect(rendered).to have_text("Invitation email sent \n  never")
      expect(rendered).to have_text("Last logged in")
      expect(rendered).to have_text("Invitation accepted \n  never")
      expect(rendered).to have_text("Password reset last sent \n  never")
    end
  end
end
