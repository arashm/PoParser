# encoding: utf-8
require 'spec_helper'

describe PoParser::Comment do
  it 'converts the comment to string' do
    comment = PoParser::Comment.new(:translator_comment, "this is a line")
    result = "# this is a line\n"
    expect(comment.to_s(true)).to eq(result)
  end

  it 'converts array of same comment to string' do
    comment = PoParser::Comment.new(:translator_comment, ["this is a line", "this is another line"])
    result = "this is a line\nthis is another line"
    result_with_label = "# this is a line\n# this is another line\n"
    expect(comment.to_s).to eq(result)
    expect(comment.to_s(true)).to eq(result_with_label)
  end
end
