# Class for a Twitter status
# Instance methods are created_at and text
class Tweet
  def initialize(params = {})
    params.assert_valid_keys(:text, :created_at)
    @created_at = params[:created_at]
    @text       = params[:text]
  end

  def created_at
    @created_at
  end

  def text
    @text
  end

  def text=(value)
    @text = value
  end
end