require 'test_helper'

class KaixintasksControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kaixintasks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kaixintask" do
    assert_difference('Kaixintask.count') do
      post :create, :kaixintask => { }
    end

    assert_redirected_to kaixintask_path(assigns(:kaixintask))
  end

  test "should show kaixintask" do
    get :show, :id => kaixintasks(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => kaixintasks(:one).to_param
    assert_response :success
  end

  test "should update kaixintask" do
    put :update, :id => kaixintasks(:one).to_param, :kaixintask => { }
    assert_redirected_to kaixintask_path(assigns(:kaixintask))
  end

  test "should destroy kaixintask" do
    assert_difference('Kaixintask.count', -1) do
      delete :destroy, :id => kaixintasks(:one).to_param
    end

    assert_redirected_to kaixintasks_path
  end
end
