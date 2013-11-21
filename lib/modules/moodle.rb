# encoding: utf-8
module Moodle

  # Executa uma chamada remota a um webservice do Moodle
  # @param [String] remote_method_name
  # @param [Hash] params
  # @param [Proc] block
  def self.remote_call(remote_method_name, params={}, &block)
    Rails.logger.debug "[Moodle WS] Chamada remota: #{remote_method_name}, parametros: #{params}"

    default = {:wstoken => TCC_CONFIG['token'], :wsfunction => remote_method_name}

    post_params = default
    post_params.merge!(params) unless params.empty?

    RestClient.post(TCC_CONFIG['server'], post_params) do |response|
      Rails.logger.debug "[WS Moodle] resposta: #{response.code} #{response.inspect}"

      if response.code != 200
        Rails.logger.error "Falha ao acessar o webservice do Moodle: HTTP_ERROR: #{response.code}"

        return false
      end

      block.call(response)
    end
  end


  def self.fetch_hub_diaries(hub, user_id)
    m = MoodleHub.new
    m.fetch_hub_diaries(hub, user_id)
  end

  def self.fetch_user_image(userid, coursemoduleid)
    Moodle.remote_call('local_wstcc_get_user_text_for_generate_doc',
      userid: userid,
      coursemoduleid: coursemoduleid
    ) do |response|
      # Utiliza Nokogiri como parser XML
      doc = Nokogiri.parse(response)

      # Verifica se ocorreu algum problema com o acesso
      if !doc.xpath('/EXCEPTION').blank?
        error_code = doc.xpath('/EXCEPTION/ERRORCODE').text
        error_message = doc.xpath('/EXCEPTION/MESSAGE').text
        debug_info = doc.xpath('/EXCEPTION/DEBUGINFO').text

        Rails.logger.error "Falha ao acessar o webservice do Moodle: #{error_message} (ERROR_CODE: #{error_code}) - #{debug_info}"
        return "Falha ao acessar o Moodle: #{error_message} (ERROR_CODE: #{error_code})"
      end

      # Recupera o conteúdo do texto online e coloca o token de ws
      onlinetext = doc.xpath('/RESPONSE/SINGLE/KEY[@name="onlinetext"]/VALUE').text
      onlinetext.gsub! '@@TOKEN@@', TCC_CONFIG['token']

    end

  end

  class MoodleHub
    def fetch_hub_diaries(hub, user_id)
      hub.diaries.each { |diary|
        online_text = fetch_online_text(user_id, diary.diary_definition.external_id)
        diary.content = online_text unless online_text.nil?
      }
    end

    def fetch_online_text(user_id, coursemodule_id)
      Moodle.remote_call('local_wstcc_get_user_online_text_submission',
                         :userid => user_id, :coursemoduleid => coursemodule_id) do |response|

        # Utiliza Nokogiri como parser XML
        doc = Nokogiri.parse(response)

        # Verifica se ocorreu algum problema com o acesso
        if !doc.xpath('/EXCEPTION').blank?


          error_code = doc.xpath('/EXCEPTION/ERRORCODE').text
          error_message = doc.xpath('/EXCEPTION/MESSAGE').text
          debug_info = doc.xpath('/EXCEPTION/DEBUGINFO').text

          Rails.logger.error "Falha ao acessar o webservice do Moodle: #{error_message} (ERROR_CODE: #{error_code}) - #{debug_info}"
          return "Falha ao acessar o Moodle: #{error_message} (ERROR_CODE: #{error_code})"
        end

        # Recupera o conteúdo do texto online
        online_text = doc.xpath('/RESPONSE/SINGLE/KEY[@name="onlinetext"]/VALUE').text

      end
    end
  end

  def self.fetch_user_text_for_generate_doc(user_id, coursemodule_id)
    Moodle.remote_call('local_wstcc_get_user_text_for_generate_doc',
                       :userid => user_id, :coursemoduleid => coursemodule_id) do |response|

      # Utiliza Nokogiri como parser XML
      doc = Nokogiri.parse(response)

      # Verifica se ocorreu algum problema com o acesso
      if !doc.xpath('/EXCEPTION').blank?


        error_code = doc.xpath('/EXCEPTION/ERRORCODE').text
        error_message = doc.xpath('/EXCEPTION/MESSAGE').text
        debug_info = doc.xpath('/EXCEPTION/DEBUGINFO').text

        Rails.logger.error "Falha ao acessar o webservice do Moodle: #{error_message} (ERROR_CODE: #{error_code}) - #{debug_info}"
        return "Falha ao acessar o Moodle: #{error_message} (ERROR_CODE: #{error_code})"
      end

      # Recupera o conteúdo do texto online
      online_text = doc.xpath('/RESPONSE/SINGLE/KEY[@name="onlinetext"]/VALUE').text
    end
  end

end