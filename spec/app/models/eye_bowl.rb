class EyeBowl
  include Mongoid::Document

  has_many :blue_eyes, class_name: "Eye", as: :eyeable
  has_many :brown_eyes, class_name: "Eye", as: :eyeable
end