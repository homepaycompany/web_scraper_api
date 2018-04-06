module Proxies
  class Proxy
    require 'open-uri'
    require 'nokogiri'

    def initialize
      @proxies = []
      @proxy = ''
      @proxy_usage = 0
      @proxy_max_usage = 100
      scrap_proxies
    end

    def open_url(url)
      t = Time.now
      try = 1
      while try < 20
        p 'trying'
        begin
          html_file = open(url, proxy: get_proxy, read_timeout: 3).read
          try = 20
        rescue
          p 'proxy failed'
          delete_proxy
          try += 1
        end
      end
      p "open url: #{Time.now - t}"
      return Nokogiri::HTML(html_file)
    end

    private

    def get_proxy
      if @proxy_usage == 0
        return @proxies.sample
      elsif @proxy_use < @proxy_max_usage
        return @proxy
      else
        @proxy_usage == 0
        return @proxy = @proxies.sample
      end
    end

    def scrap_proxies
      url = 'https://sslproxies.org'
      html_file = open(url).read
      html_doc = Nokogiri::HTML(html_file)
      table = html_doc.search('#proxylisttable').first
      table.search('tbody').first.search('tr').each do |r|
        c = r.search('td')
        @proxies << URI.parse("http://#{c[0].text}:#{c[1].text}")
      end
    end

    def delete_proxy
      @proxies.delete(@proxy)
      @proxy_usage = 0
    end
  end
end
