class KaixinusersController < ApplicationController
  # GET /kaixinusers
  # GET /kaixinusers.xml
  def index
    @kaixinusers = Kaixinuser.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @kaixinusers }
    end
  end

  # GET /kaixinusers/1
  # GET /kaixinusers/1.xml
  def show
    @kaixinuser = Kaixinuser.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @kaixinuser }
    end
  end

  # GET /kaixinusers/new
  # GET /kaixinusers/new.xml
  def new
    @kaixinuser = Kaixinuser.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @kaixinuser }
    end
  end

  # GET /kaixinusers/1/edit
  def edit
    @kaixinuser = Kaixinuser.find(params[:id])
  end

  # POST /kaixinusers
  # POST /kaixinusers.xml
  def create
    @kaixinuser = Kaixinuser.new(params[:kaixinuser])

    respond_to do |format|
      if @kaixinuser.save
        flash[:notice] = 'Kaixinuser was successfully created.'
        format.html { redirect_to(@kaixinuser) }
        format.xml  { render :xml => @kaixinuser, :status => :created, :location => @kaixinuser }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @kaixinuser.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /kaixinusers/1
  # PUT /kaixinusers/1.xml
  def update
    @kaixinuser = Kaixinuser.find(params[:id])

    respond_to do |format|
      if @kaixinuser.update_attributes(params[:kaixinuser])
        flash[:notice] = 'Kaixinuser was successfully updated.'
        format.html { redirect_to(@kaixinuser) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @kaixinuser.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /kaixinusers/1
  # DELETE /kaixinusers/1.xml
  def destroy
    @kaixinuser = Kaixinuser.find(params[:id])
    @kaixinuser.destroy

    respond_to do |format|
      format.html { redirect_to(kaixinusers_url) }
      format.xml  { head :ok }
    end
  end
end
