module VisibilityLevelHelper
  def visibility_level_color(level)
    case level
    when Gitlab::VisibilityLevel::PRIVATE
      'vs-private'
    when Gitlab::VisibilityLevel::INTERNAL
      'vs-internal'
    when Gitlab::VisibilityLevel::PUBLIC
      'vs-public'
    end
  end

  # Return the description for the +level+ argument.
  #
  # +level+       One of the Gitlab::VisibilityLevel constants
  # +form_model+  Either a model object (Project, Snippet, etc.) or the name of
  #               a Project or Snippet class.
  def visibility_level_description(level, form_model)
    case form_model
    when Project
      project_visibility_level_description(level)
    when Group
      group_visibility_level_description(level)
    when Snippet
      snippet_visibility_level_description(level, form_model)
    end
  end

  def project_visibility_level_description(level)
    case level
    when Gitlab::VisibilityLevel::PRIVATE
      "��Ŀ������ȷ��Ȩ��ÿ���û����ʡ�"
    when Gitlab::VisibilityLevel::INTERNAL
      "��Ŀ���Ա������ѵ�¼�û���¡��"
    when Gitlab::VisibilityLevel::PUBLIC
      "��Ŀ���Ա��κ��û���¡��"
    end
  end

  def group_visibility_level_description(level)
    case level
    when Gitlab::VisibilityLevel::PRIVATE
      "��Ⱥ�������Ŀֻ�����Ա���Կ�����"
    when Gitlab::VisibilityLevel::INTERNAL
      "��Ⱥ������ڲ���Ŀֻ���ѵ�¼�û��ܿ�����"
    when Gitlab::VisibilityLevel::PUBLIC
      "��Ⱥ����乫����Ŀ���Ա��κ���Ȩ���û�������"
    end
  end

  def snippet_visibility_level_description(level, snippet = nil)
    case level
    when Gitlab::VisibilityLevel::PRIVATE
      if snippet.is_a? ProjectSnippet
        "�ô���Ƭ��ֻ����Ŀ��Ա�ܿ�����"
      else
        "�ô���Ƭ��ֻ���Լ��ܿ�����"
      end
    when Gitlab::VisibilityLevel::INTERNAL
      "�ô���Ƭ���κ��ѵ�¼�û������Կ�����"
    when Gitlab::VisibilityLevel::PUBLIC
      "�ô���Ƭ�ο��Ա��κ���Ȩ���û����ʡ�"
    end
  end

  def visibility_icon_description(form_model)
    case form_model
    when Project
      project_visibility_icon_description(form_model.visibility_level)
    when Group
      group_visibility_icon_description(form_model.visibility_level)
    end
  end

  def group_visibility_icon_description(level)
    "#{visibility_level_label(level)} - #{group_visibility_level_description(level)}"
  end

  def project_visibility_icon_description(level)
    "#{visibility_level_label(level)} - #{project_visibility_level_description(level)}"
  end

  def visibility_level_label(level)
    Project.visibility_levels.key(level)
  end

  def restricted_visibility_levels(show_all = false)
    return [] if current_user.is_admin? && !show_all
    current_application_settings.restricted_visibility_levels || []
  end

  def default_project_visibility
    current_application_settings.default_project_visibility
  end

  def default_snippet_visibility
    current_application_settings.default_snippet_visibility
  end

  def default_group_visibility
    current_application_settings.default_group_visibility
  end

  def skip_level?(form_model, level)
    form_model.is_a?(Project) && !form_model.visibility_level_allowed?(level)
  end
end
