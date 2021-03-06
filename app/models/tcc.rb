class Tcc < ActiveRecord::Base
  attr_accessible :grade, :student, :tutor, :orientador, :title, :tcc_definition, :defense_date,
                  :abstract_attributes, :chapters_attributes
  validates :grade, :numericality => {greater_than_or_equal_to: 0, less_than_or_equal_to: 100}, allow_nil: true

  has_many :chapters, :inverse_of => :tcc
  has_one :abstract, :inverse_of => :tcc
  has_many :batch_prints, :inverse_of => :tcc

  belongs_to :tcc_definition, -> { includes :internal_course }, :inverse_of => :tccs

  # Referencias
  has_many :references, :dependent => :destroy
  has_many :book_refs,        :through => :references, :source => :element, :source_type => 'BookRef'
  has_many :book_cap_refs,    :through => :references, :source => :element, :source_type => 'BookCapRef'
  has_many :article_refs,     :through => :references, :source => :element, :source_type => 'ArticleRef'
  has_many :internet_refs,    :through => :references, :source => :element, :source_type => 'InternetRef'
  has_many :legislative_refs, :through => :references, :source => :element, :source_type => 'LegislativeRef'
  has_many :thesis_refs,      :through => :references, :source => :element, :source_type => 'ThesisRef'

  # Pessoas / papeis envolvidos:
  belongs_to :student, class_name: 'Person'
  belongs_to :tutor, class_name: 'Person'
  belongs_to :orientador, class_name: 'Person'

  # Salvar a nota no moodle caso ela tenha mudado
  before_save :post_moodle_grade

  accepts_nested_attributes_for :chapters, :abstract

  scope :ordered, -> { joins(:student).order('people.name') }

  include Shared::Search
  scoped_search :in => :student, :on => [:name]

  # Retorna o nome do estudante sem a matrícula ()
  def student_name
    self.name.gsub(/ \([0-9].*\)/, '')
  end

  def tcc_definition=(value)
    super(value)
    create_or_update_chapters
  end

  # Método responsável por criar os models relacionados ao TCC
  def create_dependencies!
    self.build_abstract if self.abstract.nil?
  end

  def post_moodle_grade
    if self.grade_changed? && !self.tcc_definition.nil? && (self.tcc_definition.course_id > 0)
      remote = MoodleAPI::MoodleGrade.new
      remote.set_grade_lti(self.student.moodle_id,
                       self.tcc_definition.course_id,
                       self.tcc_definition.moodle_instance_id,
                       self.grade)
    end
  end

  def count_references
    ref_ids = []
    ref_ids |= self.abstract.citations if !self.abstract.nil?

    if (!self.chapters.nil?)
      self.chapters.each { | chapter |
        ref_ids |= chapter.citations
      }
    end
    ref_ids.count
  end

  private

  def create_or_update_chapters
    unless self.tcc_definition.nil?

      self.tcc_definition.chapter_definitions.each do |chapter_definition|

        if self.chapters.empty?
          self.chapters.build(tcc: self, chapter_definition: chapter_definition, position: chapter_definition.position)
        else
          chapter_tcc = self.chapters.find_or_initialize_by(position: chapter_definition.position)
          chapter_tcc.chapter_definition = chapter_definition
          chapter_tcc.save!
        end

      end
    end
  end

end