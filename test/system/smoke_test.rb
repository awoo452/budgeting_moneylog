require "application_system_test_case"

class SmokeTest < ApplicationSystemTestCase
  test "root responds" do
    visit "/"
    assert_selector "body"
  end
end
