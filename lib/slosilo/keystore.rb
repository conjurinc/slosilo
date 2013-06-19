require 'slosilo/key'

module Slosilo
  class Keystore
    def adapter 
      Slosilo::adapter or raise "No Slosilo adapter is configured or available"
    end
    
    def put id, key
      adapter.put_key id.to_s, key
    end
    
    def get opts
      id, fingerprint = opts.is_a?(Hash) ? [nil, opts[:fingerprint]] : [opts, nil]
      if id
        key = adapter.get_key(id.to_s)
      elsif fingerprint
        key, _ = get_by_fingerprint(fingerprint)
      end
      key
    end

    def get_by_fingerprint fingerprint
      adapter.get_by_fingerprint fingerprint
    end
    
    def each &_
      adapter.each { |k, v| yield k, v }
    end
    
    def any? &block
      each do |_, k|
        return true if yield k
      end
      return false
    end
  end
  
  class << self
    def []= id, value
      keystore.put id, value
    end
    
    def [] id
      keystore.get id
    end
    
    def each(&block)
      keystore.each(&block)
    end
    
    def sign object
      self[:own].sign object
    end
    
    def token_valid? token
      keystore.any? { |k| k.token_valid? token }
    end
    
    def token_signer token
      key, id = keystore.get_by_fingerprint token['key']
      if key && key.token_valid?(token)
        return id
      else
        return nil
      end
    end
    
    attr_accessor :adapter
    
    private
    def keystore
      @keystore ||= Keystore.new
    end
  end
end
