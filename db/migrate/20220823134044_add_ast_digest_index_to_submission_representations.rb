class AddAstDigestIndexToSubmissionRepresentations < ActiveRecord::Migration[7.0]
  def change
    add_index :submission_representations, %i[submission_id ast_digest], unique: false
  end
end