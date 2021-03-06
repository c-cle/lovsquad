class ChannelsController < ApplicationController

  before_action :set_channel, only: [:show, :edit, :update, :destroy, :join, :leave]

  def index
    @channels = Channel.all
    @channelusers = Channeluser.all
    if params[:search]
      @channels = Channel.search(params[:search]).order("created_at DESC")
    else
      @channels = Channel.all.order('created_at DESC')
    end
  end

  def show
    @message = Message.new
    @rewards = @channel.rewards
    if session[:instagram_user_id]
      path = "https://graph.instagram.com/#{session[:instagram_user_id]}?fields=id,username,media&access_token=#{session[:access_token]}"
      results = HTTParty.get(path)
      @username = results.parsed_response['username']

      media = results.parsed_response["media"]["data"]
      # p media

      media.each do |x|
        path = "https://graph.instagram.com/#{x["id"]}?fields=media_url,username,caption&access_token=#{session[:access_token]}"
        results = HTTParty.get(path)
        parsed_results = results.parsed_response
        p parsed_results
        Post.create!(channel: @channel, url:results.parsed_response["media_url"],caption:results.parsed_response["caption"])

        # Feed.new << parsed_results
      end
    end
  end

  def new
    @channel = Channel.new
  end

  def create
    @channel = Channel.new(channel_params)
    @channel.user_id = current_user.id
    if @channel.save
      redirect_to channels_path
    else
      render json: @channel.errors.full_messages, status: 422
    end
  end

  def edit
  end

  def update
    @channel.update(channel_params)
  end

  def destroy
    @channel.destroy
    redirect_to channels_path
  end

  def join
    @channeluser = Channeluser.new({ user_id: current_user.id, channel_id: @channel.id })
    if @channeluser.save
      Coin.create!({ user: current_user, channel: @channel, balance: 0 })
      redirect_to channel_path(@channel)
    else
      render json: @channeluser.errors.full_messages, status: 400
    end
  end

  private

  def channel_params
    params.require(:channel).permit(:name, :photo, :description)
  end

  def set_channel
    @channel = Channel.find(params[:id])
  end
end
