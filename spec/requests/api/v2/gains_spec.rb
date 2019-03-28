require 'rails_helper'

RSpec.describe 'Gains API' do
    let!(:user) { create(:user) }
    let!(:auth_data) { user.create_new_auth_token }
    let(:headers) do
        { 
            "Accept" => "application/vnd.projetofase8.v2", 
            "access-token" => auth_data['access-token'],
            "uid" => auth_data['uid'],
            "client" => auth_data['client']
        } 
    end
    
    before { host! "localhost:3000/api" }
    
    describe "GET /gains" do
        
        context 'when no filter param is sent' do            
            before do
                create_list(:gain, 5, user_id: user.id)
                get "/gains", params: {}, headers: headers
            end

            it "returns status code 200" do
                expect(response).to have_http_status(200)
            end
            it "returns 5 gains from database" do
                expect(json_body["data"].count).to eq(5)
            end            
        end
        
        context 'when filter param is sent' do
            let!(:salario_gain_1) { create(:gain, description: 'salario do mes', user_id: user.id) }
            let!(:salario_gain_2) { create(:gain, description: 'o salario do outro mes', user_id: user.id) }
            let!(:outra_gain_1) { create(:gain, description: 'mesada da semana', user_id: user.id) }
            let!(:outra_gain_2) { create(:gain, description: 'vendas do mes', user_id: user.id) }
            
            before do
                get '/gains?q[description_cont]=sala&q[s]=description+ASC', params: {}, headers: headers
            end
        
            it 'returns only the gains matching' do
                returned_gain_descriptions = json_body['data'].map { |t| t['attributes']['description'] }
                
                expect(returned_gain_descriptions).to eq([salario_gain_2.description, salario_gain_1.description])
            end        
        end
        
    end
    
    describe "GET /gains/:id" do
        
        let(:gain) { create(:gain, user_id: user.id) }
        
        before do
            get "/gains/#{gain.id}", params: {}, headers: headers
        end
        
        it "returns status code 200" do
            expect(response).to have_http_status(200)
        end
        it "returns the json for gain" do
            expect(json_body['data']['attributes']['description']).to eq(gain.description)
        end
        
    end
    
    describe "POST /gains" do
        
        before do
            post "/gains", params: { gain: gain_params }, headers: headers
        end
        
        context "when the params are valid" do
            let(:gain_params){ attributes_for(:gain) }
            
            it "returns status code 201" do
                expect(response).to have_http_status(201)
            end
            
            it "saves the gain in the database" do
                expect( Gain.find_by(description: gain_params[:description]) ).not_to be_nil
            end
            
            it "returns the json for created gain" do
                expect(json_body['data']['attributes']['description']).to eq(gain_params[:description])
            end
            
            it "assigns the created gain to the current user" do
                expect(json_body['data']['attributes']['user-id']).to eq(user.id)
            end
        end
        
        context "when the request params are invalid" do
            let(:gain_params){ attributes_for(:gain, description: ' ') }
            
            it "returns status code 422" do
                expect(response).to have_http_status(422)
            end
            
            it "does not save the gain in the database" do
                expect( Gain.find_by(description: gain_params[:description]) ).to be_nil
            end
            
            it "returns the json error for description" do
                expect(json_body['errors']).to have_key('description')
            end
        end 
        
    end    
    
    describe "PUT /gains/:id" do
        
        let!(:gain) { create(:gain, user_id: user.id) }
        
        before do
            put "/gains/#{gain.id}", params: { gain: gain_params }, headers: headers
        end
        
        context "when the params are valid" do
            let(:gain_params){ { description: 'Nova descricao receita' } }
            
            it "returns status code 200" do
                expect(response).to have_http_status(200)
            end
            
            it "returns the json for update gain" do
                expect(json_body['data']['attributes']['description']).to eq(gain_params[:description])
            end
            
            it "updates the gain in the database" do
                expect( Gain.find_by(description: gain_params[:description]) ).not_to be_nil
            end            
        end
        
         context "when the request params are invalid" do
            let(:gain_params){ { description: ' ' } }
            
            it "returns status code 422" do
                expect(response).to have_http_status(422)
            end
            
            it "does not save the gain in the database" do
                expect( Gain.find_by(description: gain_params[:description]) ).to be_nil
            end
            
            it "returns the json error for description" do
                expect(json_body['errors']).to have_key('description')
            end
        end
    
    end
    
    describe "DELETE /gains/:id" do
        
        let!(:gain) { create(:gain, user_id: user.id) }
        
        before do
            delete "/gains/#{gain.id}", params: {}, headers: headers
        end
        
        it "returns status code 204" do
            expect(response).to have_http_status(204)
        end
        
        it "removes the gain from the database" do
            expect { Gain.find(gain.id) }.to raise_error(ActiveRecord::RecordNotFound)
        end
        
    end
    
end