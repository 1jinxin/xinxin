class @Star
  constructor: ->
    $('.project-home-panel .toggle-star').on('ajax:success', (e, data, status, xhr) ->
      $this = $(this)
      $starSpan = $this.find('span')
      $starIcon = $this.find('i')

      toggleStar = (isStarred) ->
        $this.parent().find('.star-count').text data.star_count
        if isStarred
          $starSpan.removeClass('starred').text '�Ǳ�'
          $starIcon.removeClass('fa-star').addClass 'fa-star-o'
        else
          $starSpan.addClass('starred').text 'ȡ���Ǳ�'
          $starIcon.removeClass('fa-star-o').addClass 'fa-star'
        return

      toggleStar $starSpan.hasClass('starred')
      return
    ).on 'ajax:error', (e, xhr, status, error) ->
      new Flash('�Ǳ��л�ʧ�ܣ����Ժ����ԡ�', 'alert')
      return
