class InvitesController < ApplicationController
  before_action :member
  skip_before_action :authenticate_user!, only: :decline

  respond_to :html

  def show

  end

  def accept
    if member.accept_invite!(current_user)
      label, path = source_info(member.source)

      redirect_to path, notice: "�ѽ�����Ϊ #{member.human_access} ���� #{label} �����롣"
    else
      redirect_back_or_default(options: { alert: "�������޷������ܡ�" })
    end
  end

  def decline
    if member.decline_invite!
      label, _ = source_info(member.source)

      path =
        if current_user
          dashboard_projects_path
        else
          new_user_session_path
        end

      redirect_to path, notice: "�Ѿܾ����� #{label} �����롣"
    else
      redirect_back_or_default(options: { alert: "�������޷����ܾ���" })
    end
  end

  private

  def member
    return @member if defined?(@member)

    @token = params[:id]
    @member = Member.find_by_invite_token(@token)

    unless @member
      render_404 and return
    end

    @member
  end

  def authenticate_user!
    return if current_user

    notice = "Ҫ���ܴ����룬���¼"
    notice << "���ߴ����˺�" if current_application_settings.signup_enabled?
    notice << "��"

    store_location_for :user, request.fullpath
    redirect_to new_user_session_path, notice: notice
  end

  def source_info(source)
    case source
    when Project
      project = member.source
      label = "��Ŀ #{project.name_with_namespace}"
      path = namespace_project_path(project.namespace, project)
    when Group
      group = member.source
      label = "Ⱥ�� #{group.name}"
      path = group_path(group)
    else
      label = "˭֪��"
      path = dashboard_projects_path
    end

    [label, path]
  end
end
