require 'spec_helper'

feature 'Merge requests > User posts diff notes', :js do
  let(:user) { create(:user) }
  let(:merge_request) { create(:merge_request) }
  let(:project) { merge_request.source_project }

  before do
    project.add_developer(user)
    gitlab_sign_in(user)
  end

  let(:comment_button_class) { '.add-diff-note' }
  let(:notes_holder_input_class) { 'js-temp-notes-holder' }
  let(:notes_holder_input_xpath) { './following-sibling::*[contains(concat(" ", @class, " "), " notes_holder ")]' }
  let(:test_note_comment) { 'this is a test note!' }

  context 'when hovering over a parallel view diff file' do
    before do
      visit diffs_namespace_project_merge_request_path(project.namespace, project, merge_request, view: 'parallel')
    end

    context 'with an old line on the left and no line on the right' do
      it 'allows commenting on the left side' do
        should_allow_commenting(find('[id="6eb14e00385d2fb284765eb1cd8d420d33d63fc9_23_22"]').find(:xpath, '..'), 'left')
      end

      it 'does not allow commenting on the right side' do
        should_not_allow_commenting(find('[id="6eb14e00385d2fb284765eb1cd8d420d33d63fc9_23_22"]').find(:xpath, '..'), 'right')
      end
    end

    context 'with no line on the left and a new line on the right' do
      it 'does not allow commenting on the left side' do
        should_not_allow_commenting(find('[id="2f6fcd96b88b36ce98c38da085c795a27d92a3dd_15_15"]').find(:xpath, '..'), 'left')
      end

      it 'allows commenting on the right side' do
        should_allow_commenting(find('[id="2f6fcd96b88b36ce98c38da085c795a27d92a3dd_15_15"]').find(:xpath, '..'), 'right')
      end
    end

    context 'with an old line on the left and a new line on the right' do
      it 'allows commenting on the left side' do
        should_allow_commenting(find('[id="2f6fcd96b88b36ce98c38da085c795a27d92a3dd_9_9"]').find(:xpath, '..'), 'left')
      end

      it 'allows commenting on the right side' do
        should_allow_commenting(find('[id="2f6fcd96b88b36ce98c38da085c795a27d92a3dd_9_9"]').find(:xpath, '..'), 'right')
      end
    end

    context 'with an unchanged line on the left and an unchanged line on the right' do
      it 'allows commenting on the left side' do
        should_allow_commenting(find('[id="2f6fcd96b88b36ce98c38da085c795a27d92a3dd_7_7"]', match: :first).find(:xpath, '..'), 'left')
      end

      it 'allows commenting on the right side' do
        should_allow_commenting(find('[id="2f6fcd96b88b36ce98c38da085c795a27d92a3dd_7_7"]', match: :first).find(:xpath, '..'), 'right')
      end
    end

    context 'with a match line' do
      it 'does not allow commenting on the left side' do
        should_not_allow_commenting(find('.match', match: :first).find(:xpath, '..'), 'left')
      end

      it 'does not allow commenting on the right side' do
        should_not_allow_commenting(find('.match', match: :first).find(:xpath, '..'), 'right')
      end
    end

    context 'with an unfolded line' do
      before(:each) do
        find('.js-unfold', match: :first).click
        wait_for_requests
      end

      # The first `.js-unfold` unfolds upwards, therefore the first
      # `.line_holder` will be an unfolded line.
      let(:line_holder) { first('.line_holder[id="1"]') }

      it 'does not allow commenting on the left side' do
        should_not_allow_commenting(line_holder, 'left')
      end

      it 'does not allow commenting on the right side' do
        should_not_allow_commenting(line_holder, 'right')
      end
    end
  end

  context 'when hovering over an inline view diff file' do
    before do
      visit diffs_namespace_project_merge_request_path(project.namespace, project, merge_request, view: 'inline')
    end

    context 'with a new line' do
      it 'allows commenting' do
        should_allow_commenting(find('[id="2f6fcd96b88b36ce98c38da085c795a27d92a3dd_10_9"]'))
      end
    end

    context 'with an old line' do
      it 'allows commenting' do
        should_allow_commenting(find('[id="6eb14e00385d2fb284765eb1cd8d420d33d63fc9_22_22"]'))
      end
    end

    context 'with an unchanged line' do
      it 'allows commenting' do
        should_allow_commenting(find('[id="2f6fcd96b88b36ce98c38da085c795a27d92a3dd_7_7"]'))
      end
    end

    context 'with a match line' do
      it 'does not allow commenting' do
        should_not_allow_commenting(find('.match', match: :first))
      end
    end

    context 'with an unfolded line' do
      before(:each) do
        find('.js-unfold', match: :first).click
        wait_for_requests
      end

      # The first `.js-unfold` unfolds upwards, therefore the first
      # `.line_holder` will be an unfolded line.
      let(:line_holder) { first('.line_holder[id="1"]') }

      it 'does not allow commenting' do
        should_not_allow_commenting line_holder
      end
    end

    context 'when hovering over a diff discussion' do
      before do
        visit diffs_namespace_project_merge_request_path(project.namespace, project, merge_request, view: 'inline')
        should_allow_commenting(find('[id="2f6fcd96b88b36ce98c38da085c795a27d92a3dd_7_7"]'))
        visit namespace_project_merge_request_path(project.namespace, project, merge_request)
      end

      it 'does not allow commenting' do
        should_not_allow_commenting(find('.line_holder', match: :first))
      end
    end
  end

  context 'when cancelling the comment addition' do
    before do
      visit diffs_namespace_project_merge_request_path(project.namespace, project, merge_request, view: 'inline')
    end

    context 'with a new line' do
      it 'allows dismissing a comment' do
        should_allow_dismissing_a_comment(find('[id="2f6fcd96b88b36ce98c38da085c795a27d92a3dd_10_9"]'))
      end
    end
  end

  describe 'with muliple note forms' do
    before do
      visit diffs_namespace_project_merge_request_path(project.namespace, project, merge_request, view: 'inline')
      click_diff_line(find('[id="2f6fcd96b88b36ce98c38da085c795a27d92a3dd_10_9"]'))
      click_diff_line(find('[id="6eb14e00385d2fb284765eb1cd8d420d33d63fc9_22_22"]'))
    end

    describe 'posting a note' do
      it 'adds as discussion' do
        expect(page).to have_css('.js-temp-notes-holder', count: 2)

        should_allow_commenting(find('[id="6eb14e00385d2fb284765eb1cd8d420d33d63fc9_22_22"]'), asset_form_reset: false)
        expect(page).to have_css('.notes_holder .note', count: 1)
        expect(page).to have_css('.js-temp-notes-holder', count: 1)
        expect(page).to have_button('Reply...')
      end
    end
  end

  context 'when the MR only supports legacy diff notes' do
    before do
      merge_request.merge_request_diff.update_attributes(start_commit_sha: nil)
      visit diffs_namespace_project_merge_request_path(project.namespace, project, merge_request, view: 'inline')
    end

    context 'with a new line' do
      it 'allows commenting' do
        should_allow_commenting(find('[id="2f6fcd96b88b36ce98c38da085c795a27d92a3dd_10_9"]'))
      end
    end

    context 'with an old line' do
      it 'allows commenting' do
        should_allow_commenting(find('[id="6eb14e00385d2fb284765eb1cd8d420d33d63fc9_22_22"]'))
      end
    end

    context 'with an unchanged line' do
      it 'allows commenting' do
        should_allow_commenting(find('[id="2f6fcd96b88b36ce98c38da085c795a27d92a3dd_7_7"]'))
      end
    end

    context 'with a match line' do
      it 'does not allow commenting' do
        should_not_allow_commenting(find('.match', match: :first))
      end
    end
  end

  def should_allow_commenting(line_holder, diff_side = nil, asset_form_reset: true)
    write_comment_on_line(line_holder, diff_side)

    click_button 'Comment'
    wait_for_requests

    assert_comment_persistence(line_holder, asset_form_reset: asset_form_reset)
  end

  def should_allow_dismissing_a_comment(line_holder, diff_side = nil)
    write_comment_on_line(line_holder, diff_side)

    find('.js-close-discussion-note-form').click

    assert_comment_dismissal(line_holder)
  end

  def should_not_allow_commenting(line_holder, diff_side = nil)
    line = get_line_components(line_holder, diff_side)
    line[:content].hover
    expect(line[:num]).not_to have_css comment_button_class
  end

  def get_line_components(line_holder, diff_side = nil)
    if diff_side.nil?
      get_inline_line_components(line_holder)
    else
      get_parallel_line_components(line_holder, diff_side)
    end
  end

  def get_inline_line_components(line_holder)
    { content: line_holder.find('.line_content', match: :first), num: line_holder.find('.diff-line-num', match: :first) }
  end

  def get_parallel_line_components(line_holder, diff_side = nil)
    side_index = diff_side == 'left' ? 0 : 1
    # Wait for `.line_content`
    line_holder.find('.line_content', match: :first)
    # Wait for `.diff-line-num`
    line_holder.find('.diff-line-num', match: :first)
    { content: line_holder.all('.line_content')[side_index], num: line_holder.all('.diff-line-num')[side_index] }
  end

  def click_diff_line(line_holder, diff_side = nil)
    line = get_line_components(line_holder, diff_side)
    line[:content].hover

    expect(line[:num]).to have_css comment_button_class

    line[:num].find(comment_button_class).click
  end

  def write_comment_on_line(line_holder, diff_side)
    click_diff_line(line_holder, diff_side)

    notes_holder_input = line_holder.find(:xpath, notes_holder_input_xpath)

    expect(notes_holder_input[:class]).to include(notes_holder_input_class)

    notes_holder_input.fill_in 'note[note]', with: test_note_comment
  end

  def assert_comment_persistence(line_holder, asset_form_reset:)
    notes_holder_saved = line_holder.find(:xpath, notes_holder_input_xpath)

    expect(notes_holder_saved[:class]).not_to include(notes_holder_input_class)
    expect(notes_holder_saved).to have_content test_note_comment

    assert_form_is_reset if asset_form_reset
  end

  def assert_comment_dismissal(line_holder)
    expect(line_holder).not_to have_xpath notes_holder_input_xpath
    expect(page).not_to have_content test_note_comment

    assert_form_is_reset
  end

  def assert_form_is_reset
    expect(page).to have_no_css('.js-temp-notes-holder')
  end
end
