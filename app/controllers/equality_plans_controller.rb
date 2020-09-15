# frozen_string_literal: true

class EqualityPlansController < ApplicationController
  before_action :authorize_global

  before_action :define_months, :define, :groups, :training, :salary, :ages, only: [:index]

  def index

  end

  def define
    @groups = Group.all
    @users = User.andy.all
    @male_users = User.male
    @female_users = User.female
    @male_users_count = GenderStory.all.map(&:male_count)
    @female_users_count = GenderStory.all.map(&:female_count)
  end

  def manage
    user = User.find(params['id'])
    user.gender_custom_field.first.update_column(:value, params['gender'])
  end

  def define_months
    start_date = User.first.created_on
    end_date = Date.today

    number_of_months = (end_date.year * 12 + end_date.month) - (start_date.year * 12 + start_date.month)

    dates = number_of_months.times.each_with_object([]) do |count, array|
      array << [start_date.beginning_of_month + count.months,
                start_date.end_of_month + count.months]
    end

    @months = dates.map { |m| m.first.to_s[0..6] }
  end

  def groups
    groups = Group.left_joins(:users).group(:id).where("users.status=1").order('COUNT(users.id) DESC')
    female_hash={}
    male_hash={}

    groups.each do |group|
      female_hash[group.id] = ((User.active.female.where("users.id IN (SELECT gu.user_id FROM groups_users gu WHERE gu.group_id=#{group.id})").count.to_f/group.users.count)*100).round(2)
      male_hash[group.id] = ((User.active.male.where("users.id IN (SELECT gu.user_id FROM groups_users gu WHERE gu.group_id=#{group.id})").count.to_f/group.users.count)*100).round(2)
    end

    female_hash = female_hash.each { |k, v| female_hash[k].nan? ? 0 : female_hash[k] }
    male_hash = male_hash.each { |k, v| male_hash[k].nan? ? 0 : male_hash[k] }

    @feminised_hash1 = female_hash.select {|k,v| v == 100}
    @masculinized_hash1 = male_hash.select { |k,v| @feminised_hash1.keys.include?(k) }

    @masculinized_hash2 = male_hash.select {|k,v| v == 100}
    @feminised_hash2 = female_hash.select { |k,v| @masculinized_hash2.keys.include?(k) }
  end

  def ages
    @ages = ['16-19', '20-29', '30-39', '40-49', '50-59', '60-80']

    @female_age_ranges = [User.for_age_range(16, 19).female.size,
                          User.for_age_range(20, 29).female.size,
                          User.for_age_range(30, 39).female.size,
                          User.for_age_range(40, 49).female.size,
                          User.for_age_range(50, 59).female.size,
                          User.for_age_range(60, 80).female.size]

    @male_age_ranges = [User.for_age_range(16, 19).male.size,
                        User.for_age_range(20, 29).male.size,
                        User.for_age_range(30, 39).male.size,
                        User.for_age_range(40, 49).male.size,
                        User.for_age_range(50, 59).male.size,
                        User.for_age_range(60, 80).male.size]
  end

  def salary
    @total_male = 0
    @total_female = 0
    User.female.custom_with_salary.each do |user|
      @total_female += user.salary_amount
    end

    User.male.custom_with_salary.each do |user|
      @total_male += user.salary_amount
    end

    @average_male_salary = User.male.custom_with_salary.size == 0 ? 0: @total_male/User.male.custom_with_salary.size
    @average_female_salary = User.female.custom_with_salary.size == 0 ? 0 : @total_female/User.female.custom_with_salary.size
  end

  def training
    @total_male_training_amount = 0
    @total_female_training_amount = 0

    @male_users.each do |male|
      @total_male_training_amount += male.invested_in_training_amount
    end

    @female_users.each do |female|
      @total_female_training_amount += female.invested_in_training_amount
    end
  end
end
