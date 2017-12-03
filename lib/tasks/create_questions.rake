require 'csv'
namespace :csv do 
    task :load_data => [ :environment ] do
    csv_text = File.expand_path('../questions.csv', __FILE__)
    counter = 0
        CSV.foreach(csv_text) do |row|
            counter = counter + 1
            new_grade_id = 0
            new_subject_id = 0

            ## give grade and subject new id 
            case row[1] 
            when "7"
                new_grade_id = 8
            when "8"
                new_grade_id = 9
            when "9"
                new_grade_id = 10
            when "10"
                new_grade_id = 11
            when "11"
                new_grade_id = 12
            when "12"
                new_grade_id = 13
            else
                new_grade_id = 1
            end

            case row[2] 
            when "1"
                new_subject_id = 9
            when "2"
                new_subject_id = 10
            when "3"
                new_subject_id = 11
            when "8"
                new_subject_id = 15
            when "9"
                new_subject_id = 16
            when "11"
                new_subject_id = 14
            when "13"
                new_subject_id = 13
            when "14"
                new_subject_id = 12
            else
                new_subject_id = 1
            end

            grade_paper_ids = PaperGradeship.where(:grade_id => new_grade_id).pluck(:paper_id)          
            paper = Paper.where(:paper_subject_id => new_subject_id, :id => grade_paper_ids).limit(1)

            if paper.size == 0
                mapping_string = "舊試卷用資料" + new_subject_id.to_s + "-" +  new_grade_id.to_s 
                Paper.create do |p|
                    p.title = "舊有試卷"
                    p.paper_subject_id = new_subject_id 
                    p.visible = "購點後可見"
                    p.public_date = "2017-12-01"
                    p.grade_ids = new_grade_id 
                    p.active = false
                    p.platform_type = 0
                    p.note = mapping_string
                end
                paper_id = Paper.where(:note => mapping_string)[0].id
            else
                paper_id = paper[0].id
            end

                Question.create do |q|
                    q.position = row[5]
                    q.title = row[6]
                    q.title_attr = row[7]
                    q.questionA = row[8]
                    q.questionB = row[9]
                    q.questionC = row[10]
                    q.questionD = row[11]
                    q.questionA_attr = row[12]    
                    q.questionB_attr = row[13]    
                    q.questionC_attr = row[14]    
                    q.questionD_attr = row[15]
                    q.answer = row[16]
                    q.analysis = row[17]
                    q.analysis_att = row[18]
                    q.active = row[19]             
                    q.optionCount = 4
                    q.paper_id = paper_id
                    q.platform_type = 0
                    q.question_type = "單選"
                    q.answer_count = 0
                    q.first_correct_count = 0
                end
            puts counter
        end
    end
end