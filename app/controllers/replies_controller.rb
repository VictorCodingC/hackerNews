class RepliesController < ApplicationController
  before_action :set_reply, only: [:show, :edit, :update, :destroy]

  # GET /replies
  # GET /replies.json
  def index
    @replies = Reply.all
  end

  # GET /replies/1
  # GET /replies/1.json
  def show
  end

  # GET /replies/new
  def new
    @reply = Reply.new
  end

  # GET /replies/1/edit
  def edit
    render "comments/edit"
  end

  def new_reply
    @reply = Reply.find(params[:id])
    @replies = Reply.where("reply_id=?",@reply.id).order("created_at DESC")
  end

  # POST /replies
  # POST /replies.json
  def create

    auth_user = current_user
    begin
      tmp = User.where("oauth_token=?", request.headers["HTTP_API_KEY"])[0]
      if (tmp)
        auth_user = tmp
      end
    rescue

    end
    if auth_user
      @reply = Reply.new(reply_params)

      respond_to do |format|
        if @reply.save
          format.html { redirect_to @reply.comment.submission }
          format.json { render :show, status: :created, location: @reply }
        else
          format.html { redirect_to '/comments/' + (@reply.comment.id).to_s + '/new_reply', notice: 'Reply not created, you have to fill the field content' }
          format.json { render json: @reply.errors, status: :unprocessable_entity }
        end
      end
    else
      redirect_to "auth/google_oauth2"
    end
  end

  # PATCH/PUT /replies/1
  # PATCH/PUT /replies/1.json
  def update
    respond_to do |format|
      if @reply.update(reply_params)
        format.html { redirect_to @reply.comment.submission, notice: 'Reply was successfully updated.' }
        format.json { render :show, status: :ok, location: @reply }
      else
        format.html { render :edit }
        format.json { render json: @reply.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /replies/1
  # DELETE /replies/1.json
  def destroy
    @reply.destroy
    respond_to do |format|
      format.html { redirect_to replies_url }
      format.json { head :no_content }
    end
  end

  private
    def set_reply
      @reply = Reply.find(params[:id])
    end

    def reply_params
      params.require(:reply).permit(:content, :user_id, :comment_id)
    end
end
