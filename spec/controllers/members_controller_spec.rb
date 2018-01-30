require 'rails_helper'

RSpec.describe MembersController, type: :controller do
  include Devise::Test::ControllerHelpers
  let(:current_user) { create(:user) }
  let(:campaign)     { create(:campaign, user: current_user) }
  let(:member)       { create(:member, campaign: campaign) }

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in current_user
  end

  describe 'POST #create' do
    let(:member_params) { attributes_for(:member).merge(campaign_id: campaign.id) }

    context 'when save with success' do
      before do
        post :create, params: {member: member_params }, format: :json
      end
      it 'responds with status 201' do
        expect(response).to have_http_status(201)
      end
      it 'returns member params' do
        expect(json_body[:name]).to eq(member_params[:name])
        expect(json_body[:email]).to eq(member_params[:email])
      end
    end

    context 'when not save' do
      before do
        post :create, params: {member: member_params.merge(name: '') }, format: :json
      end
      it 'responds with status 422' do
        expect(response).to have_http_status(422)
      end
      it 'returns errors' do
        expect(json_body[:name]).not_to be_nil
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when signed user is owner' do
      before do
        delete :destroy, params: {id: member.id}, format: :json
      end
      it 'responds with status 200' do
        expect(response).to have_http_status(200)
      end
      it 'destroy member of database' do
        expect( Member.find_by(id: member.id) ).to be_nil
      end
    end

    context 'when the signed is not owner' do
      let(:other_user) { create(:user) }
      let(:member) { create(:member, user: other_user) }
      it 'respond with forbidden' do
        delete :destroy, params: {id: member.id}, format: :json
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

   describe 'PUT #update' do
    let(:member_params) { {name: FFaker::Name.name} }

    context 'when save with success' do
      before do
        put :update, params: {id: member.id, member: member_params }, format: :json
      end
      it 'responds with status 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when not save' do
      before do
        post :update, params: {id: member.id, member: {name: ''} }, format: :json
      end
      it 'responds with status 422' do
        expect(response).to have_http_status(422)
      end
      it 'returns errors' do
        expect(json_body[:name]).not_to be_nil
      end
    end

    context 'when the signed user is not owner' do
      let(:other_user) { create(:user) }
      let(:member) { create(:member, user: other_user) }
      before do
        post :update, params: {id: member.id, member: {name: 'Other'} }, format: :json
      end
      it 'respond with forbidden' do
        expect(response).to have_http_status(:forbidden)
      end

      it 'not change the member' do
        member.reload
        expect( member.name ).not_to eq('Other')
      end
    end
  end

  describe 'GET #opened' do
    before do
      member.update_columns open: false, token: SecureRandom.urlsafe_base64(nil, false)
      sign_out current_user
    end

    it 'find member by token and update as opened' do
      get :opened, params: {token: member.token}, format: :json
      member.reload
      expect(member.open).to eq(true)
    end
  end
end
