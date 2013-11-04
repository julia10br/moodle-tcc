shared_examples_for 'indirect_citation' do
  before(:each) do
    ref.first_author = 'Alguma coisã qué deve ser ignorada GESTÃO'
  end


  it 'should include author' do
    ref.indirect_citation.should include("#{UnicodeUtils.titlecase(ref.first_author.split(' ').last)}")
  end

  it 'should include year' do
    ref.indirect_citation.should include(ref.year.to_s)
  end

  it 'should include (' do
    ref.indirect_citation.should include('(')
  end

  it 'should include )' do
    ref.indirect_citation.should include(')')
  end

  it 'should capitalize correctly' do
    text = "Gestão (#{ref.year})"
    expect(ref.indirect_citation).to eq(text)
  end

end

shared_examples_for 'indirect_citation with more than one author' do


  it 'should capitalize correctly with three authors' do
    ref.first_author = 'Alguma coisã qué deve ser ignorada GESTÃO'
    ref.second_author = 'Alguma coisã qué deve ser ignorada GESTÃO'
    ref.third_author = 'Alguma coisã qué deve ser ignorada GESTÃO'

    text = "Gestão, Gestão e Gestão (#{ref.year})"
    expect(ref.indirect_citation).to eq(text)
  end
  it 'should capitalize correctly with two authors' do
    ref.first_author = 'Alguma coisã qué deve ser ignorada GESTÃO'
    ref.second_author = 'Alguma coisã qué deve ser ignorada GESTÃO'
    ref.third_author = ''

    text = "Gestão e Gestão (#{ref.year})"
    expect(ref.indirect_citation).to eq(text)
  end
  it 'should capitalize correctly with one author' do
    ref.first_author = 'Alguma coisã qué deve ser ignorada GESTÃO'
    ref.second_author = ''
    ref.third_author = ''

    text = "Gestão (#{ref.year})"
    expect(ref.indirect_citation).to eq(text)
  end

  it 'should include year' do
    ref.indirect_citation.should include(ref.year.to_s)
  end

  it 'should include (' do
    ref.indirect_citation.should include('(')
  end

  it 'should include )' do
    ref.indirect_citation.should include(')')
  end

end