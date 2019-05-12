require 'rails_helper'
include SessionsHelper

RSpec.describe UsersController, type: :controller do

  describe 'Edit method' do

    before(:each) do
      @user_edit = User.create(name: 'joao silva', email: 'joaosilva@unb.br',
        password: '123456', registration:'1100061', cpf:'05601407380', active: 1)
      @user_adm = User.create(name: 'Luiz Guilherme', email: 'luiz@unb.br',
        password: '123456', registration:'1103061', cpf:'05601407350', active: 1)
      @administrative_assistant = AdministrativeAssistant.create(user: @user_adm)
    end

    it 'should return edit user' do
      sign_in(@user_edit)
      get :edit, params:{id: @user_edit.id}
      expect(response).to have_http_status(200)
    end

#    it 'should return to show current user if edit user id differ current user' do
#      sign_in(@user_edit)
#      get :edit, params:{id: @user_adm}
#      expect(response).to redirect_to(current_user)
#    end

  end

  describe 'Show methods' do

    before(:each) do
      @user = User.create(name: 'joao silva', email: 'joaosilva@unb.br',
        password: '123456', registration:'1100061', cpf:'05601407380', active: true)
      @campus = Campus.create(name: 'Gama')
      @department = Department.create(name: 'Departamento de Computação', campus_id: @campus.id)
      @discipline = Discipline.create(code: '876', name: 'Cálculo 3', department: @department)
      @course = Course.create(name: 'Engenharia de Software', department: @department)
      @coordinator = Coordinator.create(user: @user, course: @course)
      @user_adm = User.create(name: 'Luiz Guilherme', email: 'luiz@unb.br',
        password: '123456', registration:'1103061', cpf:'05601407350', active: true)
      @category = Category.create(name: 'Retroprojetor')
      @room = Room.create(code: '124325', name: 'S10', capacity: 50, active: true, time_grid_id: 1, department: @department, building: @building, category_ids: [@category.id])
      @administrative_assistant = AdministrativeAssistant.create(user_id: @user_adm.id)
      @school_room = SchoolRoom.create(name:'A', discipline: @discipline, vacancies: 40, course_ids: [@course.id])
      @school_room2 = SchoolRoom.create(name:'B', discipline: @discipline, vacancies: 40, course_ids: [@course.id])
      @allocation = Allocation.create(room_id:@room.id,school_room_id:@school_room.id, day:"Segunda",start_time:"12:00",final_time:"14:00", active: true, user: @user )
      @allocation2 = Allocation.create(room_id:@room.id,school_room_id:@school_room2.id, day:"Quarta",start_time:"12:00",final_time:"14:00", active: true, user: @user )
      @solicitation = Solicitation.create(justify: 'aaaa', status: 0, request_date: '10-01-2018', requester_id: @user.id, school_room_id: @school_room.id)
      @room_solicitation = RoomSolicitation.create(solicitation_id: @solicitation.id,start: '10-01-2018 18:00:00',final: '10-01-2018 20:00:00',day: "sabado",department_id: @department.id)
    end

    it 'should return current user show' do
      sign_in(@user)
      get :show, params:{id: @user.id}
      expect(response).to have_http_status(200)
    end

    it 'should return user show when administrative assistant access' do
      sign_in(@user_adm)
      get :show, params:{id: @user.id}
      expect(response).to have_http_status(200)
    end

#    it 'should return current user show if show user id differ current user and current user isn\'t administrative assistant' do
#      sign_in(@user)
#      get :show, params:{id: @user_adm.id}
#      expect(response).to redirect_to(current_user)
#    end

    it 'should return actives users' do
      sign_in(@user_adm)
      get :index
      expect(response).to have_http_status(200)
    end

#    it 'should return to current user show if current user isn\'t administrative assistant ' do
#      sign_in(@user)
#      get :index
#      expect(response).to redirect_to(current_user)
#    end



  end


  describe 'Destroy method' do

    before(:each) do
      @user_1 = User.create(name: 'joao silva', email: 'joaosilva@unb.br',
        password: '123456', registration:'1100061', cpf:'05601407380', active: true)
      @campus = Campus.create(name: 'Gama')
      @department = Department.create(name: 'Departamento de Computação', campus_id: @campus.id)
      @course = Course.create(name: 'Engenharia de Software', department: @department)
      @coordinator = Coordinator.create(user: @user_1, course: @course)
      @user_adm = User.create(name: 'Luiz Guilherme', email: 'luiz@unb.br',
        password: '123456', registration:'1103061', cpf:'05601407350', active: true)
      @administrative_assistant = AdministrativeAssistant.create(user: @user_adm)
    end

#    it 'should return current user show if user destroy id isn\'t current user' do
#      sign_in(@user_1)
#      get :destroy, params:{id: @user_adm.id}
#      expect(flash[:error]).to eq('Acesso Negado')
#      expect(response).to redirect_to(current_user)
#    end

    it 'should destroy user' do
      sign_in(@user_1)
      get :destroy, params:{id: @user_1.id}
      expect(flash[:success]).to eq('Usuário excluído com sucesso')
      expect(response).to redirect_to(login_path)
    end

    it 'should destroy administrative user when it isn\'t unique' do
      @user_adm_2 = User.create(name: 'Lucas Carvalho', email: 'lucas@unb.br',
        password: '123456', registration:'2203061', cpf:'22601407350', active: true)
      @administrative_assistant = AdministrativeAssistant.create(user_id: @user_adm_2.id)
      sign_in(@user_adm)
      get :destroy, params:{id: @user_adm.id}
      expect(flash[:success]).to eq('Usuário excluído com sucesso')
      expect(response).to redirect_to(login_path)
    end

#    it 'should not destroy administrative user when it is unique' do
#      sign_in(@user_adm)
#      get :destroy, params:{id: @user_adm.id}
#      expect(flash[:error]).to eq('Não é possível excluir o único assistante Administrativo')
#      expect(response).to redirect_to(current_user)
#    end
  end

  describe 'Update method' do

    before(:each) do
      @user = User.create(name: 'joao silva', email: 'joaosilva@unb.br',
        password: '123456', registration:'1100061', cpf:'05601407380', active: true)
    end

    it "should update a user" do
      sign_in(@user)
      post :update, params:{id: @user.id,user: {sname: 'Francisco Wallacy',
                                                password:123456}}
      expect(flash.now[:success]).to eq('Dados atualizados com sucesso')
    end

    it "should not update a user" do
      sign_in(@user)
      post :update, params:{id: @user.id,user: {name: ''}}
      expect(response).to redirect_to(user_edit_path)
      expect(flash[:warning]).to eq("Dados não foram atualizados")
    end
  end
end
