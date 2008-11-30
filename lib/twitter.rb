module FuKing
  #####################################################
  # Twitter
  # Class lets you read and write to your twitter account.
  # Check out the Twitter REST api docs here: http://apiwiki.twitter.com/REST+API+Documentation
  # To see what you can and can't do.
  # CONFIGURATION:
  # Change the username and password in config/twitter.yml to your own
  # Twitter username and password.
  # GOOD TO KNOW:
  # Right now all that's supported is GETting and POSTing statuses. (user_timeline & update if you're reading)
  # the API docs. Hopefully you are.
  # USAGE:
  # It's pretty simple. Something along the lines of this in console:
  # @tweets = FuKing::Twitter.read_status
  # That will get all tweets. You can pass in the usual options to twitter to limit what
  # gets returned.
  # To post, try:
  # FuKing::Twitter.update("I love twitter!!!!")
  class Twitter
    cattr_accessor :config_file
    self.config_file = RAILS_ROOT + '/config/twitter.yml'

    def self.read_status(params = {})
      doc = Hpricot.XML(do_get(configs[:read_url],params))
      parse_response(doc)
    end

    def self.update(status, in_reply_to_status_id = nil)
      if configs["#{RAILS_ENV}_uri".to_sym].blank?
        logger.debug("Skipping tweet in RAILS_ENV=#{RAILS_ENV}. To change this, specify a value for #{RAILS_ENV}_uri in config/twitter.yml.")
      else
        response = do_post(configs[:write_url], :status => CGI::escapeHTML(status), :in_reply_to_status_id => in_reply_to_status_id)
        if response.code.to_i.eql?(200)
          parse_response(Hpricot.XML(response.body))
        else
          logger.debug("Tweet failed: #{response.inspect}")
          raise "#{response.code} #{response.message}"
        end
      end
    end

  private
    class << self
      def configs
        class_name = self.name.split('::').last.downcase
        @configs = File.open(config_file) { |file| YAML.load(file) }[class_name] if File.exists?(config_file)
        @configs.symbolize_keys!
      end

      def do_get(url,params = {})
        response = res = Net::HTTP.get_response(URI.parse(url + to_query(params)))
        response.body
      end

      def do_post(url,params = {})
        response = Net::HTTP.post_form(URI.parse(url), params)
        response
      end

      def logger() RAILS_DEFAULT_LOGGER; end

      def parse_response(doc)
        (doc/:status).inject([]) do |array,status|
          text = (status/:text).innerHTML
          created_at = (status/:created_at).innerHTML
          array << Tweet.new(:text => text, :created_at => created_at)
        end
      end

      def to_query(params)
        array = []
        params.each_pair do |key,value|
          array << "#{key}=#{value}"
        end
        return "?#{array.join('&')}"
      end
    end
  end # Twitter
end