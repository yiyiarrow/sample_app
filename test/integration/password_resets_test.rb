require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  def setup 
    ActionMailer::Base.deliveries.clear
    @user = users(:xiaoming)
  end

  test "password resets" do
    get new_password_reset_path
    assert_template 'password_resets/new'

    # invalid email address test 
    post password_resets_path, password_reset: { email: "" }
    assert_not flash.empty?
    assert_template 'password_resets/new'

    # valid email address test 
    post password_resets_path, password_reset: { email: @user.email }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url    

    # password reset
    user = assigns(:user)
    
    # wrong email address
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url    

    # user not activated
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url    
    user.toggle!(:activated)
    
    # wrong token and right email address
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url    
    
    # right  token and right email address
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email

    # password and password_confirmation dismatch
    patch password_reset_path(user.reset_token), email: user.email, user: { password: "foobaz", password_confirmation: "barquxx" }
    assert_select 'div#error_explanation'

    # password and password_confirmation are empty 
    patch password_reset_path(user.reset_token), email: user.email, user: { password: " ", password_confirmation: " " }
    assert_not flash.empty?
    assert_template 'password_resets/edit'

    # password and password_confirmation are valid 
    patch password_reset_path(user.reset_token), email: user.email, user: { password: "xiaoming", password_confirmation: "xiaoming" }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end
end
