class MinterState < ActiveRecord::Base
  validates :namespace, presence: true, uniqueness: true
  validates :template, presence: true
  validates :template, format: { with: Object.const_get('Noid::Template::VALID_PATTERN'), message: 'value fails regex' }

  # @return [Hash] options for Noid::Minter.new
  # * template [String] setting the identifier pattern
  # * seq [Integer] reflecting minter position in sequence
  # * counters [Array{Hash}] "buckets" each with :current and :max values
  # * rand [Object] random number generator object
  def noid_options
    return nil unless template
    opts = {
      :template => template,
      :seq => seq
    }
    opts[:counters] = JSON.parse(counters, :symbolize_names => true) if counters
    opts[:rand]     = Marshal.load(random) if random
    opts
  end
end
