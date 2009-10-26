require 'test_helper'

class KaixinusersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kaixinusers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kaixinuser" do
    assert_difference('Kaixinuser.count') do
      post :create, :kaixinuser => { }
    end

    assert_redirected_to kaixinuser_path(assigns(:kaixinuser))
  end

  test "should show kaixinuser" do
    get :show, :id => kaixinusers(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => kaixinusers(:one).to_param
    assert_response :success
  end

  test "should update kaixinuser" do
    put :update, :id => kaixinusers(:one).to_param, :kaixinuser => { }
    assert_redirected_to kaixinuser_path(assigns(:kaixinuser))
  end

  test "should destroy kaixinuser" do
    assert_difference('Kaixinuser.count', -1) do
      delete :destroy, :id => kaixinusers(:one).to_param
    end

    assert_redirected_to kaixinusers_path
  end
end
