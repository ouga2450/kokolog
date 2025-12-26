module LoginMacros
  def login_as(user)
    visit root_path
    click_link I18n.t("actions.login")
    fill_in "user_email", with: user.email
    fill_in "user_password", with: "password"
    click_button I18n.t("actions.login")
  end
end
