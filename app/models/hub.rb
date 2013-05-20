class Hub < ActiveRecord::Base
  belongs_to :tcc
  has_many :diaries
  has_many :comments, :as => :commentable

  # Virtual attributes
  attr_accessor :new_state

  # Mass-Assignment
  attr_accessible :category, :reflection, :commentary, :grade, :diaries_attributes, :comments_attributes, :new_state

  accepts_nested_attributes_for :diaries, :comments

  validates_inclusion_of :grade, in: 0..1, allow_nil: true

  has_paper_trail :ignore => [:grade, :state]

  include AASM
  aasm_column :state

  aasm do
    state :draft, :initial => true
    state :sent_to_tutor_for_revision
    state :sent_to_tutor_for_evaluation
    state :tutor_evaluation_ok

    event :send_to_tutor_for_revision do
      transitions :from => :draft, :to => :sent_to_tutor_for_revision, :guard => :reflection_not_blank?
    end

    event :send_back_to_student do
      transitions :from => [:sent_to_tutor_for_revision, :sent_to_tutor_for_evaluation], :to => :draft#, :guard =>
    end

    event :send_to_tutor_for_evaluation do
      transitions :from => :draft, :to => :sent_to_tutor_for_evaluation, :guard => :reflection_not_blank?
    end

    event :evaluation_fails_and_send_back_to_student_for do
      transitions :from => :sent_to_tutor_for_evaluation, :to => :draft#, :guard =>
    end

    event :tutor_evaluate_ok do
      transitions :from => :sent_to_tutor_for_evaluation, :to => :tutor_evaluation_ok#, :guard =>
    end
  end

  def reflection_not_blank?
    if self.reflection.blank?
      false
    else
      true
    end
  end

end
