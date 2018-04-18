module Proxies
  class Proxy

    def initialize
      @proxies = []
      @proxy = ''
      @proxy_usage = 0
      @proxy_max_usage = 1000
      scrap_proxies
    end

    def open_url(url)
      t = Time.now
      html_file = open(url).read
      p "open url: #{Time.now - t}"
      return Nokogiri::HTML(html_file)
    end

    def out_open_url(url)
      t = Time.now
      html_file = nil
      try = 1
      while try < 15
        begin
          p url
          Timeout.timeout(5) do
            html_file = open(url, proxy: get_proxy).read
            try = 15
          end
        rescue OpenURI::HTTPError => error
          if error.io.status[0] = 410
            html_file = '<h1>listing removed</h1>'
            try = 15
          else
            p "proxy failed - #{error}"
            next_proxy
            try += 1
          end
        rescue => error
          p "proxy failed - #{error}"
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
        return @proxies.first
      elsif @proxy_use < @proxy_max_usage
        return @proxy
      else
        next_proxy
        return @proxy = @proxies.first
      end
    end

    def scrap_proxies
      urls = ['https://free-proxy-list.net','https://sslproxies.org']
      urls.each do |url|
        html_file = open(url).read
        html_doc = Nokogiri::HTML(html_file)
        table = html_doc.search('#proxylisttable').first
        table.search('tbody').first.search('tr').each do |r|
          c = r.search('td')
          proxy = URI.parse("http://#{c[0].text}:#{c[1].text}")
          @proxies << proxy unless @proxies.include?(proxy)
        end
      end
    end

    def next_proxy
      proxy = @proxies.shift
      @proxies << proxy
      @proxy_usage = 0
    end

    def delete_proxy
      @proxies.shift
    end
  end
end
