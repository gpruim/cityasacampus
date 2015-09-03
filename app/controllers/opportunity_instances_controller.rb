class OpportunityInstancesController < ApplicationController
  before_action :set_opportunity_instance, only: [:show, :edit, :update, :destroy]

  def index
    @opportunity_instances = OpportunityInstance.all
    @paginator = OpenStruct.new(opportunity_instances: @opportunity_instances, per_page: 15)

    respond_to do |format|
      format.html { render :index }
      format.json { paginate json: @opportunity_instances, root: :result }
    end
  end

  def show
    respond_to do |format|
      format.html { render :show }
      format.json { render json: @opportunity_instance, root: :result, serializer: OpportunityInstanceSerializer }
    end
  end

  def topic
    @opportunity_instances = OpportunityInstance.includes(:topic).all.select do |o|
      o.topic.present? && o.topic.name == params[:title]
    end

    respond_to do |format|
      format.html { render :index }
      format.json { paginate json: @opportunity_instances, root: :result }
    end
  end

  def search
    respond_to do |format|
      format.json {
        paginate(json: OpportunityInstance
          .joins(:topic)
          .joins(:opportunity)
          .where("opportunity_instances.ends_at > CURRENT_TIMESTAMP")
          .fuzzy_search({
            name: params[:term],
            description: params[:term],
            topics: {
              name: params[:term]
            },
            opportunities: {
              name: params[:term],
              description: params[:term]
            }
          }, false), root: :result
        )
      }
    end
  end

  # GET /opportunity_instances/new
  def new
    @opportunity_instance = OpportunityInstance.new
  end

  # GET /opportunity_instances/1/edit
  def edit
  end

  # POST /opportunity_instances
  # POST /opportunity_instances.json
  def create
    @opportunity_instance = OpportunityInstance.new(opportunity_instance_params)

    respond_to do |format|
      if @opportunity_instance.save
        format.html { redirect_to @opportunity_instance, notice: 'Opportunity instance was successfully created.' }
        format.json { render :show, status: :created, location: @opportunity_instance }
      else
        format.html { render :new }
        format.json { render json: @opportunity_instance.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /opportunity_instances/1
  # PATCH/PUT /opportunity_instances/1.json
  def update
    respond_to do |format|
      if @opportunity_instance.update(opportunity_instance_params)
        format.html { redirect_to @opportunity_instance, notice: 'Opportunity instance was successfully updated.' }
        format.json { render :show, status: :ok, location: @opportunity_instance }
      else
        format.html { render :edit }
        format.json { render json: @opportunity_instance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /opportunity_instances/1
  # DELETE /opportunity_instances/1.json
  def destroy
    @opportunity_instance.destroy
    respond_to do |format|
      format.html { redirect_to opportunity_instances_url, notice: 'Opportunity instance was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_opportunity_instance
      @opportunity_instance = OpportunityInstance.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def opportunity_instance_params
      params.require(:opportunity_instance).permit(:name, :address, :description, :registration_url, :location_name, :registration_deadline, :program_type, :logo_url, :starts_at, :ends_at, :online_address, :zipcode, :city, :state, :is_online, :hide_reason, :hide, :contact_name, :contact_email, :contact_phone, :registration_url, :price_level, :min_age, :max_age, :extra_data, :duration, :difficulty)
    end
end
