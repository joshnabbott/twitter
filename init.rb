require 'hpricot'
require 'cgi'
require 'net/http'
require 'twitter'
require 'twitterify'
ActiveRecord::Base.send(:include, FuKing::Twitterify)
ActiveRecord::Base.send(:include, ActionView::Helpers::UrlHelper)
