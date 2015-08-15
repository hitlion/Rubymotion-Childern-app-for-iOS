Given /^I am on the Story List screen/ do
  # TODO: check that this is actually the correct screen!
end

Given /^there are no stories available/ do
  # nothing to do in this case
  fixture_remove( 'Bundles', :NSDocumentDirectory )
  fixture_remove( 'Categories', :NSDocumentDirectory )
end

Given /^there (?:is|are) (\d+) (?:story|stories) available$/ do |story_count|
  fixture_dir = File.absolute_path( File.join( Dir.pwd, 'features', 'data' ) )
  case story_count.to_i
    when 1
      fixture_install( "#{File.join( fixture_dir, 'list_all_json_files', '26027f33004ef3dc1cef11420d0f5676.babbo' ) }",
                       'Bundles/26027f33004ef3dc1cef11420d0f5676.babbo', :NSDocumentDirectory )
    when 2
      fixture_install( "#{File.join( fixture_dir, 'list_all_json_files', '26027f33004ef3dc1cef11420d0f5676.babbo' ) }",
                       'Bundles/26027f33004ef3dc1cef11420d0f5676.babbo', :NSDocumentDirectory )
      fixture_install( "#{File.join( fixture_dir, 'list_all_json_files', '003d3dce9ad05f78b01f52d4a205c550.babbo' ) }",
                       'Bundles/003d3dce9ad05f78b01f52d4a205c550.babbo', :NSDocumentDirectory )
    else
      fail( "Unsupported story_count '#{story_count}'" )
  end
end

Then /^I should see an empty table$/ do
  element_exists( 'tableView' )
  uia( 'target.shake()' )

  res = query( 'tableView', numberOfRowsInSection:0 )

  if res.empty? or res.first != 0
    screenshot_and_raise( 'The table view is not empty!', :name => 'screenshot__table_not_empty.png' )
  end
end

Then /^I should see a table with (no|\d+) (?:entries|entry)$/ do |story_count|
  element_exists( 'tableView' )
  uia( 'target.shake()' )

  res = query( 'tableView', numberOfRowsInSection:0 )

  if res.empty?
    screenshot_and_raise( 'The table view is empty!', :name => 'screenshot__table_not_empty.png' )
  elsif res.first != story_count.to_i
    screenshot_and_raise( "Table view contains #{res.first} rows but should contain #{story_count} !", :name => 'screenshot__wrong_table_row_count.png' )
  end
end

Then /^table entry (\d+) should read "([^"]+)"$/ do |entry_no, entry_title|
  if query( "label marked:'#{entry_title}' parent tableViewCell indexPath:#{entry_no.to_i - 1},0" ).empty?
    screenshot_and_raise( "Table view contains no entry with the text '#{entry_title}' at index #{entry_no}", :name => 'screenshot__missing_table_entry.png' )
  end
end