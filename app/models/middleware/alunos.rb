class Middleware::Alunos < ActiveRecord::Base
  self.table_name='View_UNASUS2_Alunos'
  establish_connection :middleware
end