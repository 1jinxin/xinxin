class RepositoryCheckMailer < BaseMailer
  def notify(failed_count)
    if failed_count == 1
      @message = "һ����Ŀ�ֿ���ʧ��"
    else
      @message = "#{failed_count} ����Ŀ�ֿ���ʧ��"
    end

    mail(
      to: User.admins.pluck(:email),
      subject: "GitLab ��̨ | #{@message}"
    )
  end
end
