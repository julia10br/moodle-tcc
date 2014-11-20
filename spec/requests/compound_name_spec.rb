#encoding: utf-8
require 'spec_helper'

describe 'CompoundName' do

  context 'GET /compound_names' do
    it 'should render page with coordavea' do
      page.set_rack_session(fake_lti_session('urn:moodle:role/coordavea'))
      visit bibliographies_path(anchor: 'compound_names')

      expect(page.current_path).not_to eq(access_denied_path)
      expect(page).to have_content(I18n.t('activerecord.attributes.compound_name.name'))
    end

    it 'should not work without moodle' do
      get compound_names_path
      expect(response).to render_template('errors/unauthorized')
    end

    it 'should work with search term' do
      page.set_rack_session(fake_lti_session('urn:moodle:role/coordavea'))
      visit bibliographies_path(anchor: 'compound_names', search: 'São Paulo')

      expect(page).to have_content(I18n.t(:compound_name_search_result))
    end
  end

  context 'logged as unauthorized user' do
    context 'as a student' do
      it_behaves_like 'an unauthorized user who cannot edit compound names', 'student'
    end

    context 'as a coordenador de curso' do
      it_behaves_like 'an unauthorized user who cannot edit compound names', 'urn:moodle:role/coordcurso'
    end

    context 'as a coordenador de tutoria' do
      it_behaves_like 'an unauthorized user who cannot edit compound names', 'urn:moodle:role/tutoria'
    end
  end

  context 'logged as an authorized user' do
    context 'as admin' do
      it_behaves_like 'an authorized user who can edit compound names', 'administrator'
    end

    context 'as a coordenador avea' do
      it_behaves_like 'an authorized user who can edit compound names', 'urn:moodle:role/coordavea'
    end
  end
end
