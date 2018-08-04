class NoticeController < ApplicationController
  def index
    @notices= Notice.all
  end

  def show
    @notice = Notice.find(params[:id])
    @images = Image.where(:notice_id => params[:id])
    @attacheds = Attached.where(:notice_id => params[:id])
  end

  def images
    @images = Image.all
  end

  def attacheds
    @attacheds = Attached.all
  end
end
