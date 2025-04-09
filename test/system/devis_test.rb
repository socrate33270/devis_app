require "application_system_test_case"

class DevisTest < ApplicationSystemTestCase
  setup do
    @devis = devis(:one)
  end

  test "visiting the index" do
    visit devis_url
    assert_selector "h1", text: "Devis"
  end

  test "should create devis" do
    visit devis_url
    click_on "New devis"

    fill_in "Description", with: @devis.description
    fill_in "Statut", with: @devis.statut
    fill_in "Titre", with: @devis.titre
    click_on "Create Devis"

    assert_text "Devis was successfully created"
    click_on "Back"
  end

  test "should update Devis" do
    visit devis_url(@devis)
    click_on "Edit this devis", match: :first

    fill_in "Description", with: @devis.description
    fill_in "Statut", with: @devis.statut
    fill_in "Titre", with: @devis.titre
    click_on "Update Devis"

    assert_text "Devis was successfully updated"
    click_on "Back"
  end

  test "should destroy Devis" do
    visit devis_url(@devis)
    click_on "Destroy this devis", match: :first

    assert_text "Devis was successfully destroyed"
  end
end
