require 'test_helper'

class SerializeExerciseRepresentationsTest < ActiveSupport::TestCase
  test "serialize representations" do
    current_time = Time.zone.now
    track_1 = create :track, slug: 'ruby', title: 'Ruby'
    track_2 = create :track, slug: 'csharp', title: 'C#'
    exercise_1 = create :practice_exercise, slug: 'bob', title: 'Bob', icon_name: 'bob', track: track_1
    exercise_2 = create :practice_exercise, slug: 'leap', title: 'Leap', icon_name: 'leap', track: track_2
    representation_1 = create :exercise_representation, id: 3, feedback_markdown: 'Yay', exercise: exercise_1, num_submissions: 5,
      last_submitted_at: current_time - 5.days
    representation_2 = create :exercise_representation, id: 7, feedback_markdown: 'Jip', exercise: exercise_2, num_submissions: 3,
      last_submitted_at: current_time - 2.days

    expected = [
      {
        id: 3,
        exercise: {
          icon_url: 'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/bob.svg',
          title: 'Bob'
        },
        track: {
          icon_url: 'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/tracks/ruby.svg',
          title: 'Ruby'
        },
        num_submissions: 5,
        appears_frequently: true,
        feedback_html: "<p>Yay</p>\n",
        last_submitted_at: current_time - 5.days,
        links: {}
      },
      {
        id: 7,
        exercise: {
          icon_url: 'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/leap.svg',
          title: 'Leap'
        },
        track: {
          icon_url: 'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/tracks/csharp.svg',
          title: 'C#'
        },
        num_submissions: 3,
        appears_frequently: false,
        feedback_html: "<p>Jip</p>\n",
        last_submitted_at: current_time - 2.days,
        links: {}
      }
    ]

    assert_equal expected, SerializeExerciseRepresentations.([representation_1, representation_2])
  end
end