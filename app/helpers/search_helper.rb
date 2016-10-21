module SearchHelper

  def search_autocomplete_opts(term)
    return unless current_user

    resources_results = [
      groups_autocomplete(term),
      projects_autocomplete(term)
    ].flatten

    generic_results = project_autocomplete + default_autocomplete + help_autocomplete
    generic_results.select! { |result| result[:label] =~ Regexp.new(term, "i") }

    [
      resources_results,
      generic_results
    ].flatten.uniq do |item|
      item[:label]
    end
  end

  def search_entries_info(collection, scope, term)
    return unless collection.count > 0

    from = collection.offset_value + 1
    to = collection.offset_value + collection.length
    count = collection.total_count

    "��ʾ \"#{term}\" �� #{from} - #{to} / #{count} #{scope.humanize(capitalize: false)}"
  end

  private

  # Autocomplete results for various settings pages
  def default_autocomplete
    [
      { category: "����", label: "������������", url: profile_path },
      { category: "����", label: "SSH ��Կ",         url: profile_keys_path },
      { category: "����", label: "�Ǳ���",        url: root_path },
      { category: "����", label: "�����̨",    url: admin_root_path },
    ]
  end

  # Autocomplete results for internal help pages
  def help_autocomplete
    [
      { category: "����", label: "API ����",           url: help_page_path("api", "README") },
      { category: "����", label: "Markdown ����",      url: help_page_path("markdown", "markdown") },
      { category: "����", label: "Ȩ�ް���",   url: help_page_path("permissions", "permissions") },
      { category: "����", label: "�������ʰ���", url: help_page_path("public_access", "public_access") },
      { category: "����", label: "Rake �������",    url: help_page_path("raketasks", "README") },
      { category: "����", label: "SSH ��Կ����",      url: help_page_path("ssh", "README") },
      { category: "����", label: "ϵͳ���Ӱ���",  url: help_page_path("system_hooks", "system_hooks") },
      { category: "����", label: "Web ���Ӱ���",      url: help_page_path("web_hooks", "web_hooks") },
      { category: "����", label: "����������",      url: help_page_path("workflow", "README") },
    ]
  end

  # Autocomplete results for the current project, if it's defined
  def project_autocomplete
    if @project && @project.repository.exists? && @project.repository.root_ref
      ref = @ref || @project.repository.root_ref

      [
        { category: "��ǰ��Ŀ", label: "�ļ�",          url: namespace_project_tree_path(@project.namespace, @project, ref) },
        { category: "��ǰ��Ŀ", label: "�ύ",        url: namespace_project_commits_path(@project.namespace, @project, ref) },
        { category: "��ǰ��Ŀ", label: "����",        url: namespace_project_network_path(@project.namespace, @project, ref) },
        { category: "��ǰ��Ŀ", label: "ͼ��",          url: namespace_project_graph_path(@project.namespace, @project, ref) },
        { category: "��ǰ��Ŀ", label: "����",         url: namespace_project_issues_path(@project.namespace, @project) },
        { category: "��ǰ��Ŀ", label: "�ϲ�����", url: namespace_project_merge_requests_path(@project.namespace, @project) },
        { category: "��ǰ��Ŀ", label: "��̱�",     url: namespace_project_milestones_path(@project.namespace, @project) },
        { category: "��ǰ��Ŀ", label: "����Ƭ��",       url: namespace_project_snippets_path(@project.namespace, @project) },
        { category: "��ǰ��Ŀ", label: "��Ա",        url: namespace_project_project_members_path(@project.namespace, @project) },
        { category: "��ǰ��Ŀ", label: "ά��",           url: namespace_project_wikis_path(@project.namespace, @project) },
      ]
    else
      []
    end
  end

  # Autocomplete results for the current user's groups
  def groups_autocomplete(term, limit = 5)
    current_user.authorized_groups.search(term).limit(limit).map do |group|
      {
        category: "Ⱥ��",
        id: group.id,
        label: "#{search_result_sanitize(group.name)}",
        url: group_path(group)
      }
    end
  end

  # Autocomplete results for the current user's projects
  def projects_autocomplete(term, limit = 5)
    current_user.authorized_projects.search_by_title(term).
      sorted_by_stars.non_archived.limit(limit).map do |p|
      {
        category: "��Ŀ",
        id: p.id,
        value: "#{search_result_sanitize(p.name)}",
        label: "#{search_result_sanitize(p.name_with_namespace)}",
        url: namespace_project_path(p.namespace, p)
      }
    end
  end

  def search_result_sanitize(str)
    Sanitize.clean(str)
  end

  def search_filter_path(options={})
    exist_opts = {
      search: params[:search],
      project_id: params[:project_id],
      group_id: params[:group_id],
      scope: params[:scope]
    }

    options = exist_opts.merge(options)
    search_path(options)
  end

  # Sanitize html generated after parsing markdown from issue description or comment
  def search_md_sanitize(html)
    sanitize(html, tags: %w(a p ol ul li pre code))
  end
end
