class KaixintasksController < ApplicationController
  # GET /kaixintasks
  # GET /kaixintasks.xml
  def index
    @kaixintasks = Kaixintask.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @kaixintasks }
    end
  end

  # GET /kaixintasks/1
  # GET /kaixintasks/1.xml
  def show
    @kaixintask = Kaixintask.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @kaixintask }
    end
  end

  # GET /kaixintasks/new
  # GET /kaixintasks/new.xml
  def new
    @kaixintask = Kaixintask.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @kaixintask }
    end
  end

  # GET /kaixintasks/1/edit
  def edit
    @kaixintask = Kaixintask.find(params[:id])
  end

  # POST /kaixintasks
  # POST /kaixintasks.xml
  def create
    @kaixintask = Kaixintask.new(params[:kaixintask])

    respond_to do |format|
      if @kaixintask.save
        flash[:notice] = 'Kaixintask was successfully created.'
        format.html { redirect_to(@kaixintask) }
        format.xml  { render :xml => @kaixintask, :status => :created, :location => @kaixintask }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @kaixintask.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /kaixintasks/1
  # PUT /kaixintasks/1.xml
  def update
    @kaixintask = Kaixintask.find(params[:id])

    respond_to do |format|
      if @kaixintask.update_attributes(params[:kaixintask])
        flash[:notice] = 'Kaixintask was successfully updated.'
        format.html { redirect_to(@kaixintask) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @kaixintask.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /kaixintasks/1
  # DELETE /kaixintasks/1.xml
  def destroy
    @kaixintask = Kaixintask.find(params[:id])
    @kaixintask.destroy

    respond_to do |format|
      format.html { redirect_to(kaixintasks_url) }
      format.xml  { head :ok }
    end
  end
end
