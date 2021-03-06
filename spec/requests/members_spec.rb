require 'spec_helper'

describe "everything" do
  before(:each) do
    stub_constitution!
    stub_organisation!
    login
  end
  
  describe "/members" do
    describe "GET" do
    
      before(:each) do
        get(members_path)
      end
    
      it "responds successfully" do
        @response.should be_successful
      end

      it "contains a list of members" do
        # pending
        @response.should have_xpath("//ol")
      end
    
    end
  
    describe "GET, given a members exists" do
      before(:each) do
        @member = Member.make
        get '/members'
      end
    
      it "has a list of members" do
        # pending
        @response.should have_xpath("//ol/li")
      end
    end
  
    describe "a successful POST" do
      before(:each) do

        post(members_path, { :member => { :id => nil, :email=>'anemail@example.com', :name=>"test" }})
      end
      
      it "redirects to resource(:members)" do
        @response.should redirect_to(members_path)
      end
      
      it "should set a notice flash" do
        flash[:notice].should_not be_blank
      end
    end
  end

  describe "/members/1" do 
    describe "a successful DELETE, given a member exists" do
      before(:each) do
        @member = Member.make
      end
      
      it "should create the proposal to eject the member" do
        EjectMemberProposal.should_receive(:serialize_parameters).with('id' => @member.id).and_return(@serialized_parameters = mock('serialized parameters'))
        EjectMemberProposal.should_receive(:new).with(
          :parameters => @serialized_parameters,
          :title => "Eject #{@member.name} from test",
          :proposer_member_id => @user.id
        ).and_return(@proposal = mock('proposal'))
        @proposal.should_receive(:save).and_return(true)
        
        make_request
      end

      it "should redirect to the control center" do
        make_request
        @response.should redirect_to('/one_click/control_centre')
      end
      
      def make_request
        delete(member_path(@member))
      end
     end
  end

  describe "/members/1/edit, given a member exists" do
    before(:each) do
      @member = Member.make
    end
  
    it "responds successfully if resource == current_user" do
      get(edit_member_path(default_user))
      @response.should be_successful
    end

    it "responds unauthorized if resource != current_user" do
      get(edit_member_path(@member), {}, {'HTTP_REFERER' => 'http://www.example.com/'})
      response.should redirect_to '/'
    end  
  end



  describe "/members/1, given a member exists" do
    before(:each) do
      @member = Member.make
    end
    
    describe "GET" do
      before(:each) do
        get(member_path(@member))
      end
      
      it "responds successfully" do
        @response.should be_successful
      end
      
      it "should display a form to eject the member" do
        @response.should have_selector("form[action='/members/#{@member.id}']") do |form|
          form.should have_selector "input[type=hidden][name=_method][value=delete]"
        end
      end
    end
  
    describe "PUT" do
      before(:each) do
        put(member_path(@member), :member => {:id => @member.id})
      end
  
      it "redirect to the member show action" do
        @response.should redirect_to(member_path(@member))
      end
    end
  end
end

