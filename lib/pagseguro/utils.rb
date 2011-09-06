module PagSeguro
  module Utils
    extend self

    def to_utf8(string)
      string.to_s.unpack("C*").pack("U*")
    end

    def to_iso8859(string)
      string.to_s.unpack("U*").pack("C*")
    end
  end
end

class Hash
  # TODO: Make test for this methods
  def recursive_symbolize_underscorize_keys!
    symbolize_underscorize_keys!
    values.select{|v| v.is_a? Hash}.each{|h| h.recursive_symbolize_underscorize_keys!}
    values.select{|v| v.is_a? Array}.each{|h| h.each{|h| h.recursive_symbolize_underscorize_keys!}}
    self
  end

  def symbolize_underscorize_keys!
    keys.each do |key|
      self[(key.to_s.underscore.to_sym rescue key) || key] = delete(key)
    end
    self
  end
end

