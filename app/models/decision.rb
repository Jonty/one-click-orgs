class Decision < ActiveRecord::Base
  belongs_to :proposal
  
  def to_event
    { :timestamp => self.proposal.close_date, :object => self, :kind => :decision }    
  end 
  
  def send_email
    Decision.send_later(:send_email_for, self.id)
  end
  
  def self.send_email_for(decision_id)
    decision = Decision.find(decision_id)
    
    Member.active.each do |m|
      DecisionMailer.notify_new_decision(m, decision).deliver
    end
  end
end