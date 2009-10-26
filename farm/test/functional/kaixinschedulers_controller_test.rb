require 'test_helper'

class KaixinschedulersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kaixinschedulers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kaixinscheduler" do
    assert_difference('Kaixinscheduler.count') do
      post :create, :kaixinscheduler => { }
    end

    assert_redirected_to kaixinscheduler_path(assigns(:kaixinscheduler))
  end

  test "should show kaixinscheduler" do
    get :show, :id => kaixinschedulers(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => kaixinschedulers(:one).to_param
    assert_response :success
  end

  test "should update kaixinscheduler" do
    put :update, :id => kaixinschedulers(:one).to_param, :kaixinscheduler => { }
    assert_redirected_to kaixinscheduler_path(assigns(:kaixinscheduler))
  end

  test "should destroy kaixinscheduler" do
    assert_difference('Kaixinscheduler.count', -1) do
      delete :destroy, :id => kaixinschedulers(:one).to_param
    end

    assert_redirected_to kaixinschedulers_path
  end
end
