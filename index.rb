# frozen_string_literal: true

require 'google/apis/docs_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'

def count_unique_chinese_characters_from_google_docs(file_id, credentials_path)
  # Set up authentication
  token_store = Google::Auth::Stores::FileTokenStore.new(file: credentials_path)
  authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
    json_key_io: File.open(credentials_path),
    scope: Google::Apis::DocsV1::AUTH_DOCUMENTS_READONLY,
    token_store: token_store
  )

  # Initialize the Google Docs API client
  service = Google::Apis::DocsV1::DocsService.new
  service.authorization = authorizer

  # Get the content of the Google Docs file
  document = service.get_document(file_id)
  content = document.body.content

  chinese_characters = content.each_with_object([]) do |element, result|
    next unless element.paragraph&.elements

    element.paragraph.elements.each do |paragraph_element|
      next unless paragraph_element.text_run

      result << paragraph_element.text_run.content.scan(/[\p{Han}&&[^0-9]]/u)
    end
  end.flatten

  unique_characters = chinese_characters.uniq

  unique_characters.size
end

file_id = '1Z5OrYC2HS4boqnDMF0y_qUwa2Dkq3RIm8aEy47v-yMM'
credentials_path = '/home/sharpeim/Desktop/Developer/uniq-chinese-char-count-2442e44427dd.json'
unique_count = count_unique_chinese_characters_from_google_docs(file_id, credentials_path)
puts "You have learned #{unique_count} unique Chinese characters!"
