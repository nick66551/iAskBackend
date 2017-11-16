class PapersController < ApplicationController
  before_action :authenticate_user!, only: [:index, :show, :new, :edit, :create, :update, :destroy]
  before_action :set_paper, only: [:show, :edit, :update, :destroy]
  protect_from_forgery except: :filter

  # GET /papers
  # GET /papers.json
  def index

    if params[:filter] == nil
      orderParam = params[:orderParam]
      order = params[:order]
      
      if orderParam == nil
        orderParam = "id"
      end
      if order == nil
        order = "DESC"
      end

      if params[:relation] == "paper_subjects"
        if current_user.has_role? :iAsk
          @papers = Paper.includes(:paper_subject).where(platform_type: 0).order("paper_subjects.title #{order}").paginate(:page => params[:page], :per_page => 10)
        elsif current_user.has_role? :udn
          @papers = Paper.includes(:paper_subject).where(platform_type: 1).order("paper_subjects.title #{order}").paginate(:page => params[:page], :per_page => 10)    
        elsif current_user.has_role? :reader
          @papers = Paper.includes(:paper_subject).where(platform_type: 2).order("paper_subjects.title #{order}").paginate(:page => params[:page], :per_page => 10)
        elsif current_user.has_role? :admin
          @papers = Paper.includes(:paper_subject).where(platform_type: session[:platform_id]).order("paper_subjects.title  #{order}").paginate(:page => params[:page], :per_page => 10)
        end
      elsif params[:relation] == "grades"
        if current_user.has_role? :iAsk
          @papers = Paper.includes(:grades).where(platform_type: 0).order("grades.name #{order}").paginate(:page => params[:page], :per_page => 10)
        elsif current_user.has_role? :udn
          @papers = Paper.includes(:grades).where(platform_type: 1).order("grades.name #{order}").paginate(:page => params[:page], :per_page => 10)    
        elsif current_user.has_role? :reader
          @papers = Paper.includes(:grades).where(platform_type: 2).order("grades.name #{order}").paginate(:page => params[:page], :per_page => 10)
        elsif current_user.has_role? :admin
          @papers = Paper.includes(:grades).where(platform_type: session[:platform_id]).order("grades.name  #{order}").paginate(:page => params[:page], :per_page => 10)
        end
      else
        if current_user.has_role? :iAsk
          @papers = Paper.where(platform_type: 0).order("#{orderParam}  #{order}").paginate(:page => params[:page], :per_page => 10)
        elsif current_user.has_role? :udn
          @papers = Paper.where(platform_type: 1).order("#{orderParam}  #{order}").paginate(:page => params[:page], :per_page => 10)    
        elsif current_user.has_role? :reader
          @papers = Paper.where(platform_type: 2).order("#{orderParam}  #{order}").paginate(:page => params[:page], :per_page => 10)
        elsif current_user.has_role? :admin
          @papers = Paper.where(platform_type: session[:platform_id]).order("#{orderParam}  #{order}").paginate(:page => params[:page], :per_page => 10)
        end
      end
    else
      if current_user.has_role? :iAsk
        @papers = Paper.where(:id => session[:filter_papers_id], :platform_type => 0).paginate(:page => params[:page], :per_page => 10)
      elsif current_user.has_role? :udn
        @papers = Paper.where(:id => session[:filter_papers_id], :platform_type => 1).paginate(:page => params[:page], :per_page => 10)
      elsif current_user.has_role? :reader
        @papers = Paper.where(:id => session[:filter_papers_id], :platform_type => 2).paginate(:page => params[:page], :per_page => 10)
      elsif current_user.has_role? :admin
        @papers = Paper.where(:id => session[:filter_papers_id], :platform_type => session[:platform_id]).paginate(:page => params[:page], :per_page => 10)
      end
    end
    @question = Question.new
  end

  # GET /papers/1
  # GET /papers/1.json
  def show
  end

  # GET /papers/new
  def new
    @paper = Paper.new

    if current_user.has_role? :iAsk
      @grades = Grade.where(platform_type: 0)
    elsif current_user.has_role? :udn
      @grades = Grade.where(platform_type: 1) 
    elsif current_user.has_role? :reader
      @grades = Grade.where(platform_type: 2)
    elsif current_user.has_role? :admin
      @grades = Grade.where(platform_type: session[:platform_id])
    end

    if current_user.has_role? :iAsk
      @paper_subjects = PaperSubject.where(platform_type: 0)
    elsif current_user.has_role? :udn
      @paper_subjects = PaperSubject.where(platform_type: 1) 
    elsif current_user.has_role? :reader
      @paper_subjects = PaperSubject.where(platform_type: 2)
    elsif current_user.has_role? :admin
      @paper_subjects = PaperSubject.where(platform_type: session[:platform_id])
    end

    @visibles = [{name: "免費可見"},{name: "購點後可見"},{name: "付費可見"}]
  end

  # GET /papers/1/edit
  def edit
    if current_user.has_role? :iAsk
      @grades = Grade.where(platform_type: 0)
    elsif current_user.has_role? :udn
      @grades = Grade.where(platform_type: 1) 
    elsif current_user.has_role? :reader
      @grades = Grade.where(platform_type: 2)
    elsif current_user.has_role? :admin
      @grades = Grade.where(platform_type: session[:platform_id])
    end

    if current_user.has_role? :iAsk
      @paper_subjects = PaperSubject.where(platform_type: 0)
    elsif current_user.has_role? :udn
      @paper_subjects = PaperSubject.where(platform_type: 1) 
    elsif current_user.has_role? :reader
      @paper_subjects = PaperSubject.where(platform_type: 2)
    elsif current_user.has_role? :admin
      @paper_subjects = PaperSubject.where(platform_type: session[:platform_id])
    end
  end

  # POST /papers
  # POST /papers.json
  def create
    @paper = Paper.new(paper_params)
    if current_user.has_role? :iAsk
      @paper.platform_type = 0
    elsif current_user.has_role? :udn
      @paper.platform_type = 1  
    elsif current_user.has_role? :reader
      @paper.platform_type = 2
    elsif current_user.has_role? :admin
      @paper.platform_type = session[:platform_id]
    end
    respond_to do |format|
      if @paper.save
        format.html { redirect_to papers_path, notice: '成功建立試卷' }
        format.json { render :show, status: :created, location: @paper }
      else
        format.html { render :new }
        format.json { render json: @paper.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /papers/1
  # PATCH/PUT /papers/1.json
  def update
    respond_to do |format|
      if @paper.update(paper_params)
        format.html { redirect_to papers_path, notice: '成功編輯試卷' }
        format.json { render :show, status: :ok, location: @paper }
      else
        format.html { render :edit }
        format.json { render json: @paper.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /papers/1
  # DELETE /papers/1.json
  def destroy
    @paper.destroy
    respond_to do |format|
      format.html { redirect_to papers_url, notice: '成功刪除試卷' }
      format.json { head :no_content }
    end
  end

  def get_public_date
    @papers = Paper.distinct(:public_date).where(:platform_type => params[:platformId])
    render @papers
  end
  
  def get_paper_by_platform
    @papers = Paper.select("papers.id,papers.title,papers.public_date,papers.paper_subject_id,paper_subjects.title_view, paper_subjects.id as paper_subject_id").joins("LEFT JOIN paper_subjects ON papers.paper_subject_id = paper_subjects.id ").where(:active => true,:platform_type => params[:platformId])
    paper_subject_ids = Paper.distinct(:paper_subject_id).where(:active => true, :platform_type => params[:platformId]).pluck(:paper_subject_id)
    @papers.each{
      |paper| 
      subject_name_list = PaperSubject.find(paper.paper_subject_id).subjects.pluck(:name).join(",")
      correct_rates = StudentCorrectRate.where(:paper_id => paper.id, :student_id => params[:studentId]).pluck(:correct_rate)
      if !correct_rates.present?
        correct_rate = 0
      else
        correct_rate = correct_rates[0].to_i
      end
      paper.assign_attributes({ :subject_name => subject_name_list})
      paper.assign_attributes({ :correct_rate => correct_rate})
    }
    render json: @papers, methods: [:subject_name, :correct_rate]
  end

  def get_papers_by_subject
    paper_subject_ids = PapersubjectSubjectship.where(:subject_id => params[:subjectId]).pluck(:paper_subject_id)
    @papers = Paper.select("papers.id,papers.title,papers.public_date,papers.paper_subject_id,paper_subjects.title_view, paper_subjects.id as paper_subject_id").joins("LEFT JOIN paper_subjects ON papers.paper_subject_id = paper_subjects.id ").where(:paper_subject_id => paper_subject_ids, :active => true)
    @papers.each{
      |paper| 
      subject_name_list = PaperSubject.find(paper.paper_subject_id).subjects.pluck(:name).join(",")
      correct_rates = StudentCorrectRate.where(:paper_id => paper.id, :student_id => params[:studentId]).pluck(:correct_rate)
      if !correct_rates.present?
        correct_rate = 0
      else
        correct_rate = correct_rates[0].to_i
      end
      paper.assign_attributes({ :subject_name => subject_name_list})
      paper.assign_attributes({ :correct_rate => correct_rate})
    }
    render json: @papers, methods: [:subject_name, :correct_rate]

  end


  def filter
    subject_name = params[:filter][:subject_name]
    grade_name = params[:filter][:grade_name]
    init_public_date = params[:filter][:init_public_date]
    end_public_date = params[:filter][:end_public_date]    
    active = params[:filter][:active]    


    @filter_papers = Paper.all
    if subject_name != ""
      subject_id = Subject.where(:name => subject_name, :platform_type => session[:platform_id]).pluck(:id)
      subject_paper_subject_ids = PapersubjectSubjectship.where(:subject_id => subject_id).pluck(:paper_subject_id)
      @filter_papers = @filter_papers.where(:paper_subject_id => subject_paper_subject_ids)
    end
    if grade_name != ""
      grade_id = Grade.where(:name => grade_name, :platform_type => session[:platform_id]).pluck(:id)
      grade_paper_ids = PaperGradeship.where(:grade_id => grade_id).pluck(:paper_id)
      @filter_papers = @filter_papers.where(:id => grade_paper_ids)
    end
    if init_public_date != "" && end_public_date == ""
      @filter_papers = @filter_papers.where("public_date >= '#{init_public_date}'") 
    elsif end_public_date != "" && init_public_date == "" 
      @filter_papers = @filter_papers.where("public_date <= '#{end_public_date}'")
    elsif end_public_date != "" && init_public_date != ""
      @filter_papers = @filter_papers.where("public_date BETWEEN '#{init_public_date}' and '#{end_public_date}'")
    end  
    if active != ""
      active = true?(active)
      @filter_papers = @filter_papers.where(:active => active) 
      puts @filter_papers.to_json
    end
    session[:filter_papers_id] = @filter_papers.pluck(:id)
    respond_to do |format|
      format.html { redirect_to '/papers?filter=true' }
      format.json { render :index, status: :ok, location: @filter_papers }
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_paper
      @paper = Paper.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def paper_params
      params.require(:paper).permit(:title, :active, :visible, :public_date, :note, :grade, :open_count, :correct_count,:paper_subject_id,:platform_type,:subject_name,:correct_rate,grade_ids:[])
    end

    def true?(obj)
      obj.to_s == "true"
    end
end
