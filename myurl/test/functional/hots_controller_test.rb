require File.dirname(__FILE__) + '/../test_helper'
require 'hots_controller'

# Re-raise errors caught by the controller.
class HotsController; def rescue_action(e) raise e end; end

class HotsControllerTest < Test::Unit::TestCase
  fixtures :hots

  def setup
    @controller = HotsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = hots(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:hots)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:hot)
    assert assigns(:hot).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:hot)
  end

  def test_create
    num_hots = Hot.count

    post :create, :hot => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_hots + 1, Hot.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:hot)
    assert assigns(:hot).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Hot.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Hot.find(@first_id)
    }
  end
end
