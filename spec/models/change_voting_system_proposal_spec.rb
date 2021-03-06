require 'spec_helper'

describe ChangeVotingSystemProposal do
  before do
    @constitution_voting_system = Clause.set_text('constitution_voting_system', 'RelativeMajority')        
    @proposed_system = 'Unanimous'
  end
  
  it "should change voting system after successful proposal" do
    @p = ChangeVotingSystemProposal.new

    Constitution.should_receive(:change_voting_system).with('constitution', @proposed_system)    
    passed_proposal(@p, 'type'=>'constitution', 'proposed_system'=>@proposed_system).call
  end
end
