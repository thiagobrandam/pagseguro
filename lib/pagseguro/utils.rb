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
  def recursive_symbolize_keys
    symbolize_keys!
    values.select{|v| v.is_a? Hash}.each{|h| h.recursive_symbolize_keys}
    values.select{|v| v.is_a? Array}.each{|h| h.each{|h| h.recursive_symbolize_keys}}
    self
  end
end

