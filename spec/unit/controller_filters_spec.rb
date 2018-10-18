require 'rails_helper'

describe ActiveAdmin::Application do
  let(:application){ ActiveAdmin::Application.new }
  let(:controllers){ application.controllers_for_filters }

  it 'controllers_for_filters' do
    expect(application.controllers_for_filters).to eq [
      ActiveAdmin::BaseController, ActiveAdmin::Devise::SessionsController,
      ActiveAdmin::Devise::PasswordsController, ActiveAdmin::Devise::UnlocksController,
      ActiveAdmin::Devise::RegistrationsController, ActiveAdmin::Devise::ConfirmationsController
    ]
  end

  it 'before_action' do
    controllers.each{ |c| expect(c).to receive(:before_action).and_return(true) }
    application.before_action :my_filter, only: :show
  end

  it 'skip_before_action' do
    controllers.each{ |c| expect(c).to receive(:skip_before_action).and_return(true) }
    application.skip_before_action :my_filter, only: :show
  end

  it 'after_action' do
    controllers.each{ |c| expect(c).to receive(:after_action).and_return(true) }
    application.after_action :my_filter, only: :show
  end

  it 'skip after_action' do
    controllers.each{ |c| expect(c).to receive(:skip_after_action).and_return(true) }
    application.skip_after_action :my_filter, only: :show
  end

  it 'around_action' do
    controllers.each{ |c| expect(c).to receive(:around_action).and_return(true) }
    application.around_action :my_filter, only: :show
  end

  it 'skip_filter' do
    controllers.each{ |c| expect(c).to receive(:skip_filter).and_return(true) }
    application.skip_filter :my_filter, only: :show
  end
end
