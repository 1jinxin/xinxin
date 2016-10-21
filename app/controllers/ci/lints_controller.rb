module Ci
  class LintsController < ApplicationController
    before_action :authenticate_user!

    def show
    end

    def create
      @content = params[:content]

      if @content.blank?
        @status = false
        @error = "���ṩ .gitlab-ci.yml �ļ�����"
      else
        @config_processor = Ci::GitlabCiYamlProcessor.new(@content)
        @stages = @config_processor.stages
        @builds = @config_processor.builds
        @status = true
      end
    rescue Ci::GitlabCiYamlProcessor::ValidationError, Psych::SyntaxError => e
      @error = e.message
      @status = false
    rescue
      @error = 'δ�������'
      @status = false
    ensure
      render :show
    end
  end
end
