namespace :constitution do 
  desc "Create clauses for a default constitution. Set ORGANISATION_NAME to specify the organisation name, and OBJECTIVES to specify the objectives."
  task :create => :merb_env do
    organisation_name = ENV['ORGANISATION_NAME'] || "My Organisation"
    Clause.create(:name => 'organisation_name', :text_value => organisation_name)
    objectives = ENV['OBJECTIVES'] || ""
    Clause.create(:name => 'objectives', :text_value => objectives)
    Clause.create(:name => 'assets', :boolean_value => true)
    Clause.create(:name => 'domain', :text_value => "")
    Clause.create(:name => 'voting_period', :integer_value => 3)
    Clause.create(:name => 'general_voting_system', :text_value => "RelativeMajority")
    Clause.create(:name => 'membership_voting_system', :text_value => "RelativeMajority")
    Clause.create(:name => 'constitution_voting_system', :text_value => "RelativeMajority")
  end
end