class StatusesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update]
  before_action :set_status, only: [:show, :edit, :update, :destroy]

  # GET /statuses
  # GET /statuses.json
  def index
    @statuses = Status.includes(:user).order('created_at DESC').paginate(:page => params[:page], :per_page => 15)
    respond_to do |format|
      format.html
      format.json
    end
  end

  # GET /statuses/1
  # GET /statuses/1.json
  def show
  end

  # GET /statuses/new
  def new
    @status = Status.new
    @status.build_document
  end

  # GET /statuses/1/edit
  def edit
    @status.build_document unless @status.document
  end

  # POST /statuses
  # POST /statuses.json
  def create
    @status = Status.new(status_params)
    @status.user_id = current_user.id

    respond_to do |format|
      if @status.save
        current_user.create_activity(@status, 'created')
        format.html { redirect_to @status, notice: 'Status was successfully created.' }
        format.json { render action: 'show', status: :created, location: @status }
      else
        format.html { render action: 'new' }
        format.json { render json: @status.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /statuses/1
  # PATCH/PUT /statuses/1.json
  def update
    @document = @status.document
    respond_to do |format|
      if @status.update_attributes(status_params)
        current_user.create_activity(@status, 'updated')
        format.html { redirect_to @status, notice: 'Status was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @status.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /statuses/1
  # DELETE /statuses/1.json
  def destroy
    @status.destroy
    respond_to do |format|
      current_user.create_activity(@status, 'deleted')
      format.html { redirect_to statuses_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_status
      @status = Status.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def status_params
      params.require(:status).permit(:content, :document_attributes => [ :id, :_destroy, :image ])
    end
end
