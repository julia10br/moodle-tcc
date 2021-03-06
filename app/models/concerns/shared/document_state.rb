module Shared::DocumentState
  extend ActiveSupport::Concern

  included do
    attr_accessible :state, :state_date

    state_machine :state, :initial => :empty do

      around_transition do |document, transition, block|
        block.call
        document.state_date = Date.today
      end

      state :empty
      state :draft
      state :review
      state :done

      event :to_draft do
        transition :empty => :draft, :review => :draft
      end

      event :to_review do
        transition :draft => :review, :empty => :review, :if => lambda {|document| !document.empty?}
      end

      event :to_done do
        transition :review => :done
      end

      event :to_draft_admin do
        transition :empty => :draft, :done => :draft, :review => :draft
      end

      event :to_review_admin do
        transition :done => :review, :draft => :review, :empty => :review
      end

      event :to_done_admin do
        transition :draft => :done, :review => :done, :empty => :done
      end

      event :to_empty_admin do
        transition :draft => :empty, :review => :empty, :done => :empty
      end

    end
  end
end
