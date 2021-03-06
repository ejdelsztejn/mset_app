require 'fuzzystringmatch'

class SymptomsController < ApplicationController
  before_action :require_user

  def search
    if search_params[:symptom].empty? || search_params[:symptom] == ' '
      flash[:error] = 'Please be sure to specify a symptom'
      redirect_to request.referer
    else
      jarow = FuzzyStringMatch::JaroWinkler.create(:native)
      symptoms = Symptom.potential_symptoms(current_user).map {|symptom| symptom.description }
      @results = symptoms.select do |symptom|
        jarow.getDistance(search_params[:symptom].downcase, symptom.downcase) >= 0.7
      end

      @results << search_params[:symptom] if @results.empty?
    end
  end

  private

  def search_params
    params.permit(:symptom)
  end
end
