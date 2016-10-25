# frozen_string_literal: true
class MinterState < ActiveRecord::Base
  validates :namespace, presence: true, uniqueness: true
  validates :template, presence: true
  validates :template, format: { with: Object.const_get('Noid::Template::VALID_PATTERN'), message: 'value fails regex' }
end
