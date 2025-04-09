require "test_helper"

class DevisControllerTest < ActionDispatch::IntegrationTest
  setup do
    @devis = devis(:one)
  end

  test "should get index" do
    get devis_index_url
    assert_response :success
  end

  test "should get new" do
    get new_devis_url
    assert_response :success
  end

  test "should create devis" do
    assert_difference("Devis.count") do
      post devis_index_url, params: { devis: { description: @devis.description, statut: @devis.statut, titre: @devis.titre } }
    end

    assert_redirected_to devis_url(Devis.last)
  end

  test "should show devis" do
    get devis_url(@devis)
    assert_response :success
  end

  test "should get edit" do
    get edit_devis_url(@devis)
    assert_response :success
  end

  test "should update devis" do
    patch devis_url(@devis), params: { devis: { description: @devis.description, statut: @devis.statut, titre: @devis.titre } }
    assert_redirected_to devis_url(@devis)
  end

  test "should destroy devis" do
    assert_difference("Devis.count", -1) do
      delete devis_url(@devis)
    end

    assert_redirected_to devis_index_url
  end
end
