require 'rails_helper'

RSpec.describe 'Expense API' do
    let!(:user) { create(:user) }
    let(:headers) { { "Accept" => "application/vnd.projetofase8.v2", "Authorization" => user.auth_token } }
    
    before { host! "localhost:3000/api" }
    
    describe "GET /expenses" do
        
        context 'when no filter param is sent' do            
            before do
                create_list(:expense, 5, user_id: user.id)
                get "/expenses", params: {}, headers: headers
            end

            it "returns status code 200" do
                expect(response).to have_http_status(200)
            end
            it "returns 5 expenses from database" do
                expect(json_body["data"].count).to eq(5)
            end            
        end
        
        context 'when filter param is sent' do
            let!(:salario_expense_1) { create(:expense, description: 'salario do mes', user_id: user.id) }
            let!(:salario_expense_2) { create(:expense, description: 'o salario do outro mes', user_id: user.id) }
            let!(:outra_expense_1) { create(:expense, description: 'mesada da semana', user_id: user.id) }
            let!(:outra_expense_2) { create(:expense, description: 'vendas do mes', user_id: user.id) }
            
            before do
                get '/expenses?q[description_cont]=sala&q[s]=description+ASC', params: {}, headers: headers
            end
        
            it 'returns only the expenses matching' do
                returned_expense_descriptions = json_body['data'].map { |t| t['attributes']['description'] }
                
                expect(returned_expense_descriptions).to eq([salario_expense_2.description, salario_expense_1.description])
            end        
        end
        
    end
    
    describe "GET /expenses/:id" do
        
        let(:expense) { create(:expense, user_id: user.id) }
        
        before do
            get "/expenses/#{expense.id}", params: {}, headers: headers
        end
        
        it "returns status code 200" do
            expect(response).to have_http_status(200)
        end
        it "returns the json for expense" do
            expect(json_body['data']['attributes']['description']).to eq(expense.description)
        end
        
    end
    
    describe "POST /expenses" do
        
        before do
            post "/expenses", params: { expense: expense_params }, headers: headers
        end
        
        context "when the params are valid" do
            let(:expense_params){ attributes_for(:expense) }
            
            it "returns status code 201" do
                expect(response).to have_http_status(201)
            end
            
            it "saves the expense in the database" do
                expect( Expense.find_by(description: expense_params[:description]) ).not_to be_nil
            end
            
            it "returns the json for created expense" do
                expect(json_body['data']['attributes']['description']).to eq(expense_params[:description])
            end
            
            it "assigns the created expense to the current user" do
                expect(json_body['data']['attributes']['user-id']).to eq(user.id)
            end
        end
        
        context "when the request params are invalid" do
            let(:expense_params){ attributes_for(:expense, description: ' ') }
            
            it "returns status code 422" do
                expect(response).to have_http_status(422)
            end
            
            it "does not save the expense in the database" do
                expect( Expense.find_by(description: expense_params[:description]) ).to be_nil
            end
            
            it "returns the json error for description" do
                expect(json_body['errors']).to have_key('description')
            end
        end 
        
    end    
    
    describe "PUT /expenses/:id" do
        
        let!(:expense) { create(:expense, user_id: user.id) }
        
        before do
            put "/expenses/#{expense.id}", params: { expense: expense_params }, headers: headers
        end
        
        context "when the params are valid" do
            let(:expense_params){ { description: 'Nova descricao receita' } }
            
            it "returns status code 200" do
                expect(response).to have_http_status(200)
            end
            
            it "returns the json for update expense" do
                expect(json_body['data']['attributes']['description']).to eq(expense_params[:description])
            end
            
            it "updates the expense in the database" do
                expect( Expense.find_by(description: expense_params[:description]) ).not_to be_nil
            end            
        end
        
         context "when the request params are invalid" do
            let(:expense_params){ { description: ' ' } }
            
            it "returns status code 422" do
                expect(response).to have_http_status(422)
            end
            
            it "does not save the expense in the database" do
                expect( Expense.find_by(description: expense_params[:description]) ).to be_nil
            end
            
            it "returns the json error for description" do
                expect(json_body['errors']).to have_key('description')
            end
        end
    
    end
    
    describe "DELETE /expenses/:id" do
        
        let!(:expense) { create(:expense, user_id: user.id) }
        
        before do
            delete "/expenses/#{expense.id}", params: {}, headers: headers
        end
        
        it "returns status code 204" do
            expect(response).to have_http_status(204)
        end
        
        it "removes the expense from the database" do
            expect { Expense.find(expense.id) }.to raise_error(ActiveRecord::RecordNotFound)
        end
        
    end
    
end