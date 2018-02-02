namespace :create do 
    task :student_paper_log => [ :environment ] do
        @student_answer_logs = StudentAnswerLog.select('DISTINCT student_id,question_id,id ').all
        @student_answer_logs.each do |log|
            puts log.id
            @student_paper_log = StudentPaperLog.where(:student_id => log.student_id, :paper_id=> log.question.paper)
            if @student_paper_log.present?
                #count answer time 
                answer_time = 0
                answer_logs = StudentAnswerLog.where(:question_id => log.question_id, :student_id => log.student_id).order(:created_at)
                if answer_logs.present?
                  pre_time = answer_logs.first.created_at
                end
                current_time = nil
                answer_logs.each{
                  |answer_log|
                  current_time = answer_log.created_at
                  time_log = current_time - pre_time
          
                  if time_log < 3600000 
                    answer_time = answer_time + time_log
                  end
          
                  pre_time = answer_log.created_at
                }
                answer_time = Time.at(answer_time/1000).strftime("%H:%M:%S")

                #count finish rate
                total_size = log.question.paper.questions.size
                finish_size = StudentAnswerLog.distinct(:question_id).where(:question_id => log.question_id).size

                finish_rate = (finish_size.to_f / total_size.to_f)*100

                @student_paper_log.update(:finish_rate => finish_rate, :answer_time => answer_time)
            
            else
                #count answer time 
                answer_time = 0
                answer_logs = StudentAnswerLog.where(:question_id => log.question_id, :student_id => log.student_id).order(:created_at)
                if answer_logs.present?
                  pre_time = answer_logs.first.created_at
                end
                current_time = nil
                answer_logs.each{
                  |answer_log|

                  current_time = answer_log.created_at
                  time_log = current_time - pre_time

                  if time_log < 3600000 
                    answer_time = answer_time + time_log
                  end
          
                  pre_time = answer_log.created_at
                }
                if answer_time != 0.0
                    answer_time = Time.at(answer_time/1000).strftime("%H:%M:%S")
                end
                #count finish rate
                total_size = log.question.paper.questions.size
                finish_size = StudentAnswerLog.select('DISTINCT student_id,question_id,id ').where(:question_id => log.question_id, :student_id => log.student_id).size
                finish_rate = (finish_size.to_f / total_size.to_f)*100

                correct_rate = log.student.student_correct_rates.where(:paper_id => log.question.paper.id)[0].correct_rate
                StudentPaperLog.create(:student_id => log.student_id, :paper_id=> log.question.paper.id, :finish_rate => finish_rate, :answer_time => answer_time, :correct_rate => correct_rate)
            end
        end
    end
end
