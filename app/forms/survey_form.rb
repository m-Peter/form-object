class SurveyForm < AbstractForm
  attribute :name

  association :questions, records: 1 do
    attribute :content

    association :answers, records: 2 do
      attribute :content
    end
  end
end